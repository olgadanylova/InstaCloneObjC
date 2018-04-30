
#import "AlertViewController.h"

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

- (void)showErrorAlert:(NSString *)code title:(NSString *)title message:(NSString *)message target:(UIViewController *)target {
    NSString *titleText = @"Error";
    if (code) {
        titleText = [NSString stringWithFormat:@"Error %@", code];
    }
    else if (title) {
        titleText = title;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleText message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:dismiss];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showTakePhotoAlert:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)target {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *useCamera = [UIAlertAction actionWithTitle:@"Use camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self showErrorAlert:nil title:@"No device found" message:@"Camera is not available" target:self];
        }
        else {
            UIImagePickerController *cameraPicker = [UIImagePickerController new];
            cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraPicker.delegate = target;
            [target presentViewController:cameraPicker animated:YES completion:nil];
        }
    }];
    UIAlertAction *usePhotoLibrary = [UIAlertAction actionWithTitle:@"Use Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *cameraPicker = [UIImagePickerController new];
        cameraPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraPicker.delegate = target;
        [target presentViewController:cameraPicker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:useCamera];
    [alert addAction:usePhotoLibrary];
    [alert addAction:cancel];
    [target presentViewController:alert animated:YES completion:nil];
}

- (void)showSegueAlert:(NSString *)title message:(NSString *)message target:(UIViewController *)target action:(void (^)(UIAlertAction *))action {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:action];
    [alert addAction:OK];
    [target presentViewController:alert animated:YES completion:nil];
}

@end
