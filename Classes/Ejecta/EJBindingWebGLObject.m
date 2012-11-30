//
//  EJBindingWebGLObject.m
//  EjectaGL
//
//  Created by vikram on 11/25/12.
//
//

#import "EJBindingWebGLObject.h"

@implementation EJBindingWebGLObject

@synthesize index;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj index:(GLuint)buffer {
	if( self = [super initWithContext:ctx object:obj argc:0 argv:NULL] ) {
        index = buffer;
	}
	return self;
}

@end
