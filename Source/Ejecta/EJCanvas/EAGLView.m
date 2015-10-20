#import "EAGLView.h"

@implementation EAGLView

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame contentScale:(float)contentScale retainedBacking:(BOOL)retainedBacking {
	if( self = [super initWithFrame:frame] ) {
		#if !TARGET_OS_TV
			[self setMultipleTouchEnabled:YES];
		#endif
		
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		self.contentScaleFactor = contentScale;
		eaglLayer.contentsScale = contentScale;

		eaglLayer.opaque = TRUE;
		
		eaglLayer.drawableProperties = @{
			kEAGLDrawablePropertyRetainedBacking: @(retainedBacking),
			kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
		};
	}
	return self;
}

@end
