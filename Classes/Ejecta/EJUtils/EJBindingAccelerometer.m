#import "EJBindingAccelerometer.h"

@implementation EJBindingAccelerometer

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60.0)];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	}
	return self;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {	
	EJApp * ejecta = [EJApp instance];
	JSContextRef ctx = ejecta.jsGlobalContext;
	
	JSValueRef params[3]; // accelerationIncludingGravity(x, y, z)
	params[0] = JSValueMakeNumber(ctx, acceleration.x);
	params[1] = JSValueMakeNumber(ctx, acceleration.y);
	params[2] = JSValueMakeNumber(ctx, acceleration.z);
	
	[self triggerEvent:@"devicemotion" argc:3 argv:params];
}

EJ_BIND_EVENT(devicemotion);

@end
