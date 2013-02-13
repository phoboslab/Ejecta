#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

JSValueRef _EJGlobalUndefined;
JSClassRef _EJGlobalConstructorClass;
JSValueRef EJGetNativeClass(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception);
JSObjectRef EJCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception);

@interface EJClassLoader : NSObject {
	JSGlobalContextRef context;
}

+ (JSClassRef)getJSClass:(id)class;
+ (JSClassRef)createJSClass:(id)class;

- (id)initWithGlobalContext:(JSGlobalContextRef)context name:(NSString *)name;

@end