
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define pictureHelper [PictureHelper sharedInstance]

@interface PictureHelper : NSObject

+(instancetype)sharedInstance;
-(void)setProfilePicture:(NSString *)profilePicture forCell:(UITableViewCell *)cell;

@end
