#import "EJCanvasContext2DTexture.h"

@implementation EJCanvasContext2DTexture

- (void)create {
	backingStoreRatio = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
	bufferWidth = width * backingStoreRatio;
	bufferHeight = height * backingStoreRatio;
	
	// This creates the frame- and renderbuffers
	[super create];
	
	// Create the texture and set it as the rendering target for this framebuffer
	texture = [[EJTexture alloc] initAsRenderTargetWithWidth:width height:height
		fbo:viewFrameBuffer contentScale:backingStoreRatio];

	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.textureId, 0);
	
	[self prepare];
	
	// Clear to transparent
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
}

- (void)dealloc {
	[texture release];
	[super dealloc];
}

- (void)recreate {
	[texture release];
	texture = [[EJTexture alloc] initAsRenderTargetWithWidth:width height:height
		fbo:viewFrameBuffer contentScale:backingStoreRatio];
	bufferWidth = texture.width;
	bufferHeight = texture.height;
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.textureId, 0);
	
	// Delete stencil buffer; it will be re-created when needed
	if( stencilBuffer ) {
		glDeleteRenderbuffers(1, &stencilBuffer);
		stencilBuffer = 0;
	}
	
	// Resize the MSAA buffer
	if( msaaEnabled && msaaFrameBuffer && msaaRenderBuffer ) {
		glBindFramebuffer(GL_FRAMEBUFFER, msaaFrameBuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, msaaRenderBuffer);
		
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, msaaSamples, GL_RGBA8_OES, bufferWidth, bufferHeight);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, msaaRenderBuffer);
	}
	
	[self prepare];
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
}


- (void)setWidth:(short)newWidth {
	if( newWidth == width ) { return; }
	
	[self flushBuffers];
	width = newWidth;
	[self recreate];
	bufferWidth = texture.width;
	needsPresenting = YES;
}

- (void)setHeight:(short)newHeight {
	if( newHeight == height ) { return; }
	
	[self flushBuffers];
	height = newHeight;
	[self recreate];
	bufferHeight = texture.height;
	needsPresenting = YES;
}

- (EJTexture *)texture {

	// If this texture Canvas uses MSAA, we need to resolve the MSAA first,
	// before we can use the texture for drawing.
	if( msaaEnabled && needsPresenting ) {
		GLint boundFrameBuffer;
		glGetIntegerv( GL_FRAMEBUFFER_BINDING, &boundFrameBuffer );
		
		//Bind the MSAA and View frameBuffers and resolve
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msaaFrameBuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, viewFrameBuffer);
		glResolveMultisampleFramebufferAPPLE();
		
		glBindFramebuffer(GL_FRAMEBUFFER, boundFrameBuffer);
		needsPresenting = NO;
	}
	
	return texture;
}

@end
