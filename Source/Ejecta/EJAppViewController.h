// Well, this is actually the place where most of the stuff from the
// EJJavaScriptView should happen, if we'd follow the Model-View-Controller
// (MVC) methodology.

// Since the EJJavaScriptView is so tightly coupled to the JS execution and run
// loop, the View Controller here is mostly an empty shell that just
// instantiates a EJJavaScriptView, but does little else.

#import <Foundation/Foundation.h>

@interface EJAppViewController : UIViewController {
	NSString *path;
}

- (id)initWithScriptAtPath:(NSString *)pathp;

@end
