#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContextTexture.h"
#import "EJCanvasContextScreen.h"
#import "EJTexture.h"
#import "EJDrawable.h"

static const char * EJLineCapNames[] = {
	[kEJLineCapButt] = "butt",
	[kEJLineCapRound] = "round",
	[kEJLineCapSquare] = "square"
};

static const char * EJLineJoinNames[] = {
	[kEJLineJoinMiter] = "miter",
	[kEJLineJoinBevel] = "bevel",
	[kEJLineJoinRound] = "round"
};

static const char * EJTextBaselineNames[] = {
	[kEJTextBaselineAlphabetic] = "alphabetic",
	[kEJTextBaselineMiddle] = "middle",
	[kEJTextBaselineTop] = "top",
	[kEJTextBaselineHanging] = "hanging",
	[kEJTextBaselineBottom] = "bottom",
	[kEJTextBaselineIdeographic] = "ideographic"
};

static const char * EJTextAlignNames[] = {
	[kEJTextAlignStart] = "start",
	[kEJTextAlignEnd] = "end",
	[kEJTextAlignLeft] = "left",
	[kEJTextAlignCenter] = "center",
	[kEJTextAlignRight] = "right"
};

static const char * EJCompositeOperationNames[] = {
	[kEJCompositeOperationSourceOver] = "source-over",
	[kEJCompositeOperationLighter] = "lighter",
	[kEJCompositeOperationDarker] = "darker",
	[kEJCompositeOperationDestinationOut] = "destination-out",
	[kEJCompositeOperationDestinationOver] = "destination-over",
	[kEJCompositeOperationSourceAtop] = "source-atop",
	[kEJCompositeOperationXOR] = "xor"
};

static const char * EJScalingModeNames[] = {
	[kEJScalingModeNone] = "none",
	[kEJScalingModeFitWidth] = "fit-width",
	[kEJScalingModeFitHeight] = "fit-height"
};


@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
	EJCanvasContext * renderingContext;
	EJApp * ejectaInstance;
	short width, height;
	
	BOOL isScreenCanvas;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
	
	BOOL msaaEnabled;
	int msaaSamples;
}
	
@property (readonly, nonatomic) EJTexture * texture;

@end
