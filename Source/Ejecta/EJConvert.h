#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"


#ifdef __cplusplus
extern "C" {
#endif

NSString *JSValueToNSString( JSContextRef ctx, JSValueRef v );
JSValueRef NSStringToJSValue( JSContextRef ctx, NSString *string );
JSValueRef NSStringToJSValueProtect( JSContextRef ctx, NSString *string );
double JSValueToNumberFast( JSContextRef ctx, JSValueRef v );

static inline __unsafe_unretained id JSValueGetNativeObject( JSValueRef v ) {
	return (__bridge __unsafe_unretained id)JSObjectGetPrivate((JSObjectRef)v);
}

#ifdef __cplusplus
}
#endif