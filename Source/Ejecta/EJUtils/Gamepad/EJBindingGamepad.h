// EJBindingGamepad provides an implementation for a single Gamepad.
// Eeach instance hosts an array of buttons and axis.

#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"

// Button Mappings according to http://www.w3.org/TR/gamepad/#remapping
typedef enum {
	kEJGamepadButtonA = 0,
	kEJGamepadButtonB = 1,
	kEJGamepadButtonX = 2,
	kEJGamepadButtonY = 3,
	kEJGamepadButtonL1 = 4,
	kEJGamepadButtonR1 = 5,
	kEJGamepadButtonL2 = 6,
	kEJGamepadButtonR2 = 7,
	kEJGamepadButtonSelect = 8,
	kEJGamepadButtonStart = 9,
	kEJGamepadButtonLeftStick = 10,
	kEJGamepadButtonRightStick = 11,
	kEJGamepadButtonUp = 12,
	kEJGamepadButtonDown = 13,
	kEJGamepadButtonLeft = 14,
	kEJGamepadButtonRight = 15,
	kEJGamepadButtonHome = 16,
	kEJGamepadNumButtons
} kEJGamepadButtonMapping;


@interface EJBindingGamepad : EJBindingBase {
	GCController *controller;
	
	NSUInteger index;
	BOOL connected;
	
	JSObjectRef jsAxes;
	JSObjectRef jsButtons;
}

- (id)initWithController:(GCController *)controller atIndex:(NSUInteger)index;
- (void)disconnect;

@property (readonly) JSObjectRef jsObject;
@property (readonly) GCController *controller;
	
@end

