
#import "PostViewController.h"
#import "AlertViewController.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "PictureHelper.h"
#import "PostCell.h"
#import "Backendless.h"

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    [self configureCellIfEdit:cell];
    if (self.post) {
        cell.post = self.post;
        [backendless.userService findById:self.post.ownerId response:^(BackendlessUser *user) {
            [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.nameLabel.text = user.name;
            });
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:self];
        }];
        [pictureHelper setPostPhoto:self.post.photo forCell:cell];
        
        [UIView setAnimationsEnabled:NO];
        [cell.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", (unsigned long)[self.post.likes count]] forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        [cell.likeCountButton addTarget:self action:@selector(likesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentsButton addTarget:self action:@selector(commentsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm yyyy/MM/dd";
        cell.dateLabel.text = [formatter stringFromDate:self.post.created];
        
        NSArray *likes = self.post.likes;
        NSString *predicateString = [NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId];
        if ([likes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateString]].firstObject) {
            cell.liked = YES;
            cell.likeImageView.image = [UIImage imageNamed:@"likeSelected.png"];
        }
        else {
            cell.liked = NO;
            cell.likeImageView.image = [UIImage imageNamed:@"like.png"];
        }
        
        cell.captionTextView.text = self.post.caption;
    } 
    return cell;
}

- (void)configureCellIfEdit:(PostCell *)cell {
    if (self.edit) {
        cell.editButton.enabled = NO;
        cell.editButton.hidden = YES;
        cell.likeImageView.userInteractionEnabled = NO;
        cell.likeImageView.hidden = YES;
        cell.commentsButton.enabled = NO;
        cell.commentsButton.hidden = YES;
        cell.likeCountButton.enabled = NO;
        cell.likeCountButton.hidden = YES;
        [cell.captionTextView becomeFirstResponder];
    }
}

- (void)likesButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowLikes" sender:sender];
}

- (void)commentsButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowComments" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowLikes"]) {
        LikesViewController *likesVC = (LikesViewController *)[segue destinationViewController];
        likesVC.post = self.post;
        dispatch_async(dispatch_get_main_queue(), ^{
            [likesVC.tableView reloadData];
        });
    }
    else if ([segue.identifier isEqualToString:@"ShowComments"]) {
        CommentsViewController *commentsVC = [segue destinationViewController];
        commentsVC.post = self.post;
        [commentsVC.tableView reloadData];
    }
}

@end
