
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
        UIImagePickerController *cameraPicker = [UIImagePickerController new];
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraPicker.delegate = target;
        [target presentViewController:cameraPicker animated:YES completion:nil];
    }];
    UIAlertAction *usePhotoLibrary = [UIAlertAction actionWithTitle:@"Use Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *cameraPicker = [UIImagePickerController new];
        cameraPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraPicker.delegate = target;
        [target presentViewController:cameraPicker animated:YES completion:nil];
    }];
    [alert addAction:useCamera];
    [alert addAction:usePhotoLibrary];
    [target presentViewController:alert animated:YES completion:nil];
}

@end
