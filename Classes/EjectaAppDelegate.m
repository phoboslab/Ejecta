#import "EjectaAppDelegate.h"

@implementation EjectaAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application setIdleTimerDisabled:YES];
	app = [[EJApp alloc] initWithWindow:window];
	
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[app pause];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	[app pause];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	[app resume];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[app resume];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[app pause];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[app clearCaches];
}


- (void)dealloc {
	[app release];
    [super dealloc];
}


@end
