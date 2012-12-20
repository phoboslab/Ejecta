#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContextWebGL.h"

#define EJ_UNPACK_FLIP_Y_WEBGL 0x9240
#define EJ_UNPACK_PREMULTIPLY_ALPHA_WEBGL 0x9241
#define EJ_CONTEXT_LOST_WEBGL 0x9242
#define EJ_UNPACK_COLORSPACE_CONVERSION_WEBGL 0x9243
#define EJ_BROWSER_DEFAULT_WEBGL 0x9244

GLfloat * JSValueToGLfloatArray(JSContextRef ctx, JSValueRef value, size_t expectedSize);
GLint * JSValueToGLintArray(JSContextRef ctx, JSValueRef value, size_t expectedSize);

@interface EJBindingCanvasContextWebGL : EJBindingBase {
	
	BOOL unpackFlipY;
	BOOL premultiplyAlpha;
	
	JSObjectRef jsCanvas;
	EJCanvasContextWebGL * renderingContext;
	EJApp * ejectaInstance;
	
	NSMutableDictionary * renderbuffers;
	NSMutableDictionary * framebuffers;
	NSMutableDictionary * buffers;
	NSMutableDictionary * programs;
	NSMutableDictionary * shaders;
	NSMutableDictionary * textures;
}

- (id)initWithCanvas:(JSObjectRef)canvas renderingContext:(EJCanvasContextWebGL *)renderingContextp;

- (void)deleteRenderbuffer:(GLuint)renderbuffer;
- (void)deleteFramebuffer:(GLuint)framebuffer;
- (void)deleteBuffer:(GLuint)buffer;
- (void)deleteProgram:(GLuint)program;
- (void)deleteShader:(GLuint)shader;
- (void)deleteTexture:(GLuint)texture;

@end
