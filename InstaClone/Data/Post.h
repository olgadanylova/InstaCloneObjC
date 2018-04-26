
#import <Foundation/Foundation.h>
#import "Comment.h"
#import "Likee.h"

@interface Post : NSObject

@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSArray<Likee *> *likes;
@property (strong, nonatomic) NSArray<Comment *> *comments;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *ownerId;

@end
