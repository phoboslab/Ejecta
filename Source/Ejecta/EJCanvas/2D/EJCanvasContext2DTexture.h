// The EJCanvas2D subclass that handles rendering to an offscreen texture.

#import "EJCanvasContext2D.h"

@interface EJCanvasContext2DTexture : EJCanvasContext2D {
	EJTexture *texture;
}

@property (readonly, nonatomic) EJTexture *texture;

@end
