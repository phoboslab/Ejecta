#import "EJBindingCanvasPattern.h"

@implementation EJBindingCanvasPattern

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx pattern:(EJCanvasPattern *)pattern {
	EJBindingCanvasPattern *binding = [[EJBindingCanvasPattern alloc] initWithContext:ctx argc:0 argv:NULL];
	binding->pattern = pattern;
	
	return [self createJSObjectWithContext:ctx instance:binding];
}

+ (EJCanvasPattern *)patternFromJSValue:(JSValueRef)value {
	if( !value ) { return NULL; }
	
	EJBindingCanvasPattern *binding = JSValueGetNativeObject(value);
	return (binding && [binding isMemberOfClass:[EJBindingCanvasPattern class]]) ? binding->pattern : NULL;
}


@end
