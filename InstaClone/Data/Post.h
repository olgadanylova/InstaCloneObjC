
#import <Foundation/Foundation.h>
#import "Comment.h"
#import "Like.h"

@interface Post : NSObject

@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSMutableArray<Like *> *likes;
@property (strong, nonatomic) NSMutableArray<Comment *> *comments;
@property (strong, nonatomic) NSString *ownerId;

@end
