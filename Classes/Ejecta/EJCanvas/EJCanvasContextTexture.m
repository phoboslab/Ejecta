#import "EJCanvasContextTexture.h"

@implementation EJCanvasContextTexture
@synthesize texture;

- (void)create {
	[super create]; // This creates the framebuffer
	
	// Create the texture and set it as the rendering target for this framebuffer
	texture = [[EJTexture alloc] initWithWidth:width height:height];
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture.textureId, 0);
	bufferWidth = texture.realWidth;
	bufferHeight = texture.realHeight;
	
	[self prepare];
	
	// Clear to transparent
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)dealloc {
	[texture release];
	[super dealloc];
}

@end
