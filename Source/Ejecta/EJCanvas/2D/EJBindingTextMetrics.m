#import "EJBindingTextMetrics.h"

@implementation EJBindingTextMetrics

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx metrics:(EJTextMetrics)metrics {
	EJBindingTextMetrics *binding = [[EJBindingTextMetrics alloc] initWithContext:ctx argc:0 argv:NULL];
	binding->metrics = metrics;
	
	return [self createJSObjectWithContext:ctx instance:binding];
}

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, metrics.width);
}

EJ_BIND_GET(actualBoundingBoxAscent, ctx) {
	return JSValueMakeNumber(ctx, metrics.ascent);
}

EJ_BIND_GET(actualBoundingBoxDescent, ctx) {
	return JSValueMakeNumber(ctx, metrics.descent);
}

@end
