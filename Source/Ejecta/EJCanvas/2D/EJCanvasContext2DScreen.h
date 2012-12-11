#import "EJCanvasContext2D.h"
#import "EAGLView.h"
#import "EJCanvasContextScreen.h"

@interface EJCanvasContext2DScreen : EJCanvasContext2D <EJCanvasContextScreen> {
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
