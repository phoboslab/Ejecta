#import "EjectaAppDelegate.h"

@implementation EjectaAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[application setIdleTimerDisabled:YES];
	engine = [[EJApp alloc] initWithWindow:window];
	
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[engine pause];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	[engine pause];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	[engine resume];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[engine resume];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[engine pause];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[engine release];
    [super dealloc];
}


@end
