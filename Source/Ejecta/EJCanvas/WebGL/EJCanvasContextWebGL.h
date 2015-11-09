#import "EJCanvasContext.h"

@class EJJavaScriptView;
@interface EJCanvasContextWebGL : EJCanvasContext {
	GLuint viewFrameBuffer, viewRenderBuffer;
	GLuint msaaFrameBuffer, msaaRenderBuffer;
	GLuint boundFrameBuffer, boundRenderBuffer;
	GLuint depthStencilBuffer;
	
	GLint bufferWidth, bufferHeight;
	EJJavaScriptView *scriptView;
}

- (id)initWithScriptView:(EJJavaScriptView *)scriptView width:(short)width height:(short)height;
- (void)resizeAuxiliaryBuffers;
- (void)bindFramebuffer:(GLuint)framebuffer toTarget:(GLuint)target;
- (void)bindRenderbuffer:(GLuint)framebuffer toTarget:(GLuint)target;
- (void)create;
- (void)prepare;
- (void)clear;

@property (nonatomic) BOOL needsPresenting;

@end
