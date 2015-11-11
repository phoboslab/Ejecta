#import "EJBindingGamepad.h"
#import "EJBindingGamepadButton.h"

@implementation EJBindingGamepad
@synthesize controller;

- (id)initWithController:(GCController *)controllerp atIndex:(NSUInteger)indexp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		controller = [controllerp retain];
		index = indexp;
		connected = YES;
		
		controller.playerIndex = index;
		baseTime = NSDate.timeIntervalSinceReferenceDate;
	}
	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	
	// We have to hold on to the JS Object here as long as the gamepad is connectd
	// and can be reached through navigator.getGamepads(). It will be unprotected
	// in (void)disconnet.
	JSValueProtect(scriptView.jsGlobalContext, obj);

	// Initialize Axes - JS Array with Numbers
	if( controller.extendedGamepad ) {
		int numAxes = 4;
		JSValueRef axesValues[numAxes];
		for( int i = 0; i < numAxes; i++ ) {
			axesValues[i] = JSValueMakeNumber(view.jsGlobalContext, 0);
		}
		jsAxes = JSObjectMakeArray(view.jsGlobalContext, numAxes, axesValues, NULL);
	}
	else {
		jsAxes = JSObjectMakeArray(view.jsGlobalContext, 0, NULL, NULL);
	}
	JSValueProtect(view.jsGlobalContext, jsAxes);
	
	
	// Initialize Buttons - JS Array with EJBindingGamepad instances. The W3C standard defines
	// 17 buttons. Not all are supported by iOS. However, W3C dictates that Gamepad buttons
	// should be mapped to the standard layout if possible, so we still provide dummies, so
	// the button indices are not mingled.
	// See: http://www.w3.org/TR/gamepad/#remapping
	
	// Buttons unsupported by iOS: Select:8, Start:9, LeftStick:10, RightStick:11
	
	NSObject<EJControllerButtonInputProtocol> *mapping[kEJGamepadNumButtons] = {NULL};
	if( controller.extendedGamepad ) {
		GCExtendedGamepad *gamepad = controller.extendedGamepad;
		mapping[kEJGamepadButtonA] = gamepad.buttonA;
		mapping[kEJGamepadButtonB] = gamepad.buttonB;
		mapping[kEJGamepadButtonX] = gamepad.buttonX;
		mapping[kEJGamepadButtonY] = gamepad.buttonY;
		mapping[kEJGamepadButtonL1] = gamepad.leftShoulder;
		mapping[kEJGamepadButtonR1] = gamepad.rightShoulder;
		mapping[kEJGamepadButtonL2] = gamepad.leftTrigger;
		mapping[kEJGamepadButtonR2] = gamepad.rightTrigger;
		mapping[kEJGamepadButtonUp] = gamepad.dpad.up;
		mapping[kEJGamepadButtonDown] = gamepad.dpad.down;
		mapping[kEJGamepadButtonLeft] = gamepad.dpad.left;
		mapping[kEJGamepadButtonRight] = gamepad.dpad.right;
	}
	else if( controller.gamepad ) {
		GCGamepad *gamepad = controller.gamepad;
		mapping[kEJGamepadButtonA] = gamepad.buttonA;
		mapping[kEJGamepadButtonB] = gamepad.buttonB;
		mapping[kEJGamepadButtonX] = gamepad.buttonX;
		mapping[kEJGamepadButtonY] = gamepad.buttonY;
		mapping[kEJGamepadButtonL1] = gamepad.leftShoulder;
		mapping[kEJGamepadButtonR1] = gamepad.rightShoulder;
		mapping[kEJGamepadButtonUp] = gamepad.dpad.up;
		mapping[kEJGamepadButtonDown] = gamepad.dpad.down;
		mapping[kEJGamepadButtonLeft] = gamepad.dpad.left;
		mapping[kEJGamepadButtonRight] = gamepad.dpad.right;
	}
	#if TARGET_OS_TV 
		else if( controller.microGamepad ) {
			GCMicroGamepad *gamepad = controller.microGamepad;
			gamepad.reportsAbsoluteDpadValues = YES;
			mapping[kEJGamepadButtonA] = gamepad.buttonA;
			mapping[kEJGamepadButtonX] = gamepad.buttonX;
			mapping[kEJGamepadButtonUp] = gamepad.dpad.up;
			mapping[kEJGamepadButtonDown] = gamepad.dpad.down;
			mapping[kEJGamepadButtonLeft] = gamepad.dpad.left;
			mapping[kEJGamepadButtonRight] = gamepad.dpad.right;
		}
	#endif
	
	
	// Because Apple likes to fuck with us, the "Pause" button (otherwise known as "Home" or
	// "Menu") is not available as GCControllerButtonInput, but rather only reachable through
	// the "controllerPausedHandler" callback on the controller. So we provide our own
	// ButtonInput instance that conforms to the same protocol as GCControllerButtonInput.
	
	mapping[kEJGamepadButtonHome] = [[EJControllerButtonInputHome alloc] initWithController:controller];
	
	
	JSValueRef buttonsValues[kEJGamepadNumButtons];
	for( int i = 0; i < kEJGamepadNumButtons; i++ ) {
		NSObject<EJControllerButtonInputProtocol> *button = mapping[i];
		
		// button may be NULL, but EJBindingGamepadButton doesn't care
		EJBindingGamepadButton *binding = [[EJBindingGamepadButton alloc] initWithButton:button];
		buttonsValues[i] = [EJBindingGamepadButton
			createJSObjectWithContext:scriptView.jsGlobalContext
			scriptView:scriptView
			instance:binding];
		[binding release];
	}
	
	jsButtons = JSObjectMakeArray(view.jsGlobalContext, kEJGamepadNumButtons, buttonsValues, NULL);
	JSValueProtect(view.jsGlobalContext, jsButtons);
	
	
	[mapping[kEJGamepadButtonHome] release];
}

