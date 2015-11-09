#import "EJCanvasContext.h"

@implementation EJCanvasContext

@synthesize glContext;
@synthesize width, height;
@synthesize msaaEnabled, msaaSamples;
@synthesize preserveDrawingBuffer;

- (void)create {}
- (void)flushBuffers {}
- (void)prepare {}

@end
