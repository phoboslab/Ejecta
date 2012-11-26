//
//  EJBindingShaderDOM.m
//  EjectaGL
//
//  Created by vikram on 11/26/12.
//
//

#import "EJBindingShaderDOM.h"

@implementation EJBindingShaderDOM

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj
        script:(NSString *)scriptText type:(NSString *)typeText {
	if( self = [super initWithContext:ctx object:obj argc:0 argv:NULL] ) {
        script = [scriptText retain];
        type = [typeText retain];
	}
	return self;
}

- (void)dealloc {
    [script release];
    [type release];
    [super dealloc];
}

EJ_BIND_GET(firstChild, ctx) {
    // Return self as first child!
    return jsObject;
}

EJ_BIND_GET(nextSibling, ctx) {
    // No other siblings.
    return NULL;
}

EJ_BIND_GET(nodeType, ctx) {
    // Just return the only node as text node.
    return JSValueMakeNumber(ctx, 3);
}

EJ_BIND_GET(textContent, ctx) {
	JSStringRef jsScript = JSStringCreateWithUTF8CString([script UTF8String]);
	JSValueRef ret = JSValueMakeString(ctx, jsScript);
	JSStringRelease(jsScript);
	return ret;
}

EJ_BIND_GET(type, ctx) {
	JSStringRef jsType = JSStringCreateWithUTF8CString([type UTF8String]);
	JSValueRef ret = JSValueMakeString(ctx, jsType);
	JSStringRelease(jsType);
	return ret;
}

@end
