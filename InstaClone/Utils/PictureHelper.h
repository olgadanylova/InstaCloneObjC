
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define pictureHelper [PictureHelper sharedInstance]

@interface PictureHelper : NSObject

+ (instancetype)sharedInstance;
- (void)setProfilePicture:(NSString *)profilePicture forCell:(UITableViewCell *)cell;
- (void)setProfilePicture:(NSString *)profilePicture forHeader:(UICollectionReusableView *)header;
- (void)setProfilePicture:(NSString *)profilePicture forImageView:(UIImageView *)imageView;
- (void)setPostPhoto:(NSString *)photo forCell:(id)cell;
- (UIImage *)scaleAndRotateImage:(UIImage *)image;
- (void)saveImageToUserDefaults:(UIImage *)image withKey:(NSString *)key;
- (void)removeImageFromUserDefaults:(NSString *)key;
- (UIImage *)getImageFromUserDefaults:(NSString *)key;

@end
