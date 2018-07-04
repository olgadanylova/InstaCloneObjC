
#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UICollectionViewDataSource, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

-(void)getUserPosts;

- (IBAction)pressedRefresh:(id)sender;

@end
