// The binding for the CanvasPattern. It's just a wrapper around the actual
// EJCanvasPattern implementation, so a pattern can be passed around in
// JavaScript.

#import "EJBindingBase.h"
#import "EJCanvasPattern.h"

@interface EJBindingCanvasPattern : EJBindingBase {
	EJCanvasPattern *pattern;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)scriptView
	pattern:(EJCanvasPattern *)pattern;
+ (EJCanvasPattern *)patternFromJSValue:(JSValueRef)value;

@end
