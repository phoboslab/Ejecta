// The Canvas object exposed to JavaScript. The Ejecta.js sets it up to be
// instantiated through `document.createElement('canvas')`.

// A Canvas object starts as an empty shell that just has a `width`, `height`
// and `style`, until getContext() is called. A Canvas can either host a 2D
// or WebGL Context.

#import "EJBindingBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"
#import "EJCanvasContext.h"
#import "EJBindingCanvasStyle.h"

#define EJ_CANVAS_DEFAULT_JPEG_QUALITY 0.9
#define EJ_CANVAS_DATA_URL_PREFIX_JPEG @"data:image/jpeg;base64,"
#define EJ_CANVAS_DATA_URL_PREFIX_PNG @"data:image/png;base64,"

@class EJJavaScriptView;

typedef enum {
	kEJCanvasContextModeInvalid,
	kEJCanvasContextMode2D,
	kEJCanvasContextModeWebGL
} EJCanvasContextMode;

typedef enum {
	kEJCanvasImageRenderingAuto,
	kEJCanvasImageRenderingCrispEdges,
	kEJCanvasImageRenderingPixelated
} EJCanvasImageRendering;

@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
	JSObjectRef jsCanvasContext;
	EJCanvasContext *renderingContext;
	EJCanvasContextMode contextMode;
	short width, height;
	
	EJBindingCanvasStyle *styleObject;
	EJCanvasImageRendering imageRendering;
	CGRect style;
	
	BOOL isScreenCanvas;
}

@property (nonatomic) EJCanvasImageRendering imageRendering;
@property (nonatomic) float styleLeft;
@property (nonatomic) float styleTop;
@property (nonatomic) float styleWidth;
@property (nonatomic) float styleHeight;
@property (readonly, nonatomic) EJTexture *texture;

@end
