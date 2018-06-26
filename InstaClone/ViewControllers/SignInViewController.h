
#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

- (IBAction)pressedSignIn:(id)sender;
- (IBAction)pressedRestorePassword:(id)sender;
- (IBAction)pressedRegister:(id)sender;

@end
