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
	
	EJBindingWebGLObject *binding = (EJBindingWebGLObject *)JSObjectGetPrivate((JSObjectRef)value);
	return (binding && [binding isMemberOfClass:[self class]]) ? binding->index : 0;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)view
	webglContext:(EJBindingCanvasContextWebGL *)webglContext
	index:(GLuint)index
{
	id native = [[self alloc] initWithWebGLContext:webglContext index:index];
	
	JSObjectRef obj = [self createJSObjectWithContext:ctx scriptView:view instance:native];
	[native release];
	return obj;
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
- (id)initWithWebGLContext:(EJBindingCanvasContextWebGL *)webglContextp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		webglContext = [webglContextp retain];
		texture = [[EJTexture alloc] initEmptyForWebGL];
	}
	return self;
}

- (void)dealloc {
	if( texture.textureId ) {
		[webglContext deleteTexture:texture.textureId];
	}
	[texture release];
	[super dealloc];
}

+ (EJTexture *)textureFromJSValue:(JSValueRef)value {
	if( !value ) { return NULL; }
	
	EJBindingWebGLTexture *binding = (EJBindingWebGLTexture *)JSObjectGetPrivate((JSObjectRef)value);
	return (binding && [binding isMemberOfClass:[self class]]) ? binding->texture : NULL;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)view
	webglContext:(EJBindingCanvasContextWebGL *)webglContext
{
	id native = [[self alloc] initWithWebGLContext:webglContext];
	
	JSObjectRef obj = [self createJSObjectWithContext:ctx scriptView:view instance:native];
	[native release];
	return obj;
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

@implementation EJBindingWebGLVertexArrayObjectOES
- (void)dealloc {
	[webglContext deleteVertexArray:index];
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

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)view
	size:(GLint)sizep type:(GLenum)typep name:(NSString *)namep
{
	id native = [[self alloc] initWithSize:sizep type:typep name:namep];
	
	JSObjectRef obj = [self createJSObjectWithContext:ctx scriptView:view instance:native];
	[native release];
	return obj;
}

@end


@implementation EJBindingWebGLShaderPrecisionFormat

- (id)initWithRangeMin:(GLint)rangeMinp rangeMax:(GLint)rangeMaxp precision:(GLint)precisionp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		rangeMin = rangeMinp;
		rangeMax = rangeMaxp;
		precision = precisionp;
	}
	return self;
}

EJ_BIND_GET(rangeMin, ctx) { return JSValueMakeNumber(ctx, rangeMin); }
EJ_BIND_GET(rangeMax, ctx) { return JSValueMakeNumber(ctx, rangeMax); }
EJ_BIND_GET(precision, ctx) { return JSValueMakeNumber(ctx, precision); }

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)view
	rangeMin:(GLint)rangeMin rangeMax:(GLint)rangeMax precision:(GLint)precision
{
	id native = [[self alloc] initWithRangeMin:rangeMin rangeMax:rangeMax precision:precision];
	
	JSObjectRef obj = [self createJSObjectWithContext:ctx scriptView:view instance:native];
	[native release];
	return obj;
}

@end



@implementation EJBindingWebGLContextAttributes : EJBindingBase
// FIXME: make this non-static
EJ_BIND_CONST(alpha, true);
EJ_BIND_CONST(depth, true);
EJ_BIND_CONST(stencil, false);
EJ_BIND_CONST(antialias, false);
EJ_BIND_CONST(premultipliedAlpha, false);
EJ_BIND_CONST(preserveDrawingBuffer, false);
@end

