
#import "AppDelegate.h"
#import "EJJavaScriptView.h"
@implementation AppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Optionally set the idle timer disabled, this prevents the device from sleep when not being interacted with by touch. ie. games with motion control.
	[application setIdleTimerDisabled:YES];
    self.ejApp = [EJAppViewController instance];
    window.rootViewController = self.ejApp;
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[self.ejApp release];
    [super dealloc];
}


@end
