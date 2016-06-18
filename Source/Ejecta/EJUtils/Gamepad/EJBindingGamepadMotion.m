#import "EJBindingGamepadMotion.h"

@implementation EJBindingGamepadMotion

static id sharedInstance = nil;


+ (id)sharedInstance {
    return sharedInstance;
}

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
    if (self = [super initWithContext:ctx argc:argc argv:argv]) {

    }
    sharedInstance = self;
    return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
    [super createWithJSObject:obj scriptView:view];
    interval = 1.0f/60.0f;
    motionValid = false;
}


static const float g = 9.80665;


- (void)setGamepadMotion:(GCMotion *)motion {

    motionValid = YES;
    
    JSContextRef ctx = scriptView.jsGlobalContext;
    
    // accelerationIncludingGravity {x, y, z}
    params[0] = JSValueMakeNumber(ctx, (motion.userAcceleration.x + motion.gravity.x) * g);
    params[1] = JSValueMakeNumber(ctx, (motion.userAcceleration.y + motion.gravity.y) * g);
    params[2] = JSValueMakeNumber(ctx, (motion.userAcceleration.z + motion.gravity.z) * g);
    
    // acceleration {x, y, z}
    params[3] = JSValueMakeNumber(ctx, motion.userAcceleration.x * g);
    params[4] = JSValueMakeNumber(ctx, motion.userAcceleration.y * g);
    params[5] = JSValueMakeNumber(ctx, motion.userAcceleration.z * g);
    
#if !TARGET_OS_TV
    float radToDeg = (180/M_PI);
    
    // rotation rate {alpha, beta, gamma}
    params[6] = JSValueMakeNumber(ctx, motion.rotationRate.x * radToDeg);
    params[7] = JSValueMakeNumber(ctx, motion.rotationRate.y * radToDeg);
    params[8] = JSValueMakeNumber(ctx, motion.rotationRate.z * radToDeg);
    
    // orientation {alpha, beta, gamma}
    params[9] = JSValueMakeNumber(ctx, motion.attitude.x * radToDeg);
    params[10] = JSValueMakeNumber(ctx, motion.attitude.y * radToDeg);
    params[11] = JSValueMakeNumber(ctx, motion.attitude.z * radToDeg);
#else
    // rotation rate {alpha, beta, gamma}
    params[6] = JSValueMakeNumber(ctx, 0);
    params[7] = JSValueMakeNumber(ctx, 0);
    params[8] = JSValueMakeNumber(ctx, 0);
    
    // orientation {alpha, beta, gamma}
    params[9] = JSValueMakeNumber(ctx, 0);
    params[10] = JSValueMakeNumber(ctx, 0);
    params[11] = JSValueMakeNumber(ctx, 0);
#endif
	
	params[12] = JSValueMakeNumber(ctx, NSProcessInfo.processInfo.systemUptime * 1000.0);

}

- (void)connect:(GCController *)controllerp {
	if (!controller){
		controller = controllerp;
		controller.motion.valueChangedHandler = ^(GCMotion *motion){
			[self setGamepadMotion:motion];
		};
		prevDeviceMotionDelegate = scriptView.deviceMotionDelegate;
		scriptView.deviceMotionDelegate = self;
	}
}

- (void)disconnect:(GCController *)controllerp {
	if (controller == controllerp){
		scriptView.deviceMotionDelegate = prevDeviceMotionDelegate;
		prevDeviceMotionDelegate = nil;
		controller.motion.valueChangedHandler = nil;
		controller = nil;
	}
}

- (void)triggerDeviceMotionEvents {
    if (motionValid){
        [self triggerEvent:@"devicemotion" argc:13 argv:params];
    }
}


EJ_BIND_GET(interval, ctx) {
	return JSValueMakeNumber(ctx, roundf(interval*1000)); // update interval in ms
}

EJ_BIND_EVENT(devicemotion);
//EJ_BIND_EVENT(acceleration);

@end
