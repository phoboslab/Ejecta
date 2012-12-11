#import "EJCanvasContext2D.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@interface EJCanvasContext2DScreen : EJCanvasContext2D <EJPresentable> {
	EAGLView * glview;
	GLuint colorRenderbuffer;
	
	BOOL useRetinaResolution;
	UIDeviceOrientation orientation;
	EJScalingMode scalingMode;
}

- (void)present;
- (void)finish;

@property (nonatomic) BOOL useRetinaResolution;
@property (nonatomic) EJScalingMode scalingMode;

@end
