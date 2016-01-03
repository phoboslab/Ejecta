#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"


@interface EJBindingGamepadMotion : EJBindingEventedBase<EJDeviceMotionDelegate> {

    JSValueRef params[12];
	NSObject<EJDeviceMotionDelegate> *prevDeviceMotionDelegate;
	GCController *controller;
    BOOL motionValid;
    float interval;
}

+ (id)sharedInstance;

- (void)triggerDeviceMotionEvents;
- (void)setGamepadMotion:(GCMotion *)motion;

- (void)connect:(GCController *)controller;
- (void)disconnect:(GCController *)controller;

@end
