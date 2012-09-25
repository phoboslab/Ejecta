#import "EJCanvasContext.h"

@interface EJCanvasContextTexture : EJCanvasContext {
	EJTexture * texture;
}

@property (readonly, nonatomic) EJTexture * texture;

@end
