#import <GameController/GameController.h>
#import "EJBindingEventedBase.h"

// We need a seperate GCControllerButtonInput that handles the Home button via the
// the controllerPausedHandler callback, but we don't want to subclass
// GCControllerButtonInput.

// The EJControllerButtonInputProtocol defines the two properties we're interested
// in for a ButtonInput. GCControllerButtonInput already conforms to this, so we
// create a category on it, in order to let the compiler know of that fact.

// We can also use this protocol to create our own EJControllerButtonInputHome
// class. EJBindingGamepadButton then simply accepts any NSObject that conforms
// to the protocol -> either the stock GCControllerButtonInput or our own
// EJControllerButtonInputHome.


// The Protocl GCControllerButtonInput and our own ButtonInput class conform to
@protocol EJControllerButtonInputProtocol
@property (nonatomic, readonly) float value;
@property (nonatomic, readonly, getter = isPressed) BOOL pressed;
@end


// Empty category with EJControllerButtonInputProtocol, so the compiler knows
// GCControllerButtonInput conforms to it.
@interface GCControllerButtonInput (GCControllerButtonInputWithEJProtocol) <EJControllerButtonInputProtocol>
@end


// Home Button that conforms to the EJControllerButtonInputProtocol
@interface EJControllerButtonInputHome : NSObject<EJControllerButtonInputProtocol> {
	GCController *controller;
	NSTimeInterval lastPressed;
}
- (id)initWithController:(GCController *)controller;
@property (nonatomic, readonly) float value;
@property (nonatomic, readonly, getter = isPressed) BOOL pressed;
@end


// The Binding Class for a button, exposed to JS
@interface EJBindingGamepadButton : EJBindingBase {
	NSObject<EJControllerButtonInputProtocol> *button;
}

- (id)initWithButton:(NSObject<EJControllerButtonInputProtocol> *)button;

@end
