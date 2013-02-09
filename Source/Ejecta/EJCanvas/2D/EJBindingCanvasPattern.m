#import "EJBindingCanvasPattern.h"

@implementation EJBindingCanvasPattern

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx pattern:(EJCanvasPattern *)pattern {
	EJBindingCanvasPattern *binding = [[EJBindingCanvasPattern alloc] initWithContext:ctx argc:0 argv:NULL];
	binding->pattern = [pattern retain];
	
	return [self createJSObjectWithContext:ctx instance:binding];
}

+ (EJCanvasPattern *)patternFromJSValue:(JSValueRef)value {
	if( !value ) { return NULL; }
	
	EJBindingCanvasPattern *binding = (EJBindingCanvasPattern *)JSObjectGetPrivate((JSObjectRef)value);
	return (binding && [binding isMemberOfClass:[EJBindingCanvasPattern class]]) ? binding->pattern : NULL;
}

- (void)dealloc {
	[pattern release];
	[super dealloc];
}

@end
