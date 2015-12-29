#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"


@interface EJBindingGamepadMotion : EJBindingEventedBase {

	JSValueRef params[12];
    float interval;
}

+ (id)sharedInstance;

- (void)triggerEventWithMotion:(GCMotion *)motion;

@end
