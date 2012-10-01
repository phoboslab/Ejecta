#import "EJTexture.h"

@class EJCanvasContext;

@interface EJFont : EJTexture

- (id)initWithFont:(NSString*)font size:(NSInteger)size fill:(BOOL)fill contentScale:(float)contentScale;
- (void)drawString:(NSString*)string toContext:(EJCanvasContext*)context x:(float)x y:(float)y;

@end
