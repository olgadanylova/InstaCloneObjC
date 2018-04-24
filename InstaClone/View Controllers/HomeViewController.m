
#import "HomeViewController.h"
#import "AlertViewController.h"
#import "HomeCell.h"
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

- (void)loadPosts {
    [self.activityIndicator startAnimating];
    [[backendless.data of:[Post class]] find:^(NSArray *postsFound) {
        self->posts = [NSArray arrayWithArray:postsFound];
        [self.activityIndicator stopAnimating];
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
    HomeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    Post *post = [posts objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [self getUserName:post];
    
    
    
    
    [pictureHelper setProfilePicture:post. forCell:<#(UITableViewCell *)#>]
    
    
    /*[self getUserProfilePhoto];
     self.nameLabel.text = [self getUserName];
     [self getPostPhoto];
     self.captionLabel.text = [self getCaption];
     if (self.post.likes) {
     NSString *likesTitle = [NSString stringWithFormat:@"%lu Likes", (unsigned long)[self.post.likes count]];
     [self.likeCountButton setTitle:likesTitle forState:UIControlStateNormal];
     }
     else {
     [self.likeCountButton setTitle:@"0 Likes" forState:UIControlStateNormal];
     }*/
    
    
    return cell;
}

- (void)getUserProfilePhoto:(Post *)post forCell:(HomeCell *)cell {
    [backendless.userService findById:post.ownerId response:^(BackendlessUser *user) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *profilePicture = [user getProperty:@"profilePicture"];
            NSURL *imageURL = [NSURL URLWithString:profilePicture];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.profileImageView.image = [UIImage imageWithData:imageData];
            });
        });
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
    }];
}

- (NSString *)getUserName:(Post *)post {
    if (post.ownerId) {
        BackendlessUser *user = [backendless.userService findById:post.ownerId];
        return user.name;
    }
    return @"";
}

//- (void)getPostPhoto {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSURL *imageURL = [NSURL URLWithString:self.post.photo];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            self.imageView.image = [UIImage imageWithData:imageData];
//        });
//    });
//}

//- (NSString *)getCaption {
//    if (self.post.caption) {
//        return self.post.caption;
//    }
//    return @"";
//}

@end
