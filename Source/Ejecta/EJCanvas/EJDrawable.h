#import <UIKit/UIKit.h>
#import "EJTexture.h"

@protocol EJDrawable

@property (readonly, nonatomic) EJTexture *texture;
- (EJTexture *)getTexture;
- (void)releaseTexture;

@end
