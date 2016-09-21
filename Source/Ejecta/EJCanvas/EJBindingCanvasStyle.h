// The `.style` object associated with a Canvas. All getters and setters are
// forwarded to the Canvas object.

#import "EJBindingBase.h"

@class EJBindingCanvas;
@interface EJBindingCanvasStyle : EJBindingBase {
	EJBindingCanvas *binding;
}

@property (assign, nonatomic) EJBindingCanvas *binding;
@property (readonly, nonatomic) JSObjectRef jsObject;
@end
