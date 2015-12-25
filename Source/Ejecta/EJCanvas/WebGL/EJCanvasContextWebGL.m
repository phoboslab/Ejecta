#import "EJCanvasContextWebGL.h"
#import "EJJavaScriptView.h"

@implementation EJCanvasContextWebGL

- (BOOL)needsPresenting { return needsPresenting; }
- (void)setNeedsPresenting:(BOOL)needsPresentingp { needsPresenting = needsPresentingp; }

- (id)initWithScriptView:(EJJavaScriptView *)scriptViewp width:(short)widthp height:(short)heightp {
	if( self = [super init] ) {
		scriptView = scriptViewp;
		
		// Flush the previous context - if any - before creating a new one
		if( [EAGLContext currentContext] ) {
			glFlush();
		}
		
		glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2
			sharegroup:scriptView.openGLContext.glSharegroup];
		
		bufferWidth = width = widthp;
		bufferHeight = height = heightp;
		
		msaaEnabled = NO;
		msaaSamples = 2;
		preserveDrawingBuffer = NO;
	}
	return self;
}

- (void)resizeToWidth:(short)newWidth height:(short)newHeight {
	// This function is a stub - Overwritten in both subclasses
	bufferWidth = width = newWidth;
	bufferHeight = height = newHeight;
}

- (void)resizeAuxiliaryBuffers {
	// Resize the MSAA buffer, if enabled
	if( msaaEnabled && msaaFrameBuffer && msaaRenderBuffer ) {
		glBindFramebuffer(GL_FRAMEBUFFER, msaaFrameBuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, msaaRenderBuffer);
		
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, msaaSamples, GL_RGBA8_OES, bufferWidth, bufferHeight);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, msaaRenderBuffer);
	}
	
	// Resize the depth and stencil buffer
	glBindRenderbuffer(GL_RENDERBUFFER, depthStencilBuffer);
	if( msaaEnabled ) {
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, msaaSamples, GL_DEPTH24_STENCIL8_OES, bufferWidth, bufferHeight);
	}
	else {
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, bufferWidth, bufferHeight);
	}
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthStencilBuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthStencilBuffer);
	
	needsPresenting = YES;
}

- (void)create {
	if( msaaEnabled ) {
		glGenFramebuffers(1, &msaaFrameBuffer);
		glGenRenderbuffers(1, &msaaRenderBuffer);
	}
	
	// Create the frame- and renderbuffers
	glGenFramebuffers(1, &viewFrameBuffer);	
	glGenRenderbuffers(1, &viewRenderBuffer);
	glGenRenderbuffers(1, &depthStencilBuffer);
	
	[self resizeToWidth:width height:height];
}

- (void)dealloc {
	// Make sure this rendering context is the current one, so all
	// OpenGL objects can be deleted properly. Remember the currently bound
	// Context, but only if it's not the context to be deleted
	EAGLContext *oldContext = [EAGLContext currentContext];
	if( oldContext == glContext ) { oldContext = NULL; }
	[EAGLContext setCurrentContext:glContext];
	
	if( viewFrameBuffer ) { glDeleteFramebuffers( 1, &viewFrameBuffer); }
	if( viewRenderBuffer ) { glDeleteRenderbuffers(1, &viewRenderBuffer); }
	if( msaaFrameBuffer ) {	glDeleteFramebuffers( 1, &msaaFrameBuffer); }
	if( msaaRenderBuffer ) { glDeleteRenderbuffers(1, &msaaRenderBuffer); }
	if( depthStencilBuffer ) { glDeleteRenderbuffers(1, &depthStencilBuffer); }
	[glContext release];
	
	[EAGLContext setCurrentContext:oldContext];
	[super dealloc];
}

- (void)prepare {
	// Bind to the frame/render buffer last bound on this context
	glBindFramebuffer(GL_FRAMEBUFFER, boundFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, boundRenderBuffer);
	
	// Re-bind textures; they may have been changed in a different context
	GLint boundTexture2D;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture2D);
	if( boundTexture2D ) { glBindTexture(GL_TEXTURE_2D, boundTexture2D); }
	
	GLint boundTextureCube;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &boundTextureCube);
	if( boundTextureCube ) { glBindTexture(GL_TEXTURE_CUBE_MAP, boundTextureCube); }
	
	needsPresenting = YES;
}

- (void)clear {
	GLfloat c[4];
	glGetFloatv(GL_COLOR_CLEAR_VALUE, c);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	glClearColor(c[0], c[1], c[2], c[3]);
}

- (void)bindFramebuffer:(GLuint)framebuffer toTarget:(GLuint)target {
	if( framebuffer == 0 ) {
		framebuffer = msaaEnabled ? msaaFrameBuffer : viewFrameBuffer;
		[self bindRenderbuffer:0 toTarget:GL_RENDERBUFFER];
	}
	glBindFramebuffer(target, framebuffer);
	boundFrameBuffer = framebuffer;
}

- (void)bindRenderbuffer:(GLuint)renderbuffer toTarget:(GLuint)target {
	if( renderbuffer == 0 ) {
		renderbuffer = msaaEnabled ? msaaRenderBuffer : viewRenderBuffer;
	}
	glBindRenderbuffer(target, renderbuffer);
	boundRenderBuffer = renderbuffer;
}

- (void)setWidth:(short)newWidth {
	if( newWidth == width ) {
		// Same width as before? Just clear the canvas, as per the spec
		[self clear];
		return;
	}
	[self resizeToWidth:newWidth height:height];
}

- (void)setHeight:(short)newHeight {
	if( newHeight == height ) {
		// Same height as before? Just clear the canvas, as per the spec
		[self clear];
		return;
	}
	[self resizeToWidth:width height:newHeight];
}

@end
