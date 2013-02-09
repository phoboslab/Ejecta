#import <objc/runtime.h>

#import "EJAppViewController.h"
#import "EJBindingBase.h"
#import "EJTimer.h"

#import "EJJavaScriptView.h"

@implementation EJAppViewController

static EJAppViewController *_ejectaInstance = NULL;

+ (EJAppViewController *)instance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_ejectaInstance = [[EJAppViewController alloc] init];
	});
	return _ejectaInstance;
}

- (id)init{
	if( self = [super init] ) {
		_landscapeMode = [[[[NSBundle mainBundle] infoDictionary]
			objectForKey:@"UIInterfaceOrientation"] hasPrefix:@"UIInterfaceOrientationLandscape"];
		_ejectaInstance = self;
		[[EJJavaScriptView sharedView] loadDefaultScripts];
	}
	return self;
}

+(id)alloc
{
	@synchronized([EJAppViewController class]){
		NSAssert(_ejectaInstance == nil, @"Attempt to allocate a second instance of singleton EJAppViewController");
		_ejectaInstance = [super alloc];
		return _ejectaInstance;
	}
	return nil;
}

- (void)dealloc {
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	[[EJJavaScriptView sharedView] clearCaches];
}

- (void)loadView
{
	EJJavaScriptView *view = [EJJavaScriptView sharedView];
	self.view = view;
}

- (NSUInteger)supportedInterfaceOrientations {
	if(self.landscapeMode) {
		// Allow Landscape Left and Right
		return UIInterfaceOrientationMaskLandscape;
	}
	else {
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
			// Allow Portrait UpsideDown on iPad
			return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
		}
		else {
			// Only Allow Portrait
			return UIInterfaceOrientationMaskPortrait;
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	// Deprecated in iOS6 - supportedInterfaceOrientations is the new way to do this
	// We just use the mask returned by supportedInterfaceOrientations here to check if
	// this particular orientation is allowed.
	return (self.supportedInterfaceOrientations & (1 << orientation) );
}

@end
