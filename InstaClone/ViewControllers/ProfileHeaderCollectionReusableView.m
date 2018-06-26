
#import "ProfileHeaderCollectionReusableView.h"
#import "AlertViewController.h"
#import "PictureHelper.h"
#import "Backendless.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation ProfileHeaderCollectionReusableView

@synthesize user = _user;

- (void)setUser:(BackendlessUser *)user {
   _user = user;
    [self updateView];
}

- (void)updateView {
    self.nameLabel.text = _user.name;
    [pictureHelper setProfilePicture:[_user getProperty:@"profilePicture"] forHeader:self];
}

- (IBAction)pressedEditProfile:(id)sender {
}

@end
