// EJBindingEventedBase sits on top of EJBindingBase and provides some functions
// for classes that want to implement events and host event listeners.

// Events can be attached and removed from instances of this class from
// JavaScript with the addEventListener() and removeEventListener() methods
// or through `.onsomeevent = callback;` properties.

// The EJBindingEvent class provides an implementation of an Event object
// itself which will be passed to the callback.

#import "EJBindingBase.h"




// Events; shorthand for EJ_BIND_GET/SET - use with EJ_BIND_EVENT( eventname );

#define EJ_BIND_EVENT(NAME) \
	static JSValueRef _get_on##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		EJBindingEventedBase *instance = (EJBindingEventedBase*)JSObjectGetPrivate(object); \
		return [instance getCallbackWithType:( @ #NAME) ctx:ctx]; \
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
		EJBindingEventedBase *instance = (EJBindingEventedBase*)JSObjectGetPrivate(object); \
		[instance setCallbackWithType:( @ #NAME) ctx:ctx callback:value]; \
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

- (JSValueRef)getCallbackWithType:(NSString *)type ctx:(JSContextRef)ctx;
- (void)setCallbackWithType:(NSString *)type ctx:(JSContextRef)ctx callback:(JSValueRef)callback;
- (void)triggerEvent:(NSString *)type argc:(int)argc argv:(JSValueRef[])argv;
- (void)triggerEvent:(NSString *)type properties:(JSEventProperty[])properties;
- (void)triggerEvent:(NSString *)type;

@end



@interface EJBindingEvent : EJBindingBase {
	NSString *type;
	JSObjectRef jsTarget;
	JSValueRef jsTimestamp;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)scriptView
	type:(NSString *)type
	target:(JSObjectRef)target;
	
@end

