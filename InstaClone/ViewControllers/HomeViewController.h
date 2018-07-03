
#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)loadPosts;
- (void)scrollToTop;

- (IBAction)pressedLogout:(id)sender;
- (IBAction)pressedRefresh:(id)sender;

@end

