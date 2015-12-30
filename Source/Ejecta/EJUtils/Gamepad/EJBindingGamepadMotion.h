#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"


@interface EJBindingGamepadMotion : EJBindingEventedBase<EJDeviceMotionDelegate> {

    JSValueRef params[12];
    float interval;
}

+ (id)sharedInstance;

- (void)triggerDeviceMotionEvents;
- (void)setGamepadMotion:(GCMotion *)motion;

@end
