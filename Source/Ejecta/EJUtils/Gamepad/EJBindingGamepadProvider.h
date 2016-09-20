// The GamepadProvides implements the `gamepadconnected` and
// `gamepaddisconnected` events as well as the windows's getGamepads() method.
// The whole API, including Gamepad and Button instances, is closely modeled
// after the w3c spec.

#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"

#define EJ_GAMEPAD_NUM_DEVICES 4

@interface EJBindingGamepadProvider : EJBindingEventedBase {
	NSMutableArray *gamepadBindings;
}
@end
