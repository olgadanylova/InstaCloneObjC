
#import "PictureHelper.h"
#import "PostCell.h"

@implementation PictureHelper

+ (instancetype)sharedInstance {
    static PictureHelper *sharedHelper;
    @synchronized(self) {
        if (!sharedHelper)
            sharedHelper = [PictureHelper new];
    }
    return sharedHelper;
}

- (void)setProfilePicture:(NSString *)profilePicture forCell:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[PostCell class]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicture]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                ((PostCell *)cell).profileImageView.image = image;
            });
        });
    }
}

- (void)setPostPhoto:(NSString *)photo forCell:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[PostCell class]]) {
        ((PostCell *)cell).activityIndicator.hidden = NO;
        [((PostCell *)cell).activityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                ((PostCell *)cell).postImageView.image = image;
                ((PostCell *)cell).activityIndicator.hidden = YES;
                [((PostCell *)cell).activityIndicator stopAnimating];
            });
        });
    }
}

-(UIImage *)scaleAndRotateImage:(UIImage *)image {
    image = [self scaleImage:image];
    image = [self rotateImage:image];
    return image;
}

- (UIImage *)scaleImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;

    if (imageWidth >= imageHeight) {
        CGFloat coef = imageWidth / 512;
        imageWidth = 512;
        imageHeight = imageHeight / coef;
    }
    else {
        CGFloat coef = imageHeight / 512;
        imageHeight = 512;
        imageWidth = imageWidth / coef;
    }

    CGSize newSize = CGSizeMake(imageWidth, imageHeight);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)rotateImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
