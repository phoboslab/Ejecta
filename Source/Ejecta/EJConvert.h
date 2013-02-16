#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"


#ifdef __cplusplus
extern "C" {
#endif

NSString *JSValueToNSString( JSContextRef ctx, JSValueRef v );
JSValueRef NSStringToJSValue( JSContextRef ctx, NSString *string );
JSValueRef NSStringToJSValueProtect( JSContextRef ctx, NSString *string );
double JSValueToNumberFast( JSContextRef ctx, JSValueRef v );

#ifdef __cplusplus
}
#endif