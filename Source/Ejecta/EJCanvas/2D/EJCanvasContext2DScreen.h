#import "EJCanvasContext2D.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@interface EJCanvasContext2DScreen : EJCanvasContext2D <EJPresentable> {
	EAGLView *glview;	
	EJScalingMode scalingMode;
}

- (void)present;
- (void)finish;

@property (nonatomic) EJScalingMode scalingMode;

@end
