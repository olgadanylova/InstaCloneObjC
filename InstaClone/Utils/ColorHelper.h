
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define colorHelper [ColorHelper sharedInstance]

@interface ColorHelper : NSObject

+(instancetype)sharedInstance;
-(UIColor *)getColorFromHex:(NSString *)hexColor withAlpha:(CGFloat)alpha;

@end
