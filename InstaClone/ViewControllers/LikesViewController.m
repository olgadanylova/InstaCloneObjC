
#import "LikesViewController.h"
#import "AlertViewController.h"
#import "LikeCell.h"
#import "PictureHelper.h"
#import "Likee.h"
#import "Backendless.h"

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.post.likes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LikeCell" forIndexPath:indexPath];
    Likee *like = [self.post.likes objectAtIndex:indexPath.row];
    [backendless.userService findById:like.ownerId response:^(BackendlessUser *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ liked your photo", user.name];
        });
        [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
    return cell;
}

- (IBAction)pressedRefresh:(id)sender {
    [[backendless.data of:[Post class]] findById:self.post.objectId response:^(Post *post) {
        self.post = post;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

@end
