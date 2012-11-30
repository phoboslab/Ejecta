//
//  EJBindingUint16Array.m
//  EjectaGL
//
//  Created by vikram on 11/26/12.
//
//

#import "EJBindingUint16Array.h"

@implementation EJBindingUint16Array

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
        if ( JSValueIsObject(ctx, argv[0]) ) {
            
            // If the parameter is an object it is an array object with values.
            JSObjectRef jsArray = (JSObjectRef)argv[0];
            JSStringRef jsProp = JSStringCreateWithUTF8CString("length");
            JSValueRef jsLength = JSObjectGetProperty(ctx, jsArray, jsProp, NULL);
            JSStringRelease(jsProp);
            
            length = (size_t) JSValueToNumberFast(ctx, jsLength);
            array = (UInt16 *)malloc(length * sizeof(UInt16));
            
            for ( int i = 0; i < length; i++ ) {
                array[i] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
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
    return length * sizeof(UInt16);
}

- (void *)data {
    return (void *)array;
}

EJ_BIND_GET(length, ctx) {
	return JSValueMakeNumber(ctx, length);
}

@end
