
#import "PictureHelper.h"
#import "HomeCell.h"

@implementation PictureHelper

+(instancetype)sharedInstance {
    static PictureHelper *sharedHelper;
    @synchronized(self) {
        if (!sharedHelper)
            sharedHelper = [PictureHelper new];
    }
    return sharedHelper;
}

- (void)setProfilePicture:(NSString *)profilePicture forCell:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[HomeCell class]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicture]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                ((HomeCell *)cell).profileImageView.image = image;
            });
        });
    }
}

@end
