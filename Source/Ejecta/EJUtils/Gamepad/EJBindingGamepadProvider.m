#import "EJBindingGamepadProvider.h"
#import "EJBindingGamepad.h"

@implementation EJBindingGamepadProvider

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	
	// Create the gamepadBindings array, fill it with available gamepads
	gamepadBindings = [[NSMutableArray alloc] initWithCapacity:EJ_GAMEPAD_NUM_DEVICES];
	int maxIndex = 0;
	for( GCController *controller in GCController.controllers ) {
		EJBindingGamepad *binding = [[EJBindingGamepad alloc] initWithController:controller atIndex:maxIndex];
		[EJBindingGamepad createJSObjectWithContext:scriptView.jsGlobalContext scriptView:scriptView instance:binding];
		[gamepadBindings addObject:binding];
		[binding release];
		maxIndex++;
	}
	
	// Fill up the remaining slots with NSNull
	for( int i = maxIndex; i < EJ_GAMEPAD_NUM_DEVICES; i++ ) {
		[gamepadBindings addObject:NSNull.null];
	}
	
	[NSNotificationCenter.defaultCenter
		addObserver:self selector:@selector(gameControllerDidConnect:)
		name:GCControllerDidConnectNotification	object:nil];
	
	[NSNotificationCenter.defaultCenter
		addObserver:self selector:@selector(gameControllerDidDisconnect:)
		name:GCControllerDidDisconnectNotification object:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
	
	[gamepadBindings release];	
	[super dealloc];
}
	

- (void)gameControllerDidConnect:(NSNotification *)notification {
	GCController *controller = (GCController *)notification.object;
	
	// Do we already have this controller for whatever reason?
	for( EJBindingGamepad *binding in gamepadBindings ) {
		if( (id)binding != NSNull.null && binding.controller == controller ) {
			return;
		}
	}
	
	// Find the first free index
	NSUInteger index = [gamepadBindings indexOfObject:NSNull.null];
	if( index == NSNotFound ) {
		index = gamepadBindings.count;
	}
	
	if( index >= EJ_GAMEPAD_NUM_DEVICES ) {
		return;
	}
	
	// Create the Binding
	EJBindingGamepad *binding = [[EJBindingGamepad alloc] initWithController:controller atIndex:index];
	[EJBindingGamepad createJSObjectWithContext:scriptView.jsGlobalContext scriptView:scriptView instance:binding];
	[gamepadBindings setObject:binding atIndexedSubscript:index];
	
	[self triggerEvent:@"gamepadconnected" properties:(JSEventProperty[]){
		{"gamepad", binding.jsObject},
		{NULL, NULL},
	}];
	
	[binding release];
}

- (void)gameControllerDidDisconnect:(NSNotification *)notification {
	GCController *controller = (GCController *)notification.object;
	
	// Find the binding for the controller that was disconnected
	EJBindingGamepad *disconnectedBinding = nil;
	NSUInteger index = 0;
	for( EJBindingGamepad *binding in gamepadBindings ) {
		if( (id)binding != NSNull.null && binding.controller == controller ) {
			disconnectedBinding	= binding;
			break;
		}
		index++;
	}
	
	if( disconnectedBinding ) {
		disconnectedBinding.connected = NO;
		[self triggerEvent:@"gamepaddisconnected" properties:(JSEventProperty[]){
			{"gamepad", disconnectedBinding.jsObject},
			{NULL, NULL},
		}];
	}
	
	// Replace the binding with NSNull
	[gamepadBindings setObject:NSNull.null atIndexedSubscript:index];
}

EJ_BIND_FUNCTION(getGamepads, ctx, argc, argv) {
	JSValueRef args[EJ_GAMEPAD_NUM_DEVICES];
	for( int i = 0; i < EJ_GAMEPAD_NUM_DEVICES; i++ ) {
		EJBindingGamepad *binding = gamepadBindings[i];
		args[i] = (id)binding == NSNull.null
			? scriptView->jsUndefined
			: binding.jsObject;
	}
	return JSObjectMakeArray(ctx, EJ_GAMEPAD_NUM_DEVICES, args, NULL);
}

EJ_BIND_EVENT(gamepadconnected);
EJ_BIND_EVENT(gamepaddisconnected);

@end

