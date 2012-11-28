#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJCanvas/EJCanvasTypes.h"


#ifdef __cplusplus
extern "C" {
#endif

NSString * JSValueToNSString( JSContextRef ctx, JSValueRef v );
JSValueRef NSStringToJSValue( JSContextRef ctx, NSString * string );
JSValueRef NSStringToJSValueProtect( JSContextRef ctx, NSString * string );
double JSValueToNumberFast( JSContextRef ctx, JSValueRef v );

EJColorRGBA JSValueToColorRGBA(JSContextRef ctx, JSValueRef value);
JSValueRef ColorRGBAToJSValue( JSContextRef ctx, EJColorRGBA c );

JSObjectRef ByteArrayToJSObject( JSContextRef ctx, unsigned char * bytes, int count );
void JSObjectToByteArray( JSContextRef ctx, JSObjectRef array, unsigned char * bytes, int count );

#ifdef __cplusplus
}
#endif