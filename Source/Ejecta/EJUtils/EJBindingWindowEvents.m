#import "EJBindingWindowEvents.h"
#import "EJJavaScriptView.h"

@implementation EJBindingWindowEvents

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	scriptView.windowEventsDelegate = self;
}

- (void)pause {
	[self triggerEvent:@"pagehide" argc:0 argv:NULL];
}

- (void)resume {
	[self triggerEvent:@"pageshow" argc:0 argv:NULL];
}

- (void)resize {
	[self triggerEvent:@"resize" argc:0 argv:NULL];
}

EJ_BIND_EVENT(pagehide);
EJ_BIND_EVENT(pageshow);
EJ_BIND_EVENT(resize);

@end
