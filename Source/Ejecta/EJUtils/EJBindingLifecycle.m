#import "EJBindingLifecycle.h"
#import "EJJavaScriptView.h"

@implementation EJBindingLifecycle

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	scriptView.lifecycleDelegate = self;
}

- (void)pause {
	[self triggerEvent:@"pagehide" argc:0 argv:NULL];
}

- (void)resume {
	[self triggerEvent:@"pageshow" argc:0 argv:NULL];
}

EJ_BIND_EVENT(pagehide);
EJ_BIND_EVENT(pageshow);

@end
