//
//  EJBindingWebGLUniformLocation.m
//  EjectaGL
//
//  Created by vikram on 11/25/12.
//
//

#import "EJBindingWebGLUniformLocation.h"

@implementation EJBindingWebGLUniformLocation

+ (EJBindingWebGLUniformLocation *)fromJSValueRef:(JSValueRef)obj {
    return (EJBindingWebGLUniformLocation *)JSObjectGetPrivate((JSObjectRef)obj);
}

@end
