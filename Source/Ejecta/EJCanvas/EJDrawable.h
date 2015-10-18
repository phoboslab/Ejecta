#import <UIKit/UIKit.h>
#import "EJTexture.h"

@protocol EJDrawable

@property (readonly, nonatomic) EJTexture *texture;
@property (readonly, nonatomic) UIImage *image;

@end