- (void)disconnect {
	connected = NO;
	JSValueUnprotectSafe(scriptView.jsGlobalContext, jsObject);
}

- (void)dealloc {
	JSValueUnprotectSafe(scriptView.jsGlobalContext, jsAxes);
	JSValueUnprotectSafe(scriptView.jsGlobalContext, jsButtons);
	[controller release];
	
	[super dealloc];
}

- (JSObjectRef)jsObject {
	return jsObject;
}

EJ_BIND_GET(id, ctx) {
	return NSStringToJSValue(ctx, controller.vendorName);
}

EJ_BIND_GET(index, ctx) {
	return JSValueMakeNumber(ctx, index);
}

EJ_BIND_GET(connected, ctx) {
	return JSValueMakeBoolean(ctx, connected);
}

EJ_BIND_GET(timestamp, ctx) {
	NSTimeInterval now = NSDate.timeIntervalSinceReferenceDate;
	return JSValueMakeNumber(ctx, (now - baseTime) * 1000.0);
}

EJ_BIND_GET(mapping, ctx) {
	return NSStringToJSValue(ctx, @"standard");
}

EJ_BIND_GET(axes, ctx) {
	if( controller.extendedGamepad ) {
		GCExtendedGamepad *gamepad = controller.extendedGamepad;
		GCControllerDirectionPad *leftStick = gamepad.leftThumbstick;
		GCControllerDirectionPad *rightStick = gamepad.rightThumbstick;
		
		// Note: Y-Axis is inverted. iOS says positive Y means up, W3C says down.
		JSObjectSetPropertyAtIndex(ctx, jsAxes, 0, JSValueMakeNumber(ctx, leftStick.xAxis.value), NULL);
		JSObjectSetPropertyAtIndex(ctx, jsAxes, 1, JSValueMakeNumber(ctx, -leftStick.yAxis.value), NULL);
		JSObjectSetPropertyAtIndex(ctx, jsAxes, 2, JSValueMakeNumber(ctx, rightStick.xAxis.value), NULL);
		JSObjectSetPropertyAtIndex(ctx, jsAxes, 3, JSValueMakeNumber(ctx, -rightStick.yAxis.value), NULL);
	}
	#if TARGET_OS_TV 
		// Provide the Remote's touch pad a axis in addition to the Up/Down/Left/Right buttons
		else if( controller.microGamepad ) {
			GCMicroGamepad *gamepad = controller.microGamepad;
			JSObjectSetPropertyAtIndex(ctx, jsAxes, 0, JSValueMakeNumber(ctx, gamepad.dpad.xAxis.value), NULL);
			JSObjectSetPropertyAtIndex(ctx, jsAxes, 1, JSValueMakeNumber(ctx, -gamepad.dpad.yAxis.value), NULL);
		}
	#endif
	return jsAxes;
}

EJ_BIND_GET(buttons, ctx) {
	return jsButtons;
}

EJ_BIND_GET(exitOnMenuPress, ctx) {
	return JSValueMakeBoolean(ctx, scriptView.exitOnMenuPress);
}

EJ_BIND_SET(exitOnMenuPress, ctx, value) {
	scriptView.exitOnMenuPress = JSValueToBoolean(ctx, value);
}

@end





