
#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application setIdleTimerDisabled:YES];
    
    app = [[EJAppViewController alloc] init];
    window.rootViewController = app;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[app release];
    [super dealloc];
}


@end
