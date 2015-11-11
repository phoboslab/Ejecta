#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"

#define EJ_GAMEPAD_NUM_DEVICES 4

@interface EJBindingGamepadProvider : EJBindingEventedBase {
	NSMutableArray *gamepadBindings;
}
@end
