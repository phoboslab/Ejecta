#import "EJBindingTouchInput.h"

@implementation EJBindingTouchInput

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctxp argc:argc argv:argv] ) {
		if( argc > 0 ) {
			jsTouchTarget = argv[0];
			JSValueProtect(ctxp, jsTouchTarget);
		}
	}
	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	
	JSContextRef ctx = scriptView.jsGlobalContext;
	
	// Create the JavaScript arrays that will be passed to the callback
	jsRemainingTouches = JSObjectMakeArray(ctx, 0, NULL, NULL);
	JSValueProtect(ctx, jsRemainingTouches);
	
	jsChangedTouches = JSObjectMakeArray(ctx, 0, NULL, NULL);
	JSValueProtect(ctx, jsChangedTouches);
	
	// Create some JSStrings for property access
	jsLengthName = JSStringCreateWithUTF8CString("length");
	
	jsTargetName = JSStringCreateWithUTF8CString("target");
	jsIdentifierName = JSStringCreateWithUTF8CString("identifier");
	jsPageXName = JSStringCreateWithUTF8CString("pageX");
	jsPageYName = JSStringCreateWithUTF8CString("pageY");
	jsClientXName = JSStringCreateWithUTF8CString("clientX");
	jsClientYName = JSStringCreateWithUTF8CString("clientY");
    
    jsPressTypeName = JSStringCreateWithUTF8CString("pressType");
    
    jsPressTypeSelect = NSStringToJSValue(ctx, @"select");
    jsPressTypeUpArrow = NSStringToJSValue(ctx, @"upArrow");
    jsPressTypeDownArrow = NSStringToJSValue(ctx, @"downArrow");
    jsPressTypeLeftArrow = NSStringToJSValue(ctx, @"leftArrow");
    jsPressTypeRightArrow = NSStringToJSValue(ctx, @"rightArrow");
    jsPressTypeMenu = NSStringToJSValue(ctx, @"menu");
    jsPressTypePlayPause = NSStringToJSValue(ctx, @"playPause");
    
    JSValueProtect(ctx, jsPressTypeSelect);
    JSValueProtect(ctx, jsPressTypeUpArrow);
    JSValueProtect(ctx, jsPressTypeDownArrow);
    JSValueProtect(ctx, jsPressTypeLeftArrow);
    JSValueProtect(ctx, jsPressTypeRightArrow);
    JSValueProtect(ctx, jsPressTypeMenu);
    JSValueProtect(ctx, jsPressTypePlayPause);
	
	scriptView.touchDelegate = self;
}

- (void)dealloc {
	JSContextRef ctx = scriptView.jsGlobalContext;
	
	JSValueUnprotectSafe( ctx, jsTouchTarget );
	JSValueUnprotectSafe( ctx, jsRemainingTouches );
	JSValueUnprotectSafe( ctx, jsChangedTouches );
	JSStringRelease( jsLengthName );
	
	JSStringRelease( jsTargetName );
	JSStringRelease( jsIdentifierName );
	JSStringRelease( jsPageXName );
	JSStringRelease( jsPageYName );
	JSStringRelease( jsClientXName );
	JSStringRelease( jsClientYName );
    
    JSStringRelease( jsPressTypeName );
    
    JSValueUnprotectSafe(ctx, jsPressTypeSelect);
    JSValueUnprotectSafe(ctx, jsPressTypeUpArrow);
    JSValueUnprotectSafe(ctx, jsPressTypeDownArrow);
    JSValueUnprotectSafe(ctx, jsPressTypeLeftArrow);
    JSValueUnprotectSafe(ctx, jsPressTypeRightArrow);
    JSValueUnprotectSafe(ctx, jsPressTypeMenu);
    JSValueUnprotectSafe(ctx, jsPressTypePlayPause);
	
	for( int i = 0; i < touchesInPool; i++ ) {
		JSValueUnprotectSafe( ctx, jsTouchesPool[i] );
	}
	
	[super dealloc];
}

