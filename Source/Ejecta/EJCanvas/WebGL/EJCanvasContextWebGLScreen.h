#import "EJCanvasContextWebGL.h"
#import "EAGLView.h"
#import "EJPresentable.h"
#import "EJTexture.h"

@interface EJCanvasContextWebGLScreen : EJCanvasContextWebGL <EJPresentable> {
	EAGLView *glview;
	CGRect style;
	EJTexture *texture;
}

- (void)present;
- (void)finish;

@end
