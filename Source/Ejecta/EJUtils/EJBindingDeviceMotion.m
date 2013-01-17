#import "EJBindingDeviceMotion.h"

@implementation EJBindingDeviceMotion

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		
		interval = 1.0f/60.0f;
		motionManager = [[CMMotionManager alloc] init];
		NSOperationQueue * queue = [EJApp instance].opQueue;
		
		// Has Gyro? (iPhone4 and newer)
		if( motionManager.isDeviceMotionAvailable ) {
			motionManager.deviceMotionUpdateInterval = interval;
			[motionManager startDeviceMotionUpdatesToQueue:queue withHandler:
				^(CMDeviceMotion *motion, NSError *error) {
					[self triggerEventWithMotion:motion];
				}];
		}
		
		// Only basic accelerometer data
		else {
			motionManager.accelerometerUpdateInterval = interval;
			[motionManager startAccelerometerUpdatesToQueue:queue withHandler:
				^(CMAccelerometerData *accelerometerData, NSError *error) {
					[self triggerEventWithAccelerometerData:accelerometerData];
				}];
		}
	}
	return self;
}


static const float g = 9.80665;
static const float radToDeg = (180/M_PI);

- (void)triggerEventWithMotion:(CMDeviceMotion *)motion {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	
	// accelerationIncludingGravity {x, y, z}
	params[0] = JSValueMakeNumber(ctx, (motion.userAcceleration.x + motion.gravity.x) * g);
	params[1] = JSValueMakeNumber(ctx, (motion.userAcceleration.y + motion.gravity.y) * g);
	params[2] = JSValueMakeNumber(ctx, (motion.userAcceleration.z + motion.gravity.z) * g);
	
	// acceleration {x, y, z}
	params[3] = JSValueMakeNumber(ctx, motion.userAcceleration.x * g);
	params[4] = JSValueMakeNumber(ctx, motion.userAcceleration.y * g);
	params[5] = JSValueMakeNumber(ctx, motion.userAcceleration.z * g);
	
	// rotation rate {alpha, beta, gamma}
	params[6] = JSValueMakeNumber(ctx, motion.rotationRate.x * radToDeg);
	params[7] = JSValueMakeNumber(ctx, motion.rotationRate.y * radToDeg);
	params[8] = JSValueMakeNumber(ctx, motion.rotationRate.z * radToDeg);
	
	// orientation {alpha, beta, gamma}
	params[9] = JSValueMakeNumber(ctx, motion.attitude.roll * radToDeg);
	params[10] = JSValueMakeNumber(ctx, motion.attitude.pitch * radToDeg);
	params[11] = JSValueMakeNumber(ctx, motion.attitude.yaw * radToDeg);
	
	[self triggerEvent:@"devicemotion" argc:12 argv:params];
}

- (void)triggerEventWithAccelerometerData:(CMAccelerometerData *)accel {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	
	// accelerationIncludingGravity {x, y, z}
	params[0] = JSValueMakeNumber(ctx, accel.acceleration.x * g);
	params[1] = JSValueMakeNumber(ctx, accel.acceleration.y * g);
	params[2] = JSValueMakeNumber(ctx, accel.acceleration.z * g);
	
	[self triggerEvent:@"acceleration" argc:3 argv:params];
}

EJ_BIND_GET(interval, ctx) {
	return JSValueMakeNumber(ctx, roundf(interval*1000)); // update interval in ms
}

EJ_BIND_EVENT(devicemotion);
EJ_BIND_EVENT(acceleration);

@end
