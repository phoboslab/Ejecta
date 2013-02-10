
#import "AppDelegate.h"
#import "EJJavaScriptView.h"
@implementation AppDelegate

@synthesize ejApp;
@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	// Optionally set the idle timer disabled, this prevents the device from sleep when
	// not being interacted with by touch. ie. games with motion control.
	[application setIdleTimerDisabled:YES];
	
    ejApp = [EJAppViewController instance];
    window.rootViewController = ejApp;
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[ejApp release];
	[window release];
    [super dealloc];
}


@end
