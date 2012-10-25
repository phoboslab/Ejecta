#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"

@implementation EAGLView

@synthesize context;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame contentScale:(float)contentScale {
	if( self = [super initWithFrame:frame] ) {
		[self setMultipleTouchEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		self.contentScaleFactor = contentScale;
		eaglLayer.contentsScale = contentScale;
        
        eaglLayer.opaque = FALSE;
        eaglLayer.backgroundColor = [[UIColor clearColor] CGColor];
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:TRUE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];										

		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		[EAGLContext setCurrentContext:context];
    }
    return self;
}

- (void)resetContext {
	[EAGLContext setCurrentContext:context];
}

- (void)dealloc {  
    [context release];
    [super dealloc];
}

@end
