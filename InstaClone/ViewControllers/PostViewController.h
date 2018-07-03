
#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostViewController : UITableViewController

@property (nonatomic) BOOL edit;
@property (strong, nonatomic) Post *post;

@end
