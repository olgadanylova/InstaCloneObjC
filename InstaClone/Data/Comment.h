
#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *ownerId;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSString *text;

@end
