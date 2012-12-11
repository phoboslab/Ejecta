#import "EJBindingBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"
#import "EJCanvasContext.h"
#import "EJCanvasContextScreen.h"

typedef enum {
	kEJCanvasContextMode2D,
	kEJCanvasContextModeWebGL
} EJCanvasContextMode;

static const char * EJScalingModeNames[] = {
	[kEJScalingModeNone] = "none",
	[kEJScalingModeFitWidth] = "fit-width",
	[kEJScalingModeFitHeight] = "fit-height"
};

@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
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
