#import "EJBindingWindowEvents.h"
#import "EJJavaScriptView.h"

@implementation EJBindingWindowEvents

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	scriptView.windowEventsDelegate = self;
}

- (void)pause {
	[self triggerEvent:@"pagehide"];
}

- (void)resume {
	[self triggerEvent:@"pageshow"];
}

- (void)resize {
	[self triggerEvent:@"resize"];
}

- (void)unload {
	[self triggerEvent:@"unload"];
}

EJ_BIND_EVENT(pagehide);
EJ_BIND_EVENT(pageshow);
EJ_BIND_EVENT(resize);
EJ_BIND_EVENT(unload);
EJ_BIND_EVENT(load);

@end
