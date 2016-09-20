// The Drawable protocol is implement by all objects that can be drawn to a
// 2D Context or loaded as a Texture in WebGL Contexts: Image, ImageData and
// the Canvas itself.

#import <UIKit/UIKit.h>
#import "EJTexture.h"

@protocol EJDrawable

@property (readonly, nonatomic) EJTexture *texture;

@end
