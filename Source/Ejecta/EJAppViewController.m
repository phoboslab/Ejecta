#import <objc/runtime.h>

#import "EJAppViewController.h"
#import "EJJavaScriptView.h"

@implementation EJAppViewController

- (id)init{
	if( self = [super init] ) {
		landscapeMode = [[[NSBundle mainBundle] infoDictionary][@"UIInterfaceOrientation"]
			hasPrefix:@"UIInterfaceOrientationLandscape"];
	}
	return self;
}

- (void)dealloc {
	self.view = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[(EJJavaScriptView *)self.view clearCaches];
}

- (void)loadView {
	CGRect frame = UIScreen.mainScreen.bounds;
	if( landscapeMode ) {
		frame.size = CGSizeMake(frame.size.height, frame.size.width);
	}
	
	EJJavaScriptView *view = [[EJJavaScriptView alloc] initWithFrame:frame];
	self.view = view;
	
	[view loadScriptAtPath:@"index.js"];
	[view release];
}

- (NSUInteger)supportedInterfaceOrientations {
	if( landscapeMode ) {
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
	return ( self.supportedInterfaceOrientations & (1 << orientation) );
}

@end
