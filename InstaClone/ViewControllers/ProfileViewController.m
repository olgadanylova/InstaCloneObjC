
#import "ProfileViewController.h"
#import "AlertViewController.h"
#import "PostViewController.h"
#import "PhotoCollectionViewCell.h"
#import "ProfileHeaderCollectionReusableView.h"
#import "Post.h"
#import "Backendless.h"
#import "PictureHelper.h"

@interface ProfileViewController() {
    NSInteger totalUsersCount;
    NSArray<Post *> *posts;
    id<IDataStore>postStore;
}
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    postStore = [backendless.data of:[Post class]];
    [self getUserPosts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.delegate = self;
    [self getUserPosts];
}

- (void)getUserPosts {
    DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
    [queryBuilder setWhereClause:[NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId]];
    [postStore find:queryBuilder response:^(NSArray *userPosts) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        self->posts = [userPosts sortedArrayUsingDescriptors:@[sortDescriptor]];
        [[backendless.data of:[BackendlessUser class]] getObjectCount:^(NSNumber *usersCount) {
            self->totalUsersCount = [usersCount integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.collectionView reloadData];
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                } completion:nil];
            });
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.message target:self];
        }];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.message target:self];
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self scrollToTop];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    cell.post = [posts objectAtIndex:indexPath.row];
    [pictureHelper setPostPhoto:cell.post.photo forCell:cell];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ProfileHeaderCollectionReusableView *headerViewCell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileHeaderCollectionReusableView" forIndexPath:indexPath];
    headerViewCell.user = backendless.userService.currentUser;
    headerViewCell.postsCountLabel.text = [NSString stringWithFormat:@"%lu", posts.count];
    if (totalUsersCount > 0) {
        headerViewCell.followingCountLabel.text = [NSString stringWithFormat:@"%li", totalUsersCount - 1];
        headerViewCell.followersCountLabel.text = [NSString stringWithFormat:@"%li", totalUsersCount - 1];
    }
    return headerViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width / 3 - 1, collectionView.frame.size.width / 3 - 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout  minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowPost" sender:[posts objectAtIndex:indexPath.row]];
}

- (void)scrollToTop {
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGPoint point = CGPointMake(0, - statusBarHeight - navBarHeight);
    [self.collectionView setContentOffset:point animated:YES];
}

- (IBAction)pressedRefresh:(id)sender {
    [self getUserPosts];
    [self scrollToTop];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPost"]) {
        PostViewController *postVC = [segue destinationViewController];
        postVC.post = sender;
        postVC.editMode = NO;
        [postVC.tableView reloadData];
    }
}

- (IBAction)unwindToProfile:(UIStoryboardSegue *)segue {
    [self getUserPosts];
}

@end
