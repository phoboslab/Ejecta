#import "EJBindingWebGLObjects.h"

@implementation EJBindingWebGLObject

- (id)initWithWebGLContext:(EJBindingCanvasContextWebGL *)webglContextp index:(GLuint)indexp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		webglContext = [webglContextp retain];
		index = indexp;
	}
	return self;
}

- (void)dealloc {
	[webglContext release];
	[super dealloc];
}

+ (GLuint)indexFromJSValue:(JSValueRef)value {
	if( !value ) { return 0; }
	
	EJBindingWebGLObject * binding = (EJBindingWebGLObject *)JSObjectGetPrivate((JSObjectRef)value);
	return (binding && [binding isMemberOfClass:[self class]]) ? binding->index : 0;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx webglContext:(EJBindingCanvasContextWebGL *)webglContext index:(GLuint)index {
	id native = [[self alloc] initWithWebGLContext:webglContext index:index];
	return [self createJSObjectWithContext:ctx instance:native];
}

@end


@implementation EJBindingWebGLBuffer
- (void)dealloc {
	[webglContext deleteBuffer:index];
	[super dealloc];
}
@end

@implementation EJBindingWebGLProgram
- (void)dealloc {
	[webglContext deleteProgram:index];
	[super dealloc];
}
@end

@implementation EJBindingWebGLShader
- (void)dealloc {
	[webglContext deleteShader:index];
	[super dealloc];
}
@end

@implementation EJBindingWebGLTexture
- (void)dealloc {
	[webglContext deleteTexture:index];
	[super dealloc];
}
@end

@implementation EJBindingWebGLUniformLocation
// nothing to delete
@end

@implementation EJBindingWebGLRenderbuffer
- (void)dealloc {
	[webglContext deleteRenderbuffer:index];
	[super dealloc];
}
@end

@implementation EJBindingWebGLFramebuffer
- (void)dealloc {
	[webglContext deleteFramebuffer:index];
	[super dealloc];
}
@end


@implementation EJBindingWebGLActiveInfo

- (id)initWithSize:(GLint)sizep type:(GLenum)typep name:(NSString *)namep {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		size = sizep;
		type = typep;
		name = [namep retain];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[super dealloc];
}

EJ_BIND_GET(size, ctx) { return JSValueMakeNumber(ctx, size); }
EJ_BIND_GET(type, ctx) { return JSValueMakeNumber(ctx, type); }
EJ_BIND_GET(name, ctx) { return NSStringToJSValue(ctx, name); }

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx size:(GLint)sizep type:(GLenum)typep name:(NSString *)namep {
	id native = [[self alloc] initWithSize:sizep type:typep name:namep];
	return [self createJSObjectWithContext:ctx instance:native];
}

@end

