//
//  EJBindingFloat32Array.m
//  EjectaGL
//
//  Created by vikram on 11/25/12.
//
//

#import "EJBindingFloat32Array.h"

#import "EJBindingFloat32Array.h"

@implementation EJBindingFloat32Array

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj
                 argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
        // Support only other arrays as constructor parameter.
        // TODO(vikram): Atleast add support for other Float32Array-s
        if (JSValueIsObject(ctx, argv[0])) {
            
            // If the parameter is an object it is an array object with values.
            JSObjectRef jsArray = (JSObjectRef)argv[0];
            JSStringRef jsProp = JSStringCreateWithUTF8CString("length");
            JSValueRef jsLength = JSObjectGetProperty(ctx, jsArray, jsProp, NULL);
            JSStringRelease(jsProp);
            
            length = (size_t) JSValueToNumberFast(ctx, jsLength);
            array = (float *)malloc(length * sizeof(float));
            
            for (int i = 0; i < length; i++) {
                array[i] = JSValueToNumberFast(ctx,
                        JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
        }
	}
	return self;
}

- (void)dealloc {
    free(array);
    [super dealloc];
}

- (uint)size {
    return length * sizeof(float);
}

- (void *)data {
    return (void *)array;
}

EJ_BIND_GET(length, ctx) {
	return JSValueMakeNumber(ctx, length);
}

@end
