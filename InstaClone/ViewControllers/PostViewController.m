
#import "PostViewController.h"
#import "AlertViewController.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "PictureHelper.h"
#import "PostCell.h"
#import "PostCaptionCell.h"
#import "Backendless.h"

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    if (!self.editMode) {
        [self.navigationItem setHidesBackButton:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.post) {
        if (section == 0 || section == 2) {
            return 1;
        }
        else if (section == 1) {
            if (self.editMode) {
                return 0;
            }
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostPhotoCell" forIndexPath:indexPath];
        cell.post = self.post;
        cell.postViewController = self;
        [backendless.userService findById:self.post.ownerId response:^(BackendlessUser *user) {
            [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.nameLabel.text = user.name;
            });
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:self];
        }];
        [pictureHelper setPostPhoto:self.post.photo forCell:cell];
        return cell;
    }
    else if (indexPath.section == 1) {
        PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostLikesAndCommentsCell" forIndexPath:indexPath];
        cell.post = self.post;
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
        return cell;
    }
    else if (indexPath.section == 2) {
        PostCaptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCaptionCell" forIndexPath:indexPath];
        cell.captionTextView.delegate = self;
        cell.captionTextView.text = self.post.caption;
        if(self.editMode) {
            cell.captionTextView.editable = YES;
        }
        else {
            cell.captionTextView.editable = NO;
        }
        return cell;
    }
    return nil;
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

- (void)scrollToTop {
    NSIndexPath *top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
    [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)pressedCancel:(id)sender {
    self.editMode = NO;
    [self.tableView reloadData];
    self.navigationItem.title = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
    [self scrollToTop];
}

- (IBAction)pressedSave:(id)sender {
    PostCaptionCell *cell = (PostCaptionCell *)[(UITableView *)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    self.post.caption = cell.captionTextView.text;
    [[backendless.data of:[Post class]] save:self.post response:^(Post *editedPost) {
        self.editMode = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.navigationItem.title = nil;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.hidesBackButton = NO;
            [self scrollToTop];
        });        
    } error:^(Fault * fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    [UIView setAnimationsEnabled:NO];
    [textView sizeToFit];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

@end
