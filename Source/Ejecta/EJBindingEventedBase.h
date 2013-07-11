#import "EJBindingBase.h"


// ------------------------------------------------------------------------------------
// Events; shorthand for EJ_BIND_GET/SET - use with EJ_BIND_EVENT( eventname );

#define EJ_BIND_EVENT(NAME) \
	static JSValueRef _get_on##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(getCallbackWith:ctx:), ( @ #NAME), ctx); \
	} \
	__EJ_GET_POINTER_TO(_get_on##NAME) \
	\
	static bool _set_on##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef value, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		objc_msgSend(instance, @selector(setCallbackWith:ctx:callback:), ( @ #NAME), ctx, value); \
		return true; \
	} \
	__EJ_GET_POINTER_TO(_set_on##NAME)


typedef struct {
	const char *name;
	JSValueRef value;
} JSEventProperty;
	
@interface EJBindingEventedBase : EJBindingBase {
	NSMutableDictionary *eventListeners; // for addEventListener
	NSMutableDictionary *onCallbacks; // for on* setters
}

- (JSObjectRef)getCallbackWith:(NSString *)type ctx:(JSContextRef)ctx;
- (void)setCallbackWith:(NSString *)type ctx:(JSContextRef)ctx callback:(JSValueRef)callback;
- (void)triggerEvent:(NSString *)type argc:(int)argc argv:(JSValueRef[])argv;
- (void)triggerEvent:(NSString *)type properties:(JSEventProperty[])properties;
- (void)triggerEvent:(NSString *)type;

@end


@interface EJBindingEvent : EJBindingBase {
	NSString *type;
	JSObjectRef jsTarget;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)scriptView
	type:(NSString *)type
	target:(JSObjectRef)target;
	
@end

