#import <Foundation/Foundation.h>
#import "EJApp.h"

#include <objc/message.h>

extern JSValueRef ej_global_undefined;

// (Not sure if clever hack or really stupid...)

// All classes derived from this JS_BaseClass will return a JSClassRef through the 
// 'getJSClass' class method. The properties and functions that are exposed to 
// JavaScript are defined through the 'staticFunctions' and 'staticValues' in this 
// JSClassRef.

// Since these functions don't have extra data (e.g. a void*), we have to define a 
// C callback function for each js function, for each js getter and for each js setter.

// Furthermore, a class method is added to the objc class to return the function pointer
// to the particular C callback function - this way we can later inflect the objc class
// and gather all function pointers.


// The class method that returns a pointer to the static C callback function
#define __EJ_GET_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}


// ------------------------------------------------------------------------------------
// Function - use with EJ_BIND_FUNCTION( functionName, ctx, argc, argv ) { ... }

#define EJ_BIND_FUNCTION(NAME, CTX_NAME, ARGC_NAME, ARGV_NAME) \
	\
	/* The C callback function for the exposed method and class method that returns it */ \
	static JSValueRef _func_##NAME( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		JSValueRef ret = (JSValueRef)objc_msgSend(instance, @selector(_func_##NAME:argc:argv:), ctx, argc, argv); \
		return ret ? ret : ej_global_undefined; \
	} \
	__EJ_GET_POINTER_TO(_func_##NAME)\
	\
	/* The actual implementation for this method */ \
	- (JSValueRef)_func_##NAME:(JSContextRef)CTX_NAME argc:(size_t)ARGC_NAME argv:(const JSValueRef [])ARGV_NAME


// ------------------------------------------------------------------------------------
// Getter - use with EJ_BIND_GET( propertyName, ctx ) { ... }

#define EJ_BIND_GET(NAME, CTX_NAME) \
	\
	/* The C callback function for the exposed getter and class method that returns it */ \
	static JSValueRef _get_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(_get_##NAME:), ctx); \
	} \
	__EJ_GET_POINTER_TO(_get_##NAME)\
	\
	/* The actual implementation for this getter */ \
	- (JSValueRef)_get_##NAME:(JSContextRef)CTX_NAME


// ------------------------------------------------------------------------------------
// Setter - use with EJ_BIND_SET( propertyName, ctx, value ) { ... }

#define EJ_BIND_SET(NAME, CTX_NAME, VALUE_NAME) \
	\
	/* The C callback function for the exposed setter and class method that returns it */ \
	static bool _set_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef value, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		objc_msgSend(instance, @selector(_set_##NAME:value:), ctx, value); \
		return true; \
	} \
	__EJ_GET_POINTER_TO(_set_##NAME) \
	\
	/* The actual implementation for this setter */ \
	- (void)_set_##NAME:(JSContextRef)CTX_NAME value:(JSValueRef)VALUE_NAME
		


// ------------------------------------------------------------------------------------
// Shorthand to define a function that logs a "not implemented" warning

#define EJ_BIND_FUNCTION_NOT_IMPLEMENTED(NAME) \
	EJ_BIND_FUNCTION( NAME, ctx, argc, argv ) { \
		static bool didShowWarning; \
		if( !didShowWarning ) { \
			NSLog(@"Warning: method " @ #NAME @" is not yet implemented!"); \
			didShowWarning = true; \
		} \
		return NULL; \
	}


// ------------------------------------------------------------------------------------
// Shorthand to bind enums with name tables - use with
// EJ_BIND_ENUM( name, target, EJ_ENUM_NAMES("name1", "name2", ...) );

#define EJ_ENUM_NAMES(...) __VA_ARGS__ 
#define EJ_BIND_ENUM(NAME, TARGET, ENUM_NAMES) \
	static const char * _##NAME##EnumNames[] = {ENUM_NAMES}; \
	EJ_BIND_GET(NAME, ctx) { \
		JSStringRef src = JSStringCreateWithUTF8CString( _##NAME##EnumNames[TARGET] ); \
		JSValueRef ret = JSValueMakeString(ctx, src); \
		JSStringRelease(src); \
		return ret; \
	} \
	\
	EJ_BIND_SET(NAME, ctx, value) { \
		JSStringRef str = JSValueToStringCopy(ctx, value, NULL); \
		const JSChar * strptr = JSStringGetCharactersPtr( str ); \
		int length = JSStringGetLength(str)-1; \
		for( int i = 0; i < sizeof(_##NAME##EnumNames)/sizeof(_##NAME##EnumNames[0]); i++ ) { \
			if( JSStrIsEqualToStr( strptr, _##NAME##EnumNames[i], length) ) { \
				TARGET = i; \
				break; \
			} \
		} \
		JSStringRelease( str );\
	}
	
static inline bool JSStrIsEqualToStr( const JSChar * s1, const char * s2, int length ) {
	for( int i = 0; i < length && *s1 == *s2; i++ ) {
		s1++;
		s2++;
	}
	return (*s1 == *s2);
}


// ------------------------------------------------------------------------------------
// Shorthand to bind const numbers

#define EJ_BIND_CONST(NAME, VALUE) \
	static JSValueRef _get_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		return JSValueMakeNumber(ctx, VALUE); \
	} \
	__EJ_GET_POINTER_TO(_get_##NAME)
	


@interface EJBindingBase : NSObject {
	JSObjectRef jsObject;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv;
+ (JSClassRef)getJSClass;
+ (JSClassRef)createJSClass;
+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx instance:(EJBindingBase *)instance;

@end
