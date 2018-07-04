
#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostViewController : UITableViewController<UITextViewDelegate>

@property (nonatomic) BOOL editMode;
@property (strong, nonatomic) Post *post;

- (IBAction)pressedSave:(id)sender;
- (IBAction)pressedCancel:(id)sender;

@end
