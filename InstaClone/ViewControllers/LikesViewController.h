
#import <UIKit/UIKit.h>
#import "Post.h"

@interface LikesViewController : UITableViewController 

@property (strong, nonatomic) Post *post;

- (IBAction)pressedRefresh:(id)sender;

@end
