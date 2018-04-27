
#import "PostCell.h"
#import "AlertViewController.h"
#import "Likee.h"
#import "Backendless.h"

#define LIKE @"like"
#define LIKE_SELECTED @"likeSelected"

@interface PostCell() {
    id<IDataStore>postStore;
    id<IDataStore>likeStore;
}
@end

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.activityIndicator.hidden = YES;
    
    UITapGestureRecognizer *likeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTap)];
    [self.likeImageView addGestureRecognizer:likeTapGesture];
    self.likeImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *commentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentTap)];
    [self.commentImageView addGestureRecognizer:commentTapGesture];
    self.commentImageView.userInteractionEnabled = YES;
    
    postStore = [backendless.data of:[Post class]];
    likeStore = [backendless.data of:[Likee class]];
}

- (void)handleLikeTap {
    if (!self.liked) {
        self.liked = YES;
        self.likeImageView.image = [UIImage imageNamed:@"likeSelected"];
        
        [[backendless.data of:[Likee class]] save:[Likee new] response:^(Likee *like) {
            [[backendless.data of:[Post class]] addRelation:@"likes:Like:n"
                                             parentObjectId:self.post.objectId
                                               childObjects:@[like.objectId]
                                                   response:^(NSNumber *relationSet) {
                                                       [[backendless.data of:[Post class]] findById:self.post.objectId response:^(Post *post) {
                                                           [UIView setAnimationsEnabled:NO];
                                                           [self.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
                                                           [UIView setAnimationsEnabled:YES];
                                                       } error:^(Fault *fault) {
                                                           
                                                       }];
                                                   } error:^(Fault *fault) {
                                                       
                                                   }];
        } error:^(Fault *fault) {
            
        }];
    }
    else {
        self.liked = NO;
        self.likeImageView.image = [UIImage imageNamed:@"like"];
        
        DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
        [queryBuilder setWhereClause:[NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId]];
        id<IDataStore>likeStore = [backendless.data of:[Likee class]];
        [likeStore findFirst:queryBuilder response:^(Likee *like) {
            [likeStore remove:like response:^(NSNumber *removed) {
                [[backendless.data of:[Post class]] findById:self.post.objectId response:^(Post *post) {
                    [UIView setAnimationsEnabled:NO];
                    [self.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
                    [UIView setAnimationsEnabled:YES];
                    
                } error:^(Fault *fault) {
                    
                }];    
            } error:^(Fault *fault) {
                
            }];
        } error:^(Fault *fault) {
            
        }];
    }
}

- (void)handleCommentTap {
    // переходим на view с комментами
}

-(void)changeLikesButtonTitle {
    [self.likeCountButton setTitle:[NSString stringWithFormat:@"%li Likes", (long)self.likesCount] forState:UIControlStateNormal];
}

@end
