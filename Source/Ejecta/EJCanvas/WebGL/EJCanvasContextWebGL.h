#import "EJCanvasContext.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@interface EJCanvasContextWebGL : EJCanvasContext <EJPresentable> {
	GLuint viewFrameBuffer, viewRenderBuffer;
	GLuint depthRenderBuffer;
	
	GLint bufferWidth, bufferHeight;
	EAGLView *glview;
	
	float backingStoreRatio;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
}

- (id)initWithWidth:(short)width height:(short)height;
- (void)bindRenderbuffer;
- (void)bindFramebuffer;
- (void)present;
- (void)finish;
- (void)create;
- (void)prepare;

@property (nonatomic) BOOL useRetinaResolution;
@property (nonatomic) EJScalingMode scalingMode;
@property (nonatomic,readonly) float backingStoreRatio;

@end
