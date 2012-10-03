#import "EJTexture.h"

@class EJCanvasContext;

@interface EJFont : NSObject

- (id)initWithFont:(NSString*)font size:(NSInteger)size fill:(BOOL)fill contentScale:(float)contentScale;
- (void)drawString:(NSString*)string toContext:(EJCanvasContext*)context x:(float)x y:(float)y;
- (float)measureString:(NSString*)string;

@end
