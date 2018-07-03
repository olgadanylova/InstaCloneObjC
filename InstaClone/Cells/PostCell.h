
#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "Post.h"
#import "Backendless.h"

@interface PostCell : UITableViewCell<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *likeImageView;
@property (strong, nonatomic) IBOutlet UIButton *likeCountButton;
@property (strong, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) UIViewController *parentVC;
@property (strong, nonatomic) Post *post;
@property (nonatomic) BOOL liked;
@property (nonatomic) NSInteger likesCount;

- (IBAction)pressedEdit:(id)sender;

@end
