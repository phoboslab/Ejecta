#import "EJBindingBase.h"
#import "EJClassLoader.h"
#import <objc/runtime.h>


@implementation EJBindingBase

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super init] ) {
	}
	return self;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx instance:(EJBindingBase *)instance {
	// Create JSObject with the JSClass for this ObjC-Class
	JSObjectRef obj = JSObjectMake( ctx, [EJClassLoader getJSClass:self], NULL );
	
	// The JSObject retains the instance; it will be released by EJBindingBaseFinalize
	JSObjectSetPrivate( obj, (void *)[instance retain] );
	instance->jsObject = obj;
	
	return obj;
}

void EJBindingBaseFinalize(JSObjectRef object) {
	id instance = (id)JSObjectGetPrivate(object);
	[instance release];
}


@end
