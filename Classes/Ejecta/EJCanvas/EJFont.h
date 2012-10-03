#import "EJTexture.h"

#define EJ_FONT_TEXTURE_SIZE 1024

@class EJCanvasContext;

@interface EJFont : NSObject

- (id)initWithFont:(NSString*)font size:(NSInteger)size fill:(BOOL)fill contentScale:(float)contentScale;
- (void)drawString:(NSString*)string toContext:(EJCanvasContext*)context x:(float)x y:(float)y;
- (float)measureString:(NSString*)string;

@end
