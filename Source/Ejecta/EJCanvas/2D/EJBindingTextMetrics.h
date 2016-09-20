// The binding class for an EJTextMetrics struct as created by an EJFontLayout
// instance.

#import "EJBindingBase.h"
#import "EJFont.h"

@interface EJBindingTextMetrics : EJBindingBase {
	EJTextMetrics metrics;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx scriptView:(EJJavaScriptView *)scriptView metrics:(EJTextMetrics)metrics;

@end
