
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
    __weak PostCell *weakSelf = self;
    if (!self.liked) {
        self.liked = YES;        
        self.likeImageView.image = [UIImage imageNamed:@"likeSelected"];
        self.likesCount++;
        [weakSelf changeLikesButtonTitle];
        
        Likee *like = [Likee new];
        [likeStore save:like response:^(Likee *savedLike) {
            [self->postStore addRelation:@"likes" parentObjectId:self.post.objectId childObjects:@[savedLike.objectId] response:^(NSNumber *relationSet) {
            } error:^(Fault *fault) {
            }];
        } error:^(Fault *fault) {
        }];
    }
    else {
        self.likesCount--;
        [self changeLikesButtonTitle];
        self.liked = NO;
        self.likeImageView.image = [UIImage imageNamed:@"like"];
        DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
        [queryBuilder setWhereClause:[NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId]];
        [likeStore findFirst:queryBuilder response:^(Likee *like) {
                [self->likeStore remove:like response:^(NSNumber *removedLike) {
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
         
         - (IBAction)pressedLikes:(id)sender {
             if ([self.post.likes count] > 0) {
                 [(HomeViewController *)self.inputViewController performSegueWithIdentifier:@"ShowLikes" sender:nil];
             }
         }
         
         @end
