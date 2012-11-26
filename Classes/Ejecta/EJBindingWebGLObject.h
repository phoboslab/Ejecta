//
//  EJBindingWebGLObject.h
//  EjectaGL
//
//  Created by vikram on 11/25/12.
//
//

#import <Foundation/Foundation.h>
#import "EJBindingBase.h"

@interface EJBindingWebGLObject : EJBindingBase {
    GLuint index;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj
                index:(GLuint)buffer;

@property GLuint index;

@end
