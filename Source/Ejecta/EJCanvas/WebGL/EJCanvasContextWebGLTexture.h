// Subclass of EJCanvasContextWebGL that renders to an offscreen texture.

#import "EJCanvasContextWebGL.h"
#import "EJTexture.h"

@interface EJCanvasContextWebGLTexture : EJCanvasContextWebGL {
	EJTexture *texture;
}

@end
