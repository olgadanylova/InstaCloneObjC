
#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostViewController : UITableViewController<UITextViewDelegate>

@property (strong, nonatomic) Post *post;
@property (nonatomic) BOOL editMode;

- (IBAction)pressedSave:(id)sender;
- (IBAction)pressedCancel:(id)sender;

@end
