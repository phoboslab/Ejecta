#import "EJBindingBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"
#import "EJCanvasContext.h"

typedef enum {
	kEJCanvasContextModeInvalid,
	kEJCanvasContextMode2D,
	kEJCanvasContextModeWebGL
} EJCanvasContextMode;

@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
	JSObjectRef jsCanvasContext;
	EJCanvasContext * renderingContext;
	EJCanvasContextMode contextMode;
	short width, height;
	
	BOOL isScreenCanvas;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
	
	BOOL msaaEnabled;
	int msaaSamples;
}

@property (readonly, nonatomic) EJTexture * texture;

@end
