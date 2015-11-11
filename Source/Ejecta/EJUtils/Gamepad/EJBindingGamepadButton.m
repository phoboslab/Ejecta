#import "EJBindingGamepadButton.h"


@implementation EJControllerButtonInputHome

- (id)initWithController:(GCController *)controllerp {
	if( self = [super init] ) {
		controller = [controllerp retain];
		controller.controllerPausedHandler = ^(GCController *controller) {
			lastPressed = NSDate.timeIntervalSinceReferenceDate;
		};
	}
	return self;
}

- (void)dealloc {
	controller.controllerPausedHandler = nil;
	[controller release];
	[super dealloc];
}

- (BOOL)isPressed {
	// If the last press happened not longer than 250ms ago, we consider
	// the button to be pressed. Yeah, it's a cheap hack :/
	return (NSDate.timeIntervalSinceReferenceDate - lastPressed) < 0.25;
}

- (float)value {
	return self.isPressed ? 1.0 : 0.0;
}

@end



@implementation EJBindingGamepadButton

- (id)initWithButton:(NSObject<EJControllerButtonInputProtocol> *)buttonp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		button = [buttonp retain];
	}
	return self;
}

-(void)dealloc {
	[button release];
	[super dealloc];
}

EJ_BIND_GET(pressed, ctx) {
	return JSValueMakeBoolean(ctx, button.pressed);
}

EJ_BIND_GET(value, ctx) {
	return JSValueMakeNumber(ctx, button.value);
}

@end

