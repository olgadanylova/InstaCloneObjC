
#import <UIKit/UIKit.h>
#import "Post.h"

@interface CommentsViewController : UIViewController <UITabBarDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) Post *post;

- (IBAction)pressedSend:(id)sender;
- (IBAction)pressedRefresh:(id)sender;

@end
