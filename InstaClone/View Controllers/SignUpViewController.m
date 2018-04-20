
#import "SignUpViewController.h"
#import "AlertViewController.h"
#import "Backendless.h"

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.userNameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.userNameField.tag = 0;
    self.emailField.tag = 1;
    self.passwordField.tag = 2;
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

- (IBAction)pressedSignUp:(id)sender {
    if (self.userNameField.text.length > 0 && self.emailField.text.length > 0 && self.passwordField.text > 0) {
        BackendlessUser *newUser = [BackendlessUser new];
        newUser.name = self.userNameField.text;
        newUser.email = self.emailField.text;
        newUser.password = self.passwordField.text;
        [backendless.userService setStayLoggedIn:YES];
        [backendless.userService registerUser:newUser
                                     response:^(BackendlessUser *user) {
                                         [self performSegueWithIdentifier:@"showTabBar" sender:nil];
                                     } error:^(Fault *fault) {
                                         [alertViewController showErrorAlert:fault.faultCode :nil :fault.message targer:self];
                                     }];
    }
    else {
        [alertViewController showErrorAlert:nil :@"Invalid user name, email or password" :@"Please make sure you've entered your name, email and password correctly" targer:self];
    }
}

- (IBAction)pressedDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
