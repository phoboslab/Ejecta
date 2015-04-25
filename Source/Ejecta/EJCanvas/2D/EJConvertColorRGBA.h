#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJCanvas2DTypes.h"

#ifdef __cplusplus
extern "C" {
#endif

EJColorRGBA JSValueToColorRGBA( JSContextRef ctx, JSValueRef value );
JSValueRef ColorRGBAToJSValue( JSContextRef ctx, EJColorRGBA c );
UIColor* JSValueToUIColor(JSContextRef ctx, JSValueRef value);
    
#ifdef __cplusplus
}
#endif