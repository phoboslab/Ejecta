#import "EJCanvasContext.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@class EJJavaScriptView;
@interface EJCanvasContextWebGL : EJCanvasContext <EJPresentable> {
	GLuint viewFrameBuffer, viewRenderBuffer;
	GLuint depthRenderBuffer;
	
	GLint bufferWidth, bufferHeight;
	EAGLView *glview;
	EJJavaScriptView *scriptView;
	
	float backingStoreRatio;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
}

- (id)initWithScriptView:(EJJavaScriptView *)scriptView width:(short)width height:(short)height;
- (void)bindRenderbuffer;
- (void)bindFramebuffer;
- (void)present;
- (void)finish;
- (void)create;
- (void)prepare;

@property (nonatomic) BOOL needsPresenting;
@property (nonatomic) BOOL useRetinaResolution;
@property (nonatomic) EJScalingMode scalingMode;
@property (nonatomic,readonly) float backingStoreRatio;

@end
