
#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "Post.h"
#import "Backendless.h"

@interface HomeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UIImageView *likeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *commentImageView;
@property (strong, nonatomic) IBOutlet UIButton *likeCountButton;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;

@property (strong, nonatomic) NSString *profilePhoto;

@end
