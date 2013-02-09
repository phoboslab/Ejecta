#import <Foundation/Foundation.h>
#import "EJBindingBase.h"

JSValueRef ej_global_undefined;
JSClassRef ej_constructorClass;
JSValueRef ej_getNativeClass(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception);
JSObjectRef ej_callAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception);

@interface EJUtils : NSObject

@end
