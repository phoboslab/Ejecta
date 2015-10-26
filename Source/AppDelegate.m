
#import "AppDelegate.h"
#import "EJJavaScriptView.h"
@implementation AppDelegate
@synthesize window;


#define EJECTA_SYSTEM_VERSION_LESS_THAN(v) \
([UIDevice.currentDevice.systemVersion compare:v options:NSNumericSearch] == NSOrderedAscending)


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	// Optionally set the idle timer disabled, this prevents the device from sleep when
	// not being interacted with by touch. ie. games with motion control.
	application.idleTimerDisabled = YES;

	window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	[self loadViewControllerWithScriptAtPath:@"index.js"];
	
    [window makeKeyAndVisible];
    return YES;
}

- (void)loadViewControllerWithScriptAtPath:(NSString *)path {
	// Release any previous ViewController
	window.rootViewController = nil;
	
	EJAppViewController *vc = [[EJAppViewController alloc] initWithScriptAtPath:path];
	window.rootViewController = vc;
	[vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	window.rootViewController = nil;
	[window release];
    [super dealloc];
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self setApplicationIconBadgeNumber:0];
}


- (BOOL)checkNotificationType:(UIUserNotificationType)type {
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    return (currentSettings.types & type);
}


- (void)setApplicationIconBadgeNumber:(NSInteger)badgeNumber {
    UIApplication *application = [UIApplication sharedApplication];
    

    if(EJECTA_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        application.applicationIconBadgeNumber = badgeNumber;
    } else {
        if ([self checkNotificationType:UIUserNotificationTypeBadge]) {
//            NSLog(@"badge number changed to %d", badgeNumber);
            application.applicationIconBadgeNumber = badgeNumber;
        } else {
//            NSLog(@"access denied for UIUserNotificationTypeBadge");
        }

    }

}

@end
