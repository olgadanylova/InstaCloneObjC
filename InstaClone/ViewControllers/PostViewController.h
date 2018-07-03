
#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;

@property (nonatomic) BOOL editing;
@property (strong, nonatomic) Post *post;

@end
