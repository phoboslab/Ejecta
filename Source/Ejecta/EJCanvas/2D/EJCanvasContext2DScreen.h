// The EJCanvas2D subclass that handles rendering to the screen (i.e. a UIView)

#import "EJCanvasContext2D.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@interface EJCanvasContext2DScreen : EJCanvasContext2D <EJPresentable> {
	EAGLView *glview;
	CGRect style;
}

- (void)present;
- (void)finish;

@property (readonly, nonatomic) EJTexture *texture;

@end
