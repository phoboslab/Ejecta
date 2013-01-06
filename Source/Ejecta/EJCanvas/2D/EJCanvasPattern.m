#import "EJCanvasPattern.h"

@implementation EJCanvasPattern

@synthesize texture;
@synthesize repeat;

- (id)initWithTexture:(EJTexture *)texturep repeat:(EJCanvasPatternRepeat)repeatp {
	if( self = [super init] ) {
		texture = texturep.copy;
		repeat = repeatp;
		
		[texture setParam:GL_TEXTURE_WRAP_S param: (repeat & kEJCanvasPatternRepeatX) ? GL_REPEAT : GL_CLAMP_TO_EDGE];
		[texture setParam:GL_TEXTURE_WRAP_T param: (repeat & kEJCanvasPatternRepeatY) ? GL_REPEAT : GL_CLAMP_TO_EDGE];
	}
	return self;
}

- (void)dealloc {
	[texture release];
	[super dealloc];
}

@end
