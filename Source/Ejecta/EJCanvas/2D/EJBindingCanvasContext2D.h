#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContext2D.h"

@interface EJBindingCanvasContext2D : EJBindingBase {
	JSObjectRef jsCanvas;
	EJCanvasContext2D *renderingContext;
}

- (id)initWithRenderingContext:(EJCanvasContext2D *)renderingContextp;

@end
