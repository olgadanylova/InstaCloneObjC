
#import "ProfileViewController.h"
#import "AlertViewController.h"
#import "PhotoCollectionViewCell.h"
#import "ProfileHeaderCollectionReusableView.h"
#import "Post.h"
#import "Backendless.h"

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

- (void)getUserPosts {
    DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
    [queryBuilder setWhereClause:[NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId]];
    [postStore find:queryBuilder response:^(NSArray *userPosts) {
        self->posts = userPosts;
        [[backendless.data of:[BackendlessUser class]] getObjectCount:^(NSNumber *usersCount) {
            self->totalUsersCount = [usersCount integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });            
        } error:^(Fault *fault) {
            [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
        }];
    } error:^(Fault *fault) {
        [alertViewController showErrorAlert:fault.faultCode title:nil message:fault.message target:self];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    cell.post = [posts objectAtIndex:indexPath.row];
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

@end
