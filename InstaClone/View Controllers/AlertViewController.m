
#import "AlertViewController.h"

@implementation AlertViewController

+ (instancetype)sharedInstance {
    static AlertViewController *sharedAlert;
    @synchronized(self) {
        if (!sharedAlert)
            sharedAlert = [AlertViewController new];
    }
    return sharedAlert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)showErrorAlert:(NSString *)code :(NSString *)title :(NSString *)message targer:(UIViewController *)target {
    NSString *titleText = @"Error";
    if (code) {
        titleText = [NSString stringWithFormat:@"Error %@", code];
    }
    else if (title) {
        titleText = title;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleText
                                                                   message:message                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissButton = [UIAlertAction actionWithTitle:@"Dismiss"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:dismissButton];
    [target presentViewController:alert animated:YES completion:nil];
}

@end
