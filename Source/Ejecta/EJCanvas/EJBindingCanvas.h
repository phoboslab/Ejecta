#import "EJBindingBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"
#import "EJCanvasContext.h"
#import "EJBindingCanvasStyle.h"

@class EJJavaScriptView;

typedef enum {
	kEJCanvasContextModeInvalid,
	kEJCanvasContextMode2D,
	kEJCanvasContextModeWebGL
} EJCanvasContextMode;

@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
	JSObjectRef jsCanvasContext;
	EJCanvasContext *renderingContext;
	EJCanvasContextMode contextMode;
	short width, height;
	
	EJBindingCanvasStyle *styleObject;
	CGRect style;
	
	BOOL isScreenCanvas;
	BOOL useRetinaResolution;
	
	BOOL msaaEnabled;
	int msaaSamples;
}

@property (nonatomic) float styleLeft;
@property (nonatomic) float styleTop;
@property (nonatomic) float styleWidth;
@property (nonatomic) float styleHeight;
@property (readonly, nonatomic) EJTexture *texture;

@end
