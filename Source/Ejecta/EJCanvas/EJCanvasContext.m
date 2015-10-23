#import "EJCanvasContext.h"

@implementation EJCanvasContext

@synthesize glContext;
@synthesize width, height;
@synthesize msaaEnabled, msaaSamples;
@synthesize backingStoreRatio;
@synthesize useRetinaResolution;
@synthesize needsPresenting;
@synthesize ignoreClearing;

- (void)create {}
- (void)flushBuffers {}
- (void)prepare {}

@end
