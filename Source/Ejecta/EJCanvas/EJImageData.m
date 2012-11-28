#import "EJImageData.h"

@implementation EJImageData

@synthesize width, height, pixels;

- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *)pixelsp {
	if( self = [super init] ) {
		width = widthp;
		height = heightp;
		pixels = pixelsp;
	}
	return self;
}

- (void)dealloc {
	free(pixels);
	[super dealloc];
}

- (EJTexture *)texture {
	return [[[EJTexture alloc] initWithWidth:width height:height pixels:pixels] autorelease];
}

@end
