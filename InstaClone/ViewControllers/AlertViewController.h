
#import <UIKit/UIKit.h>
#import "Post.h"

#define alertViewController [AlertViewController sharedInstance]

@interface AlertViewController : UIViewController<UITextFieldDelegate>

+ (instancetype)sharedInstance;
- (void)showErrorAlert:(NSString *)message target:(UIViewController *)target;
- (void)showErrorAlertWithExit:(UIViewController *)target;
- (void)showTakePhotoAlert:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)target;
- (void)showSegueAlert:(UIViewController *)target action:(void(^)(UIAlertAction *))action;
- (void)showRestorePasswordAlert:(UIViewController *)target;
- (void)showUpdateCompleteAlert:(UIViewController *)target;
- (void)showEditAlert:(Post *)post target:(UIViewController *)target;

@end

