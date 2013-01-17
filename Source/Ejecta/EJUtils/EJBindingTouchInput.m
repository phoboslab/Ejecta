#import "EJBindingTouchInput.h"


@implementation EJBindingTouchInput

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
	
		// Create the JavaScript arrays that will be passed to the callback
		jsRemainingTouches = JSObjectMakeArray(ctx, 0, NULL, NULL);
		JSValueProtect(ctx, jsRemainingTouches);
		
		jsChangedTouches = JSObjectMakeArray(ctx, 0, NULL, NULL);
		JSValueProtect(ctx, jsChangedTouches);
		
		// Create some JSStrings for property access
		jsLengthName = JSStringCreateWithUTF8CString("length");
		
		jsIdentifierName = JSStringCreateWithUTF8CString("identifier");
		jsPageXName = JSStringCreateWithUTF8CString("pageX");
		jsPageYName = JSStringCreateWithUTF8CString("pageY");
		jsClientXName = JSStringCreateWithUTF8CString("clientX");
		jsClientYName = JSStringCreateWithUTF8CString("clientY");
		
		// Create all touch objects
		for( int i = 0; i < EJ_TOUCH_INPUT_MAX_TOUCHES; i++ ) {
			jsTouchesPool[i] = JSObjectMake( ctx, NULL, NULL );
			JSValueProtect( ctx, jsTouchesPool[i] );
		}
		
		[EJApp instance].touchDelegate = self;
	}
	return self;
}

- (void)dealloc {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	
	JSValueUnprotect( ctx, jsRemainingTouches );
	JSValueUnprotect( ctx, jsChangedTouches );
	JSStringRelease( jsLengthName );
	
	JSStringRelease( jsIdentifierName );
	JSStringRelease( jsPageXName );
	JSStringRelease( jsPageYName );
	JSStringRelease( jsClientXName );
	JSStringRelease( jsClientYName );
	
	for( int i = 0; i < EJ_TOUCH_INPUT_MAX_TOUCHES; i++ ) {
		JSValueUnprotect( ctx, jsTouchesPool[i] );
	}
	
	[super dealloc];
}

- (void)triggerEvent:(NSString *)name all:(NSSet *)all changed:(NSSet *)changed remaining:(NSSet *)remaining {
	EJApp * ejecta = [EJApp instance];
	JSContextRef ctx = ejecta.jsGlobalContext;
	float scale = ejecta.internalScaling;
	
	JSObjectSetProperty(ctx, jsRemainingTouches, jsLengthName, JSValueMakeNumber(ctx, remaining.count), kJSPropertyAttributeNone, NULL);
	JSObjectSetProperty(ctx, jsChangedTouches, jsLengthName, JSValueMakeNumber(ctx, changed.count), kJSPropertyAttributeNone, NULL);
	
	int
		poolIndex = 0,
		remainingIndex = 0,
		changedIndex = 0;
		
	for( UITouch * touch in all ) {
		CGPoint pos = [touch locationInView:touch.view];
		
		JSValueRef identifier = JSValueMakeNumber(ctx, [touch hash] );
		JSValueRef x = JSValueMakeNumber(ctx, pos.x / scale );
		JSValueRef y = JSValueMakeNumber(ctx, pos.y / scale );
		
		JSObjectRef jsTouch = jsTouchesPool[poolIndex++];
		JSObjectSetProperty( ctx, jsTouch, jsIdentifierName, identifier, kJSPropertyAttributeNone, NULL );
		JSObjectSetProperty( ctx, jsTouch, jsPageXName, x, kJSPropertyAttributeNone, NULL );
		JSObjectSetProperty( ctx, jsTouch, jsPageYName, y, kJSPropertyAttributeNone, NULL );
		JSObjectSetProperty( ctx, jsTouch, jsClientXName, x, kJSPropertyAttributeNone, NULL );
		JSObjectSetProperty( ctx, jsTouch, jsClientYName, y, kJSPropertyAttributeNone, NULL );
		
		if( [remaining member:touch] ) {
			JSObjectSetPropertyAtIndex(ctx, jsRemainingTouches, remainingIndex++, jsTouch, NULL);
		}
		
		if( [changed member:touch] ) {
			JSObjectSetPropertyAtIndex(ctx, jsChangedTouches, changedIndex++, jsTouch, NULL);
		}
		
		if( poolIndex >= EJ_TOUCH_INPUT_MAX_TOUCHES ) { break; }
	}
	
	[self triggerEvent:name argc:2 argv:(JSValueRef[]){ jsRemainingTouches, jsChangedTouches }];
}

EJ_BIND_EVENT(touchstart);
EJ_BIND_EVENT(touchend);
EJ_BIND_EVENT(touchmove);


@end
