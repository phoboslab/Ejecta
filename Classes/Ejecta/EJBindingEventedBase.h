#import "EJBindingBase.h"


// ------------------------------------------------------------------------------------
// Events; shorthand for EJ_BIND_GET/SET - use with EJ_BIND_EVENT( eventname );

#define EJ_BIND_EVENT(NAME) \
	EJ_BIND_GET(on##NAME, ctx ) { \
		return [self getCallbackWith:( @ #NAME) ctx:ctx]; \
	} \
	EJ_BIND_SET(on##NAME, ctx, callback) {\
		[self setCallbackWith:( @ #NAME) ctx:ctx callback:callback]; \
	}

@interface EJBindingEventedBase : EJBindingBase {
	NSMutableDictionary * eventListeners; // for addEventListener
	NSMutableDictionary * onCallbacks; // for on* setters
}

- (JSObjectRef)getCallbackWith:(NSString *)name ctx:(JSContextRef)ctx;
- (void)setCallbackWith:(NSString *)name ctx:(JSContextRef)ctx callback:(JSValueRef)callback;
- (void)triggerEvent:(NSString *)name argc:(int)argc argv:(JSValueRef[])argv;

@end
