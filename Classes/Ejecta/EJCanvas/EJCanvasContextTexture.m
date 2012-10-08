#import "EJCanvasContextTexture.h"

@implementation EJCanvasContextTexture

- (void)create {
	// Create the texture
	texture = [[EJTexture alloc] initWithWidth:width height:height];
	bufferWidth = texture.realWidth;
	bufferHeight = texture.realHeight;
	
	// This creates the frame- and renderbuffers
	[super create];
	
	// Set the texture and set it as the rendering target for this framebuffer
	glFramebufferTexture2DOES(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.textureId, 0);
	
	[self prepare];
	
	// Clear to transparent
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)dealloc {
	[texture release];
	[super dealloc];
}

- (void)prepare {
	[super prepare];
	
	// When this Canvas context is made active and it's using MSAA, set
	// a flag so that we know it's contents may have been modified.
	msaaNeedsResolving = msaaEnabled;
}

- (EJTexture *)texture {

	// If this texture Canvas uses MSAA, we need to resolve the MSAA first,
	// before we can use the texture for drawing.
	if( msaaNeedsResolving ) {	
		GLint boundFrameBuffer;
		glGetIntegerv( GL_FRAMEBUFFER_BINDING, &boundFrameBuffer );
		
		//Bind the MSAA and View frameBuffers and resolve
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msaaFrameBuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, viewFrameBuffer);
		glResolveMultisampleFramebufferAPPLE();
		
		glBindFramebuffer(GL_FRAMEBUFFER, boundFrameBuffer);
		
		msaaNeedsResolving = NO;
	}
	
	return texture;
}

@end
