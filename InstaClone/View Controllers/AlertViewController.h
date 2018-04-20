
#import <UIKit/UIKit.h>

#define alertViewController [AlertViewController sharedInstance]

@interface AlertViewController : UIViewController

+ (instancetype)sharedInstance;
- (void)showErrorAlert:(NSString *)code :(NSString *)title :(NSString *)message targer:(id)target;

@end
