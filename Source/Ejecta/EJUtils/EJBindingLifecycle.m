#import "EJBindingLifecycle.h"

@implementation EJBindingLifecycle

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		[EJApp instance].lifecycleDelegate = self;
	}
	return self;
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
