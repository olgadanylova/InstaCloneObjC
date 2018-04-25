
#import "HomeViewController.h"
#import "AlertViewController.h"
#import "PostCell.h"
#import "PictureHelper.h"
#import "Post.h"
#import "Backendless.h"

@interface HomeViewController() {
    NSArray<Post *> *posts;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 571;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self loadPosts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPosts];
}

- (void)loadPosts {
    [[backendless.data of:[Post class]] find:^(NSArray *postsFound) {
        self->posts = [NSArray arrayWithArray:postsFound];
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

- (IBAction)pressedLikesButton:(id)sender {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    Post *post = [posts objectAtIndex:indexPath.row];
    [backendless.userService findById:post.ownerId response:^(BackendlessUser *user) {
        [pictureHelper setPostPhoto:post.photo forCell:cell];
        cell.nameLabel.text = [self getUserName:post];
        [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
        cell.captionLabel.text = post.caption;
        if (post.likes) {
            NSString *likesTitle = [NSString stringWithFormat:@"%lu Likes", (unsigned long)[post.likes count]];
            [cell.likeCountButton setTitle:likesTitle forState:UIControlStateNormal];
        }
        else {
            [cell.likeCountButton setTitle:@"0 Likes" forState:UIControlStateNormal];
        }
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
    }];
    
    return cell;
}

- (NSString *)getUserName:(Post *)post {
    if (post.ownerId) {
        BackendlessUser *user = [backendless.userService findById:post.ownerId];
        return user.name;
    }
    return @"";
}

@end
