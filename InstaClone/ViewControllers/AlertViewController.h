
#import <UIKit/UIKit.h>

#define alertViewController [AlertViewController sharedInstance]

@interface AlertViewController : UIViewController

+ (instancetype)sharedInstance;
- (void)showErrorAlert:(NSString *)code title:(NSString *)title message:(NSString *)message target:(UIViewController *)target;
- (void)showTakePhotoAlert:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)target;
- (void)showSegueAlert:(NSString *)title message:(NSString *)message segueIdentifier:(NSString *)segueIdentifier target:(UIViewController *)target;

@end
