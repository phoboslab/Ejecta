#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"


#ifdef __cplusplus
extern "C" {
#endif

NSString *JSValueToNSString( JSContextRef ctx, JSValueRef v );
JSValueRef NSStringToJSValue( JSContextRef ctx, NSString *string );
double JSValueToNumberFast( JSContextRef ctx, JSValueRef v );
void JSValueUnprotectSafe( JSContextRef ctx, JSValueRef v );
JSValueRef NSObjectToJSValue( JSContextRef ctx, NSObject *obj );
NSObject *JSValueToNSObject( JSContextRef ctx, JSValueRef value );

#ifdef __cplusplus
}
#endif