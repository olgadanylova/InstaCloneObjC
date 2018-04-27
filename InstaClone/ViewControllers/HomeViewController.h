
#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)pressedLogout:(id)sender;
- (IBAction)pressedRefresh:(id)sender;

@end

