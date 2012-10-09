#import "EJBindingTouchInput.h"


@implementation EJBindingTouchInput

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		[EJApp instance].touchDelegate = self;
	}
	return self;
}

- (void)triggerEvent:(NSString *)name withTouches:(NSSet *)touches {
	EJApp * ejecta = [EJApp instance];
	JSContextRef ctx = ejecta.jsGlobalContext;
	float scaling = ejecta.internalScaling;

	JSValueRef params[EJ_TOUCH_MAX_CALLBACK_PARAMS];
	int argc = 0;
	for( UITouch * touch in touches ) {
		CGPoint pos = [touch locationInView:touch.view];
		
		params[argc++] = JSValueMakeNumber(ctx, [touch hash]);
		params[argc++] = JSValueMakeNumber(ctx, pos.x / scaling);
		params[argc++] = JSValueMakeNumber(ctx, pos.y / scaling);
		
		if( argc >= EJ_TOUCH_MAX_CALLBACK_PARAMS ) { break; }
	}
	
	[self triggerEvent:name argc:argc argv:params];
}

EJ_BIND_EVENT(touchstart);
EJ_BIND_EVENT(touchend);
EJ_BIND_EVENT(touchmove);


@end
