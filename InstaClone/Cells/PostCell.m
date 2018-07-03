
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
    
    postStore = [backendless.data of:[Post class]];
    likeStore = [backendless.data of:[Likee class]];
}

- (void)handleLikeTap {
    __weak PostCell *weakSelf = self;
    __weak id<IDataStore> weakPostStore = postStore;
    if (!self.liked) {
        self.liked = YES;
        self.likeImageView.image = [UIImage imageNamed:@"likeSelected"];
        [likeStore save:[Likee new] response:^(Likee *like) {
            [self->postStore addRelation:@"likes:Like:n"
                                             parentObjectId:self.post.objectId
                                               childObjects:@[like.objectId]
                                                   response:^(NSNumber *relationSet) {
                                                       [weakPostStore findById:weakSelf.post.objectId response:^(Post *post) {
                                                           [UIView setAnimationsEnabled:NO];
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                [weakSelf.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
                                                           });
                                                          
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
        [likeStore findFirst:queryBuilder response:^(Likee *like) {
            [self->likeStore remove:like response:^(NSNumber *removed) {
                [self->postStore findById:self.post.objectId response:^(Post *post) {
                    [UIView setAnimationsEnabled:NO];
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [self.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
                    });                   
                    [UIView setAnimationsEnabled:YES];
                } error:^(Fault *fault) {
                }];    
            } error:^(Fault *fault) {
            }];
        } error:^(Fault *fault) {
        }];
    }
}

- (void)changeLikesButtonTitle {
    [self.likeCountButton setTitle:[NSString stringWithFormat:@"%li Likes", (long)self.likesCount] forState:UIControlStateNormal];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}

@end
