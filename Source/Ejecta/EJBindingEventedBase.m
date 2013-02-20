#import "EJBindingEventedBase.h"
#import "EJJavaScriptView.h"

@implementation EJBindingEventedBase

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctxp argc:argc argv:argv] ) {
		eventListeners = [[NSMutableDictionary alloc] init];
		onCallbacks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	JSContextRef ctx = scriptView.jsGlobalContext;
	
	// Unprotect all event callbacks
	for( NSString *name in eventListeners ) {
		NSArray *listeners = eventListeners[name];
		for( NSValue *callbackValue in listeners ) {
			JSValueUnprotectSafe(ctx, [callbackValue pointerValue]);
		}
	}
	[eventListeners release];
	
	// Unprotect all event callbacks
	for( NSString *name in onCallbacks ) {
		NSValue *listener = onCallbacks[name];
		JSValueUnprotectSafe(ctx, [(NSValue *)listener pointerValue]);
	}
	[onCallbacks release];
	
	[super dealloc];
}

- (JSObjectRef)getCallbackWith:(NSString *)name ctx:(JSContextRef)ctx {
	NSValue *listener = onCallbacks[name];
	return listener ? [listener pointerValue] : NULL;
}

- (void)setCallbackWith:(NSString *)name ctx:(JSContextRef)ctx callback:(JSValueRef)callbackValue {
	// remove old event listener?
	JSObjectRef oldCallback = [self getCallbackWith:name ctx:ctx];
	if( oldCallback ) {
		JSValueUnprotectSafe(ctx, oldCallback);
		[onCallbacks removeObjectForKey:name];
	}
	
	JSObjectRef callback = JSValueToObject(ctx, callbackValue, NULL);
	if( callback && JSObjectIsFunction(ctx, callback) ) {
		JSValueProtect(ctx, callback);
		onCallbacks[name] = [NSValue valueWithPointer:callback];
		return;
	}
}

EJ_BIND_FUNCTION(addEventListener, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	NSString *name = JSValueToNSString( ctx, argv[0] );
	JSObjectRef callback = JSValueToObject(ctx, argv[1], NULL);
	JSValueProtect(ctx, callback);
	NSValue *callbackValue = [NSValue valueWithPointer:callback];
	
	NSMutableArray *listeners = NULL;
	if( (listeners = eventListeners[name]) ) {
		[listeners addObject:callbackValue];
	}
	else {
		eventListeners[name] = [NSMutableArray arrayWithObject:callbackValue];
	}
	return NULL;
}

EJ_BIND_FUNCTION(removeEventListener, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	NSString *name = JSValueToNSString( ctx, argv[0] );

	NSMutableArray *listeners = NULL;
	if( (listeners = eventListeners[name]) ) {
		JSObjectRef callback = JSValueToObject(ctx, argv[1], NULL);
		for( int i = 0; i < listeners.count; i++ ) {
			if( JSValueIsStrictEqual(ctx, callback, [listeners[i] pointerValue]) ) {
				[listeners removeObjectAtIndex:i];
				return NULL;
			}
		}
	}
	return NULL;
}

- (void)triggerEvent:(NSString *)name argc:(int)argc argv:(JSValueRef[])argv {
	NSArray *listeners = eventListeners[name];
	if( listeners ) {
		for( NSValue *callbackValue in listeners ) {
			[scriptView invokeCallback:[callbackValue pointerValue] thisObject:jsObject argc:argc argv:argv];
		}
	}
	
	NSValue *callbackValue = onCallbacks[name];
	if( callbackValue ) {
		[scriptView invokeCallback:[callbackValue pointerValue] thisObject:jsObject argc:argc argv:argv];
	}
}


@end
