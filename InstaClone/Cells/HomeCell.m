
#import "HomeCell.h"
#import "AlertViewController.h"

@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *commentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentImageViewTap)];
    [self.commentImageView addGestureRecognizer:commentTapGesture];
    self.commentImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *likeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentImageViewTap)];
    [self.likeImageView addGestureRecognizer:likeTapGesture];
    self.likeImageView.userInteractionEnabled = YES;
}

- (void)handleCommentImageViewTap {
    // переходим на view с комментами
}

- (void)handleLikeTap {
    // переходим на view с лайками
}

@end
