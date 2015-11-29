#import <objc/runtime.h>

#import "EJAppViewController.h"
#import "EJJavaScriptView.h"

@implementation EJAppViewController

- (id)initWithScriptAtPath:(NSString *)pathp {
	if( self = [super init] ) {
		path = [pathp retain];
	}
	return self;
}

- (void)dealloc {
	self.view = nil;
	[path release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[(EJJavaScriptView *)self.view clearCaches];
	[super didReceiveMemoryWarning];
}

- (void)loadView {
	CGRect frame = UIScreen.mainScreen.bounds;
	
	EJJavaScriptView *view = [[EJJavaScriptView alloc] initWithFrame:frame];
	self.view = view;
	
	[view loadScriptAtPath:path];
	[view release];
}

@end
