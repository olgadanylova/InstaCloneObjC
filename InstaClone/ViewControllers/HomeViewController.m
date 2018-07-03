
#import "HomeViewController.h"
#import "AlertViewController.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "PostViewController.h"
#import "PostCell.h"
#import "PictureHelper.h"
#import "Post.h"
#import "Backendless.h"

@interface HomeViewController() {
    id<IDataStore>postStore;
    NSArray<Post *> *posts;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 600;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    postStore = [backendless.data of:[Post class]];
    [self loadPosts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPosts];
    [self scrollToTop];
    self.tabBarController.delegate = self;
    self.navigationController.tabBarController.tabBar.hidden = NO;
}

- (void)loadPosts {
    [postStore find:^(NSArray *postsFound) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        self->posts = [postsFound sortedArrayUsingDescriptors:@[sortDescriptor]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self scrollToTop];
        });
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    Post *post = [posts objectAtIndex:indexPath.row];
    cell.post = post;
    
    [backendless.userService findById:post.ownerId response:^(BackendlessUser *user) {
        [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.nameLabel.text = user.name;
        });        
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
    [pictureHelper setPostPhoto:post.photo forCell:cell];
    
    [UIView setAnimationsEnabled:NO];
    [cell.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", (unsigned long)[post.likes count]] forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];
    [cell.likeCountButton addTarget:self action:@selector(likesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentsButton addTarget:self action:@selector(commentsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"HH:mm yyyy/MM/dd";
    cell.dateLabel.text = [formatter stringFromDate:post.created];
    
    NSArray *likes = post.likes;
    NSString *predicateString = [NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId];
    if ([likes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateString]].firstObject) {
        cell.liked = YES;
        cell.likeImageView.image = [UIImage imageNamed:@"likeSelected.png"];
    }
    else {
        cell.liked = NO;
        cell.likeImageView.image = [UIImage imageNamed:@"like.png"];
    }
    
    cell.captionLabel.text = post.caption;
    return cell;
}

- (void)likesButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowLikes" sender:sender];
}

- (void)commentsButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowComments" sender:sender];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self scrollToTop];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PostCell *cell = (PostCell *)[[sender superview] superview];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
        [self loadPosts]; 
        
        if ([segue.identifier isEqualToString:@"ShowLikes"]) {
            NSString *currentPost = [self->posts objectAtIndex:indexPath.row].objectId;
            [self->postStore findById:currentPost response:^(Post *post) {
                LikesViewController *likesVC = (LikesViewController *)[segue destinationViewController];
                likesVC.post = post;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [likesVC.tableView reloadData];
                });
            } error:^(Fault *fault) {
                [alertViewController showErrorAlert:fault.message target:self];
            }];
        }
        else if ([segue.identifier isEqualToString:@"ShowComments"]) {
            Post *currentPost = [self->posts objectAtIndex:indexPath.row];
            CommentsViewController *commentsVC = [segue destinationViewController];
            commentsVC.post = currentPost;
            [commentsVC.tableView reloadData];
        }
        else if ([segue.identifier isEqualToString:@"ShowPost"]) {
            Post *currentPost = [self->posts objectAtIndex:indexPath.row];
            PostViewController *postVC = [segue destinationViewController];
            postVC.navigationItem.title = @"Edit post";
            postVC.editing = YES;
            postVC.post = currentPost;
        }
    });
}

- (void)scrollToTop {
    NSIndexPath *top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
    [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)pressedLogout:(id)sender {
    [backendless.userService logout:^{
        [self performSegueWithIdentifier:@"unwindToSignIn" sender:nil];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

- (IBAction)pressedRefresh:(id)sender {
    [self loadPosts];
    [self scrollToTop];
}

- (IBAction)pressedEdit:(id)sender {
    PostCell *postCell = (PostCell *)[[sender superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:postCell];
    Post *post = [posts objectAtIndex:indexPath.row];
    [alertViewController showEditAlert:post target:self];
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
}

@end
