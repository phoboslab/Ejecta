#import "EJBindingBase.h"
#import "EJFont.h"

@interface EJBindingTextMetrics : EJBindingBase {
	EJTextMetrics metrics;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx metrics:(EJTextMetrics)metrics;

@end
