
#import "SignUpViewController.h"
#import "AlertViewController.h"
#import "Backendless.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.userNameField.tag = 0;
    self.emailField.tag = 1;
    self.passwordField.tag = 2;
    
    CGFloat side = self.profileImageView.frame.size.width / 2;
    self.profileImageView.frame = CGRectMake(0, 0, side, side);
    self.profileImageView.layer.cornerRadius = side;
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView)]];
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

- (IBAction)tapImageView {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertViewController showErrorAlert:nil title:@"No device found" message:@"Camera is not available" target:self];
    }
    else {
        [alertViewController showTakePhotoAlert:self];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *imageTaken = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil);
        self.profileImageView.image = imageTaken;
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeImage] && picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        self.profileImageView.image = image;
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)pressedSignUp:(id)sender {
    if (self.userNameField.text.length > 0 && self.emailField.text.length > 0 && self.passwordField.text > 0) {
        BackendlessUser *newUser = [BackendlessUser new];
        newUser.name = self.userNameField.text;
        newUser.email = self.emailField.text;
        newUser.password = self.passwordField.text;
        
        if (self.profileImageView.image != [UIImage imageNamed:@"camera.png"]) {
            NSString *profileImageFileName = [NSString stringWithFormat:@"/InstaCloneProfilePictures/%@", [[NSUUID UUID] UUIDString]];
            NSData *data = UIImagePNGRepresentation(self.profileImageView.image);
            [backendless.file saveFile:profileImageFileName content:data response:^(BackendlessFile *profilePicture) {
                [newUser setProperty:@"profilePicture" object:profilePicture.fileURL];
                [backendless.userService registerUser:newUser response:^(BackendlessUser *user) {
                    [self performSegueWithIdentifier:@"showTabBar" sender:nil];
                } error:^(Fault *fault) {
                    [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
                }];
            } error:^(Fault *fault) {
                [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
            }];
        }
        else {
            [newUser setProperty:@"profilePicture" object:@"InstaCloneProfilePictures/defaultProfilePicture.png"];
            [backendless.userService registerUser:newUser response:^(BackendlessUser *user) {
                [self performSegueWithIdentifier:@"showTabBar" sender:nil];
            } error:^(Fault *fault) {
                [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
            }];
        }
    }
    else {
        [alertViewController showErrorAlert:nil title:@"Invalid user name, email or password" message:@"Please make sure you've entered your name, email and password correctly" target:self];
    }
}

- (IBAction)pressedDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
