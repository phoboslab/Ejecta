// The binding for the CanvasGradient. It's just a wrapper around the actual
// EJCanvasGradient implementation, so a gradient can be manipulated and passed
// around in JavaScript.

#import "EJBindingBase.h"
#import "EJCanvasGradient.h"

@interface EJBindingCanvasGradient : EJBindingBase {
	EJCanvasGradient *gradient;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)scriptView
	gradient:(EJCanvasGradient *)gradient;
+ (EJCanvasGradient *)gradientFromJSValue:(JSValueRef)value;

@end