- (void)triggerEvent:(NSString *)name all:(NSSet *)all changed:(NSSet *)changed remaining:(NSSet *)remaining {
	JSContextRef ctx = scriptView.jsGlobalContext;
	
	NSUInteger remainingCount = MIN(remaining.count, EJ_TOUCH_INPUT_MAX_TOUCHES);
	NSUInteger changedCount = MIN(changed.count, EJ_TOUCH_INPUT_MAX_TOUCHES);
	NSUInteger totalCount = MAX(remainingCount, changedCount);
	
	JSObjectSetProperty(ctx, jsRemainingTouches, jsLengthName, JSValueMakeNumber(ctx, remainingCount), kJSPropertyAttributeNone, NULL);
	JSObjectSetProperty(ctx, jsChangedTouches, jsLengthName, JSValueMakeNumber(ctx, changedCount), kJSPropertyAttributeNone, NULL);
	
	// More touches than we have in our pool? Create some!
	if( touchesInPool < totalCount ) {
		for( NSUInteger i = touchesInPool; i < totalCount; i++ ) {
			jsTouchesPool[i] = JSObjectMake( ctx, NULL, NULL );
			JSValueProtect( ctx, jsTouchesPool[i] );
			
			// Attach the target (always the screen canvas) for each new touch. This never changes, so we can do it here
			JSObjectSetProperty( ctx, jsTouchesPool[i], jsTargetName, jsTouchTarget, kJSPropertyAttributeNone, NULL );
		}
		touchesInPool = totalCount;
	}
	
	int
		poolIndex = 0,
		remainingIndex = 0,
		changedIndex = 0;
		
	for( id input in all ) {
        
        JSObjectRef jsTouch = jsTouchesPool[poolIndex++];
        
        JSValueRef identifier = JSValueMakeNumber(ctx, [input hash] );
        JSObjectSetProperty( ctx, jsTouch, jsIdentifierName, identifier, kJSPropertyAttributeNone, NULL );
        
        if ([input isKindOfClass:[UITouch class]])
        {
            CGPoint pos = [input locationInView:[input view]];
		
            JSValueRef x = JSValueMakeNumber(ctx, pos.x);
            JSValueRef y = JSValueMakeNumber(ctx, pos.y);
            
            JSObjectSetProperty( ctx, jsTouch, jsPageXName, x, kJSPropertyAttributeNone, NULL );
            JSObjectSetProperty( ctx, jsTouch, jsPageYName, y, kJSPropertyAttributeNone, NULL );
            JSObjectSetProperty( ctx, jsTouch, jsClientXName, x, kJSPropertyAttributeNone, NULL );
            JSObjectSetProperty( ctx, jsTouch, jsClientYName, y, kJSPropertyAttributeNone, NULL );
        }
#if TARGET_OS_TV
        else if ([input isKindOfClass:[UIPress class]])
        {
            switch ([((UIPress*)input) type]) {
                case UIPressTypeSelect:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypeSelect, kJSPropertyAttributeNone, NULL );
                    break;
                    
                case UIPressTypeUpArrow:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypeUpArrow, kJSPropertyAttributeNone, NULL );
                    break;
                    
                case UIPressTypeDownArrow:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypeDownArrow, kJSPropertyAttributeNone, NULL );
                    break;
                    
                case UIPressTypeLeftArrow:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypeLeftArrow, kJSPropertyAttributeNone, NULL );
                    break;
                    
                case UIPressTypeRightArrow:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypeRightArrow, kJSPropertyAttributeNone, NULL );
                    break;
                    
                case UIPressTypeMenu:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypeMenu, kJSPropertyAttributeNone, NULL );
                    break;
                    
                case UIPressTypePlayPause:
                    JSObjectSetProperty( ctx, jsTouch, jsPressTypeName, jsPressTypePlayPause, kJSPropertyAttributeNone, NULL );
                    break;
            }
        }
#endif
        
        if( [remaining member:input] ) {
            JSObjectSetPropertyAtIndex(ctx, jsRemainingTouches, remainingIndex++, jsTouch, NULL);
        }
        
        if( [changed member:input] ) {
            JSObjectSetPropertyAtIndex(ctx, jsChangedTouches, changedIndex++, jsTouch, NULL);
        }
		
		if( poolIndex >= touchesInPool ) { break; }
	}
	
	[self triggerEvent:name argc:2 argv:(JSValueRef[]){ jsRemainingTouches, jsChangedTouches }];
}

EJ_BIND_EVENT(touchstart);
EJ_BIND_EVENT(touchend);
EJ_BIND_EVENT(touchmove);


@end
