
#import "EditProfileViewController.h"
#import "AlertViewController.h"
#import "PictureHelper.h"
#import "Backendless.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface EditProfileViewController() {
    BackendlessUser *currentUser;
    BOOL profileImageChanged;
}
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameField.delegate = self;
    CGFloat side = self.profileImageView.frame.size.width / 2;
    self.profileImageView.frame = CGRectMake(0, 0, side, side);
    self.profileImageView.layer.cornerRadius = side;
    self.profileImageView.clipsToBounds = YES;
    self.activityIndicator.hidden = YES;
    [self.profileImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView)]];
    currentUser = backendless.userService.currentUser;
    profileImageChanged = NO;
    [pictureHelper setProfilePicture:[currentUser getProperty:@"profilePicture"]  forImageView:self.profileImageView];
    self.userNameField.text = self->currentUser.name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)tapImageView {
    [alertViewController showTakePhotoAlert:self];
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
    profileImageChanged = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)pressedCancel:(id)sender {
    
}

- (IBAction)pressedRestorePassword:(id)sender {
    [alertViewController showRestorePasswordAlert:self];
}

- (IBAction)pressedSave:(id)sender {
    [self.view endEditing:YES];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    if (![currentUser.name isEqualToString:self.userNameField.text]) {
        currentUser.name = self.userNameField.text;
    }
    if (profileImageChanged) {
        NSString *profilePicture = [currentUser getProperty:@"profilePicture"];
        NSRange range = [profilePicture rangeOfString:@"InstaCloneProfilePictures"];
        profilePicture = [profilePicture substringFromIndex:range.location];
        [backendless.file remove:profilePicture response:^{
            [pictureHelper removeImageFromUserDefaults:profilePicture];
            NSString *profileImageFileName = [NSString stringWithFormat:@"/InstaCloneProfilePictures/%@.png", [[NSUUID UUID] UUIDString]];
            UIImage *image = [pictureHelper scaleAndRotateImage:self.profileImageView.image];
            NSData *data = UIImagePNGRepresentation(image);
            [pictureHelper saveImageToUserDefaults:image withKey:profileImageFileName];
            [backendless.file uploadFile:profileImageFileName content:data response:^(BackendlessFile *profilePicture) {
                [self->currentUser setProperty:@"profilePicture" object:profilePicture.fileURL];
                [[backendless.data ofTable:@"Users"] save:self->currentUser response:^(BackendlessUser *updatedUser) {
                    [alertViewController showUpdateCompleteAlert:self];
                } error:^(Fault *fault) {
                    [alertViewController showErrorAlert:fault.message target:self];
                }];
            } error:^(Fault *fault) {
                [alertViewController showErrorAlert:fault.message target:self];
            }];
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:self];
        }];
    }
    else {
        [[backendless.data ofTable:@"Users"] save:currentUser response:^(BackendlessUser *updatedUser) {
            [alertViewController showUpdateCompleteAlert:self];
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:self];
        }];
    }   
}

@end
