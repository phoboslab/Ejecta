// This class provides the `devicemotion` and `deviceorientation` events to
// JavaScript.

#import "EJBindingEventedBase.h"
#import "EJJavaScriptView.h"
#import <CoreMotion/CoreMotion.h>

@interface EJBindingDeviceMotion : EJBindingEventedBase<EJDeviceMotionDelegate> {
	CMMotionManager *motionManager;
	JSValueRef params[13];
	float interval;
}

- (void)triggerDeviceMotionEvents;
- (void)triggerEventWithMotion:(CMDeviceMotion *)motion;
- (void)triggerEventWithAccelerometerData:(CMAccelerometerData *)accel;

@end
