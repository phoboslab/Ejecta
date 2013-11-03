#import "EJCanvasContextWebGLTexture.h"

@implementation EJCanvasContextWebGLTexture

- (void)dealloc {
	[texture release];
	[super dealloc];
}

- (void)resizeToWidth:(short)newWidth height:(short)newHeight {
	[self flushBuffers];
	
	bufferWidth = width = newWidth;
	bufferHeight = height = newHeight;
	
	NSLog(
		@"Creating Offscreen Canvas (WebGL): size: %dx%d",
		width, height
	);
	
	GLint previousFrameBuffer;
	GLint previousRenderBuffer;
	glGetIntegerv( GL_FRAMEBUFFER_BINDING, &previousFrameBuffer );
	glGetIntegerv( GL_RENDERBUFFER_BINDING, &previousRenderBuffer );
	
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
	
	// Release previous texture if any, create the new texture and set it as
	// the rendering target for this framebuffer
	[texture release];
	texture = [[EJTexture alloc] initAsRenderTargetWithWidth:newWidth height:newHeight
		fbo:viewFrameBuffer contentScale:backingStoreRatio];
	texture.drawFlippedY = true;
	
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.textureId, 0);
	
	// Set up the depth buffer
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
	
	// Clear
	glViewport(0, 0, width, height);
	[self clear];
	
	// Reset to the previously bound frame and renderbuffers
	glBindFramebuffer(GL_FRAMEBUFFER, previousFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, previousRenderBuffer);
}

- (EJTexture *)texture {
	return texture;
}

@end
