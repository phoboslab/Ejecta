#import "EJBindingWebGLExtensions.h"
#import "EJBindingCanvasContextWebGL.h"

static NSMutableDictionary *openGLToWebGLMap = nil;
static NSMutableDictionary *webGLToOpenGLMap = nil;

static void addToMap(NSMutableDictionary **dict, NSString *key, NSString *value) {
    if( !(*dict) ) {
        *dict = [NSMutableDictionary new];
    }
    
    [(*dict) setObject:value forKey:key];
}

static void addOpenGLToWebGL(NSString *openGLName, NSString *webGLName) {
    addToMap(&openGLToWebGLMap, openGLName, webGLName);
}

static void addWebGLToOpenGL(NSString *webGLName, NSString *openGLName) {
    addToMap(&webGLToOpenGLMap, webGLName, openGLName);
}

NSString *getWebGLExtensionNameFromOpenGL(NSString *openGLName) {
    return openGLToWebGLMap[openGLName];
}

NSString *getOpenGLExtensionNameFromWebGL(NSString *webGLName) {
    return webGLToOpenGLMap[webGLName];
}

const NSArray *getWebGLExtensions() {
    return [webGLToOpenGLMap allKeys];
}

@implementation EJBindingWebGLExtension

- (id)initWithWebGLContext:(EJBindingCanvasContextWebGL *)webglContextp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		webglContext = [webglContextp retain];
	}
	return self;
}

- (void)dealloc {
	[webglContext release];
	[super dealloc];
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


@EJ_GL_EXTENSION_IMPLEMENTATION(EXT_texture_filter_anisotropic)

EJ_BIND_CONST_GL(MAX_TEXTURE_MAX_ANISOTROPY_EXT);
EJ_BIND_CONST_GL(TEXTURE_MAX_ANISOTROPY_EXT);

@EJ_GL_EXTENSION_END


@EJ_GL_EXTENSION_IMPLEMENTATION(OES_texture_float)
@EJ_GL_EXTENSION_END


@EJ_GL_EXTENSION_IMPLEMENTATION(OES_texture_half_float)

EJ_BIND_CONST_GL(HALF_FLOAT_OES);

@EJ_GL_EXTENSION_END


@EJ_GL_EXTENSION_IMPLEMENTATION(OES_standard_derivatives)
@EJ_GL_EXTENSION_END


@EJ_GL_EXTENSION_IMPLEMENTATION(OES_vertex_array_object)

EJ_BIND_FUNCTION(createVertexArrayOES, ctx, argc, argv) {
    GLuint vertexArray;
    scriptView.currentRenderingContext = webglContext.renderingContext;
    glGenVertexArraysOES(1, &vertexArray);
	JSObjectRef obj = [EJBindingWebGLVertexArrayObjectOES createJSObjectWithContext:ctx
        scriptView:scriptView webglContext:webglContext index:vertexArray];
    [webglContext addVertexArray:vertexArray obj:obj];
    return obj;
}

EJ_BIND_FUNCTION(deleteVertexArrayOES, ctx, argc, argv) { \
    if( argc < 1 ) { return NULL; }
    GLuint index = [EJBindingWebGLVertexArrayObjectOES indexFromJSValue:argv[0]];
    [webglContext deleteVertexArray:index];
    return NULL;
}

EJ_BIND_FUNCTION(isVertexArrayOES, ctx, argc, argv) {
    if( argc < 1 ) { return NULL; }
    scriptView.currentRenderingContext = webglContext.renderingContext;
    GLuint index = [EJBindingWebGLVertexArrayObjectOES indexFromJSValue:argv[0]];
    return JSValueMakeBoolean(ctx, glIsVertexArrayOES(index));
}

EJ_BIND_FUNCTION(bindVertexArrayOES, ctx, argc, argv) {
    if( argc < 1 ) { return NULL; }
    scriptView.currentRenderingContext = webglContext.renderingContext;
    GLuint index = [EJBindingWebGLVertexArrayObjectOES indexFromJSValue:argv[0]];
    glBindVertexArrayOES(index);
    return NULL;
}

// Constants
EJ_BIND_CONST_GL(VERTEX_ARRAY_BINDING_OES);

@EJ_GL_EXTENSION_END
