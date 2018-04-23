
#import "HomeViewController.h"
#import "AlertViewController.h"
#import "HomeTableViewCell.h"
#import "Backendless.h"
#import "Post.h"

@interface HomeViewController() {
    NSArray<Post *> *posts;
    NSArray<BackendlessUser *> *users;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 571;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self loadPosts];
}

- (void)loadPosts {
    [self.activityIndicatorView startAnimating];
    [[backendless.data of:[Post class]] find:^(NSArray *postsFound) {
        self->posts = [NSArray arrayWithArray:postsFound];
        [self.activityIndicatorView stopAnimating];
        [self.tableView reloadData];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
    }];
}

- (IBAction)pressedLogout:(id)sender {
    [backendless.userService logout:^{
        [self performSegueWithIdentifier:@"unwindToSignInVC" sender:nil];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    cell.post = [posts objectAtIndex:indexPath.row];
    cell.user = [users objectAtIndex:indexPath.row];
    cell.homeVC = self;
    return cell;
}

@end
