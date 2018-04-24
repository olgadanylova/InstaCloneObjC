
#import "CameraViewController.h"
#import "AlertViewController.h"
#import "ColorHelper.h"
#import "Post.h"
#import "Backendless.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define SHARE @"Share"
#define TAKE_PHOTO @"Take a photo"

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDefaultView];
    self.captionTextView.delegate = self;
    self.captionTextView.tag = 0;
    
    // change activity indicator size
    CGFloat side = self.view.frame.size.width / 10;
    self.activityIndicator.frame = CGRectMake(0, 0, side, side);
}

- (void)setDefaultView {
    self.activityIndicator.hidden = YES;
    self.photoImageView.userInteractionEnabled = NO;
    self.photoImageView.hidden = YES;
    self.captionTextView.userInteractionEnabled = NO;
    self.captionTextView.hidden = YES;
    self.clearButton.enabled = NO;
    [self.clearButton setTintColor:[UIColor clearColor]];
    [self.shareButton setTitle:TAKE_PHOTO forState:UIControlStateNormal];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photoImageView.userInteractionEnabled = YES;
    self.photoImageView.hidden = NO;
    self.captionTextView.userInteractionEnabled = YES;
    self.captionTextView.hidden = NO;
    self.clearButton.enabled = YES;
    [self.clearButton setTintColor:[colorHelper getColorFromHex:@"2C3E50" withAlpha:1]];
    [self.shareButton setTitle:SHARE forState:UIControlStateNormal];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *imageTaken = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil);
        self.photoImageView.image = imageTaken;
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeImage] && picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        self.photoImageView.image = image;
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)pressedShare:(id)sender {
    if ([self.shareButton.titleLabel.text isEqualToString:TAKE_PHOTO]) {
        [alertViewController showTakePhotoAlert:self];
    }
    else {
        NSString *photoFileName = [NSString stringWithFormat:@"/InstaClonePhotos/%@", [[NSUUID UUID] UUIDString]];
        NSData *data = UIImagePNGRepresentation(self.photoImageView.image);
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [backendless.file saveFile:photoFileName content:data response:^(BackendlessFile *photo) {
            Post *newPost = [Post new];
            newPost.photo = photo.fileURL;
            newPost.caption = self.captionTextView.text;            
            id<IDataStore>postStore = [backendless.data of:[Post class]];
            [postStore save:newPost response:^(Post *post) {
                [self.activityIndicator stopAnimating];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setDefaultView];
                });
            } error:^(Fault *fault) {
                [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
            }];
            
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
        }];
    }
}

- (IBAction)pressedClear:(id)sender {
    [self setDefaultView];
}

@end