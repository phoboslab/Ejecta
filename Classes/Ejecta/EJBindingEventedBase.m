#import "EJBindingEventedBase.h"

@implementation EJBindingEventedBase

- (id)initWithContext:(JSContextRef)ctxp object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self  = [super initWithContext:ctxp object:obj argc:argc argv:argv] ) {
		eventListeners = [[NSMutableDictionary alloc] init];
		onCallbacks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	
	// Unprotect all event callbacks
	for( NSString * name in eventListeners ) {
		NSArray * listeners = [eventListeners objectForKey:name];
		for( NSValue * callbackValue in listeners ) {
			JSValueUnprotect(ctx, [callbackValue pointerValue]);
		}
	}
	[eventListeners release];
	
	// Unprotect all event callbacks
	for( NSString * name in onCallbacks ) {
		NSValue * listener = [onCallbacks objectForKey:name];
		JSValueUnprotect(ctx, [(NSValue *)listener pointerValue]);
	}
	[onCallbacks release];
	
	[super dealloc];
}

- (JSObjectRef)getCallbackWith:(NSString *)name ctx:(JSContextRef)ctx {
	NSValue * listener = [onCallbacks objectForKey:name];
	return listener ? [listener pointerValue] : NULL;
}

- (void)setCallbackWith:(NSString *)name ctx:(JSContextRef)ctx callback:(JSValueRef)callbackValue {
	// remove old event listener?
	JSObjectRef oldCallback = [self getCallbackWith:name ctx:ctx];
	if( oldCallback ) {
		JSValueUnprotect(ctx, oldCallback);
		[onCallbacks removeObjectForKey:name];
	}
	
	JSObjectRef callback = JSValueToObject(ctx, callbackValue, NULL);
	if( JSObjectIsFunction(ctx, callback) ) {
		JSValueProtect(ctx, callback);
		[onCallbacks setObject:[NSValue valueWithPointer:callback] forKey:name];
		return;
	}
}

EJ_BIND_FUNCTION(addEventListener, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	NSString * name = JSValueToNSString( ctx, argv[0] );
	JSObjectRef callback = JSValueToObject(ctx, argv[1], NULL);
	JSValueProtect(ctx, callback);
	NSValue * callbackValue = [NSValue valueWithPointer:callback];
	
	NSMutableArray * listeners = NULL;
	if( (listeners = [eventListeners objectForKey:name]) ) {
		[listeners addObject:callbackValue];
	}
	else {
		[eventListeners setObject:[NSMutableArray arrayWithObject:callbackValue] forKey:name];
	}
	return NULL;
}

EJ_BIND_FUNCTION(removeEventListener, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	NSString * name = JSValueToNSString( ctx, argv[0] );

	NSMutableArray * listeners = NULL;
	if( (listeners = [eventListeners objectForKey:name]) ) {
		JSObjectRef callback = JSValueToObject(ctx, argv[1], NULL);
		for( int i = 0; i < listeners.count; i++ ) {
			if( JSValueIsStrictEqual(ctx, callback, [[listeners objectAtIndex:i] pointerValue]) ) {
				[listeners removeObjectAtIndex:i];
				return NULL;
			}
		}
	}
	return NULL;
}

- (void)triggerEvent:(NSString *)name argc:(int)argc argv:(JSValueRef[])argv {
	EJApp * ejecta = [EJApp instance];
	
	NSArray * listeners = [eventListeners objectForKey:name];
	if( listeners ) {
		for( NSValue * callbackValue in listeners ) {
			[ejecta invokeCallback:[callbackValue pointerValue] thisObject:jsObject argc:argc argv:argv];
		}
	}
	
	NSValue * callbackValue = [onCallbacks objectForKey:name];
	if( callbackValue ) {
		[ejecta invokeCallback:[callbackValue pointerValue] thisObject:jsObject argc:argc argv:argv];
	}
}


@end
