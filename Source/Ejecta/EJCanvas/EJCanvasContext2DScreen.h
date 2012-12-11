#import "EJCanvasContext2D.h"
#import "EAGLView.h"

typedef enum {
	kEJScalingModeNone,
	kEJScalingModeFitWidth,
	kEJScalingModeFitHeight
} EJScalingMode;

@interface EJCanvasContext2DScreen : EJCanvasContext2D {
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
