
#import "HomeViewController.h"
#import "AlertViewController.h"
#import "LikesViewController.h"
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
        [self performSegueWithIdentifier:@"unwindToSignIn" sender:nil];
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
        cell.post = post;
        [pictureHelper setPostPhoto:post.photo forCell:cell];
        cell.nameLabel.text = [self getUserName:post];
        [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
        cell.captionLabel.text = post.caption;
        if (post.likes) {
            cell.likesCount = [post.likes count];
            NSString *predString = [NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId];
            NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
            if ([[post.likes filteredArrayUsingPredicate:pred] count] > 0) {
                cell.liked = YES;
                cell.likeImageView.image = [UIImage imageNamed:@"likeSelected"];
            }
            NSString *likesTitle = [NSString stringWithFormat:@"%lu Likes", cell.likesCount];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowLikes"]) {
        PostCell *cell = (PostCell *)[sender superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        LikesViewController *likesVC = [segue destinationViewController];       
        likesVC.post = [posts objectAtIndex:indexPath.row];
    }
}

@end
