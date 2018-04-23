
#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)pressedLogout:(id)sender;

@end
