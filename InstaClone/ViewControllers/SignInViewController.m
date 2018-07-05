
#import "SignInViewController.h"
#import "AlertViewController.h"
#import "Backendless.h"

#define APP_ID @"APP_ID"
#define API_KEY @"API_KEY"
#define HOST_URL @"http://api.backendless.com"

@interface SignInViewController() {
    NSTimer *timer;
}
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.tag = 0;
    self.passwordField.tag = 1;    
    backendless.hostURL = HOST_URL;
    [backendless initApp:APP_ID APIKey:API_KEY];
    if (backendless.userService.isValidUserToken && backendless.userService.currentUser) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showTabBar) userInfo:nil repeats:NO];
    }
    else {
        [backendless.userService logout:^{
            
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:self];
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITextField *nextTextField = [textField.superview viewWithTag:textField.tag + 1];
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)showTabBar {
    [self performSegueWithIdentifier:@"ShowTabBar" sender:nil];
}

- (IBAction)pressedSignIn:(id)sender {
    [self.view endEditing:YES];
    if (self.emailField.text.length > 0 && self.passwordField.text > 0) {
        [backendless.userService setStayLoggedIn:YES];
        NSString *email = self.emailField.text;
        NSString *password = self.passwordField.text;
        [backendless.userService login:email
                              password:password
                              response:^(BackendlessUser *user) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.view endEditing:YES];
                                      self.emailField.text = @"";
                                      self.passwordField.text = @"";
                                  });                                  
                                  [self showTabBar];
                              } error:^(Fault *fault) {
                                  [alertViewController showErrorAlert:fault.message target:self];
                              }];        
    }
    else {
        [alertViewController showErrorAlert:@"Please make sure you've entered your email and password correctly" target:self];
    }
}

- (IBAction)pressedRestorePassword:(id)sender {
    [alertViewController showRestorePasswordAlert:self];
}

- (IBAction)pressedRegister:(id)sender {
    [self performSegueWithIdentifier:@"ShowSignUp" sender:nil];
}

- (IBAction)unwindToSignIn:(UIStoryboardSegue *)segue {
}

@end
