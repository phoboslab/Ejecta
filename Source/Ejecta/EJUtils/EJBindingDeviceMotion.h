#import "EJBindingEventedBase.h"
#import <CoreMotion/CoreMotion.h>

@interface EJBindingDeviceMotion : EJBindingEventedBase {
	CMMotionManager * motionManager;
	JSValueRef params[12];
	float interval;
}

- (void)triggerEventWithMotion:(CMDeviceMotion *)motion;
- (void)triggerEventWithAccelerometerData:(CMAccelerometerData *)accel;

@end