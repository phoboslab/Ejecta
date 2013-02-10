#import <UIKit/UIKit.h>
#import "EJAppViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	EJAppViewController *ejApp;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, strong) EJAppViewController *ejApp;
@end

