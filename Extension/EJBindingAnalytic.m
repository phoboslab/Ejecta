#import "EJBindingAnalytic.h"

@implementation EJBindingAnalytic

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			appKey = [JSValueToNSString(ctx, argv[0]) retain];
			[MobClick startWithAppkey:AppKey];
		}
		else {
			NSLog(@"Error: Must set appKey");
		}
	}
	return self;
}

EJ_BIND_FUNCTION(load, ctx, argc, argv)
{
	
	
}

@end
