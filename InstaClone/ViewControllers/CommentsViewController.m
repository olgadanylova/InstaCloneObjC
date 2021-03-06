
#import "CommentsViewController.h"
#import "AlertViewController.h"
#import "CommentCell.h"
#import "PictureHelper.h"
#import "Backendless.h"

@interface CommentsViewController() {
    id<IDataStore>postStore;
    id<IDataStore>commentStore;
    NSArray *comments;
}
@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.commentTextField.delegate = self;
    [self.commentTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    postStore = [backendless.data of:[Post class]];
    commentStore = [backendless.data of:[Comment class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0;
        self.view.frame = f;
    }];
}

- (void)textFieldDidChange {
    if ([self.commentTextField.text length] > 0) {
        [self.sendButton setEnabled:YES];
    }
    else {
        [self.sendButton setEnabled:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.post.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES];
    comments = [self.post.comments sortedArrayUsingDescriptors:@[sortDescriptor]];
    Comment *comment = [comments objectAtIndex:indexPath.row];
    [backendless.userService findById:comment.ownerId response:^(BackendlessUser *user) {
        [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
        cell.nameLabel.text = user.name;
        cell.commentLabel.text = comment.text;
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm yyyy/MM/dd";
        cell.dateLabel.text = [formatter stringFromDate:comment.created];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment *comment = [comments objectAtIndex:indexPath.row];
        if ([comment.ownerId isEqualToString:backendless.userService.currentUser.objectId] ||
            [self.post.ownerId isEqualToString:backendless.userService.currentUser.objectId]) {
            [commentStore remove:comment response:^(NSNumber *removed) {
                [self reloadTableData];
            } error:^(Fault *fault) {
                [alertViewController showErrorAlert:fault.message target:self];
            }];
        }
        else {
            [alertViewController showErrorAlert:@"Only the owner of this post or the person who left this comment delete it" target:self];
        }
    }
}

- (void)reloadTableData {
    [postStore findById:self.post.objectId response:^(Post *post) {
        self.post = post;
        [self.tableView reloadData];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

- (IBAction)pressedSend:(id)sender {
    __weak CommentsViewController *weakSelf = self;
    Comment *newComment = [Comment new];
    newComment.text = self.commentTextField.text;
    [commentStore save:newComment response:^(Comment *comment) {
        [self->postStore addRelation:@"comments:Comment:n" parentObjectId:self.post.objectId childObjects:@[comment.objectId] response:^(NSNumber *relationSet) {
            weakSelf.commentTextField.text = @"";
            [weakSelf.sendButton setEnabled:NO];
            [weakSelf.view endEditing:YES];
            [weakSelf reloadTableData];
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:weakSelf];
        }];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

- (IBAction)pressedRefresh:(id)sender {
    [self reloadTableData];
}

@end
