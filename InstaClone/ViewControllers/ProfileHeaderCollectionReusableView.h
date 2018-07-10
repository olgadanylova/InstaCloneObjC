
#import <UIKit/UIKit.h>
#import "Backendless.h"

@interface ProfileHeaderCollectionReusableView : UICollectionReusableView <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersCountLabel;

@property (strong, nonatomic) BackendlessUser *user;

@end
