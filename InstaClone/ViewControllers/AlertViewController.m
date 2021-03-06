
#import "AlertViewController.h"
#import "PostViewController.h"
#import "PostCell.h"
#import "PostCaptionCell.h"
#import "Backendless.h"

@implementation AlertViewController

+ (instancetype)sharedInstance {
    static AlertViewController *sharedAlert;
    @synchronized(self) {
        if (!sharedAlert) {
            sharedAlert = [AlertViewController new];
        }
    }
    return sharedAlert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)showErrorAlert:(NSString *)message target:(UIViewController *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showErrorAlertWithExit:(UIViewController *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Make sure to configure the app with your APP ID and API KEY before running the app. \nApplication will be closed" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        exit(0);
    }]];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showTakePhotoAlert:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Use camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self showErrorAlert:@"Camera is not available" target:target];
        }
        else {
            UIImagePickerController *cameraPicker = [UIImagePickerController new];
            cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraPicker.delegate = target;
            [target presentViewController:cameraPicker animated:YES completion:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Use Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *photoPicker = [UIImagePickerController new];
        photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoPicker.delegate = target;
        [target presentViewController:photoPicker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showSegueAlert:(UIViewController *)target action:(void (^)(UIAlertAction *))action {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Registration complete" message:@"Please login to continue" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:action]];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showRestorePasswordAlert:(UIViewController *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Restore password" message: @"Please enter your email address. Then check your inbox to restore the password" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"your email";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target.view endEditing:YES];
        UITextField *emailField =  alert.textFields[0];
        [backendless.userService restorePassword:emailField.text response:^{
        } error:^(Fault *fault) {
            [self showErrorAlert:fault.message target:target];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [target.view endEditing:YES];
    }]];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showUpdateCompleteAlert:(UIViewController *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Profile updated" message: @"Your profile has been successfully updated" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [target performSegueWithIdentifier:@"unwindToProfileVC" sender:nil];
    }]];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showEditAlert:(Post *)post target:(UIViewController *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([target isKindOfClass:[PostViewController class]]) {
            PostViewController *postVC = (PostViewController *)target;
            postVC.editMode = YES;
            [postVC.tableView reloadData];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            PostCaptionCell *cell = (PostCaptionCell *)[postVC.tableView cellForRowAtIndexPath: indexPath];
            [cell.captionTextView becomeFirstResponder];      
            
            postVC.navigationItem.title = @"Edit post";
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:postVC action:@selector(pressedCancel:)];
            postVC.navigationItem.leftBarButtonItem = cancelButton;
            UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:postVC action:@selector(pressedSave:)];
            postVC.navigationItem.rightBarButtonItem = saveButton;
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Delete post" message:@"Are you sure you want to delete this post?" preferredStyle:UIAlertControllerStyleAlert];
        [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[backendless.data of:[Post class]] remove:post response:^(NSNumber *deleted) {
                if ([target isKindOfClass:[PostViewController class]]) {
                    [target performSegueWithIdentifier:@"unwindToProfileVC" sender:nil];
                }
            } error:^(Fault *fault) {
                [self showErrorAlert:fault.message target:target];
            }];
        }]];
        [confirmAlert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
        [target presentViewController:confirmAlert animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [target presentViewController:alert animated:YES completion:nil];
}

@end
