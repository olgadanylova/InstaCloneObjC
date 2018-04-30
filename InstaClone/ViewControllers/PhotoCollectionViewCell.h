
#import <UIKit/UIKit.h>
#import "Post.h"

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) Post *post;

@end
