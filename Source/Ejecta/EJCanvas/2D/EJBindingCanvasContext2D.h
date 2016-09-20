// The binding for the Canvas2D Context. This class is exposed to JavaScript and
// forwards all calls to the actual implementation in CanvasContext2D.

#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContext2D.h"

@interface EJBindingCanvasContext2D : EJBindingBase {
	JSObjectRef jsCanvas;
	EJCanvasContext2D *renderingContext;
}

- (id)initWithRenderingContext:(EJCanvasContext2D *)renderingContextp;

@end
