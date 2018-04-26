
#import "LikesViewController.h"
#import "LikeCell.h"
#import "PictureHelper.h"
#import "Likee.h"
#import "Backendless.h"

@interface LikesViewController ()

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.post.likes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LikeCell" forIndexPath:indexPath];
    
    Likee *like = [self.post.likes objectAtIndex:indexPath.row];
    [backendless.userService findById:like.ownerId response:^(BackendlessUser *user) {
        cell.nameLabel.text = user.name;
        [pictureHelper setProfilePicture:[user getProperty:@"profilePicture"] forCell:cell];
    } error:^(Fault *fault) {
        
    }];
        
    return cell;
}

@end
