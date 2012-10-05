#import "EJCanvasContext.h"

@interface EJCanvasContextTexture : EJCanvasContext {
	BOOL msaaNeedsResolving;
	EJTexture * texture;
}

@property (readonly, nonatomic) EJTexture * texture;

@end
