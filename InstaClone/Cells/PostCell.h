
#import <UIKit/UIKit.h>
#import "PostViewController.h"
#import "Post.h"
#import "Backendless.h"

@interface PostCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *likeImageView;
@property (strong, nonatomic) IBOutlet UIButton *likeCountButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) PostViewController *postViewController;
@property (nonatomic) BOOL liked;
@property (nonatomic) NSInteger likesCount;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

- (IBAction)pressedEdit:(id)sender;

@end
