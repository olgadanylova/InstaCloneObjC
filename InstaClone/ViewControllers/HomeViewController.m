
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

- (IBAction)pressedRefresh:(id)sender {
    [self loadPosts];
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
        
        // если среди post.likes есть like.ownerId = currentUser.objectId, то liked = yes;
        NSArray *likes = post.likes;
        NSString *predString = [NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId];
        NSPredicate *pred = [NSPredicate predicateWithFormat:predString];
        if ([likes filteredArrayUsingPredicate:pred].firstObject) {
            cell.liked = YES;
            cell.likeImageView.image = [UIImage imageNamed:@"likeSelected.png"];
        }
        else {
            cell.liked = NO;
            cell.likeImageView.image = [UIImage imageNamed:@"like.png"];
        }
        [UIView setAnimationsEnabled:NO];
        [cell.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        [cell.likeCountButton addTarget:self action:@selector(likesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
    }];
    
    return cell;
}

-(void)likesButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowLikes" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowLikes"]) {
        PostCell *cell = (PostCell *)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
        
        [self loadPosts];
        NSString *currentPost = [posts objectAtIndex:indexPath.row].objectId;
        [[backendless.data of:[Post class]] findById:currentPost response:^(Post *post) {
            LikesViewController *likesVC = (LikesViewController *)[segue destinationViewController];
            likesVC.post = post;
            [likesVC.tableView reloadData];
        } error:^(Fault *fault) {
            
        }];
        
    }
}

- (NSString *)getUserName:(Post *)post {
    if (post.ownerId) {
        BackendlessUser *user = [backendless.userService findById:post.ownerId];
        return user.name;
    }
    return @"";
}

@end
