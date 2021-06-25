// JSValueToColorRGBA and ColorRGBAToJSValue convert from JavaScript strings
// to EJColorRGBA and vice versa.

// JSValueToColorRGBA accepts colors in hex, rgb(a) and hsl(a) formats and
// all 140 HTML color names. E.g.:
// "#f0f", "#ff00ff", "rgba(255, 0, 255, 1)", "magenta"

// ColorRGBAToJSValue always converts the color to an rgba string, because I'm
// lazy.

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
