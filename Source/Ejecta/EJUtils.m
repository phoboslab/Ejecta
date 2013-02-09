#import "EJUtils.h"

// ---------------------------------------------------------------------------------
// JavaScript callback functions to retrieve and create instances of a native class

JSValueRef ej_global_undefined;

JSClassRef ej_constructorClass;

JSValueRef ej_getNativeClass(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception) {
	CFStringRef className = JSStringCopyCFString( kCFAllocatorDefault, propertyNameJS );
	
	JSObjectRef obj = NULL;
	NSString *fullClassName = [NSString stringWithFormat:@"EJBinding%@", className];
	id class = NSClassFromString(fullClassName);
	if( class ) {
		obj = JSObjectMake( ctx, ej_constructorClass, (void *)class );
	}
	
	CFRelease(className);
	return obj ? obj : ej_global_undefined;
}

JSObjectRef ej_callAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
	Class class = (Class)JSObjectGetPrivate(constructor);
	EJBindingBase *instance = [(EJBindingBase *)[class alloc] initWithContext:ctx argc:argc argv:argv];
	return [class createJSObjectWithContext:ctx instance:instance];
}

@implementation EJUtils

@end
