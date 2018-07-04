
#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostCaptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (strong, nonatomic) Post *post;

@end
