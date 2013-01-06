#import "EJBindingBase.h"
#import "EJCanvasPattern.h"

@interface EJBindingCanvasPattern : EJBindingBase {
	EJCanvasPattern * pattern;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx pattern:(EJCanvasPattern *)pattern;
+ (EJCanvasPattern *)patternFromJSValue:(JSValueRef)value;

@end
