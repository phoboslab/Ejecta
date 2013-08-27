#import "EJCanvasContextWebGL.h"
#import "EJJavaScriptView.h"

@implementation EJCanvasContextWebGL

@synthesize style;
@synthesize useRetinaResolution;
@synthesize backingStoreRatio;

@synthesize boundFramebuffer;
@synthesize boundRenderbuffer;

- (BOOL)needsPresenting { return needsPresenting; }
- (void)setNeedsPresenting:(BOOL)needsPresentingp { needsPresenting = needsPresentingp; }

- (id)initWithScriptView:(EJJavaScriptView *)scriptViewp width:(short)widthp height:(short)heightp style:(CGRect)stylep {
	if( self = [super init] ) {
		scriptView = scriptViewp;
		
		// Flush the previous context - if any - before creating a new one
		if( [EAGLContext currentContext] ) {
			glFlush();
		}
		
		glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2
			sharegroup:scriptView.openGLContext.glSharegroup];
		
		backingStoreRatio = 1;
		bufferWidth = width = widthp;
		bufferHeight = height = heightp;
		style = stylep;
		
		msaaEnabled = NO;
		msaaSamples = 2;
		
		boundFramebuffer = 0;
		boundRenderbuffer = 0;
	}
	return self;
}

- (void)setStyle:(CGRect)newStyle {
	if(
		(style.size.width ? style.size.width : width) != newStyle.size.width ||
		(style.size.height ? style.size.height : height) != newStyle.size.height
	) {
		// Must resize
		style = newStyle;
		[self resizeToWidth:width height:height];
	}
	else {
		// Just reposition
		style = newStyle;
		if( glview ) {
			glview.frame = self.frame;
		}
	}
}

- (CGRect)frame {
	// Returns the view frame with the current style. If the style's witdth/height
	// is zero, the canvas width/height is used
	return CGRectMake(
		style.origin.x,
		style.origin.y,
		(style.size.width ? style.size.width : width),
		(style.size.height ? style.size.height : height)
	);
}

- (void)resizeToWidth:(short)newWidth height:(short)newHeight {
	[self flushBuffers];
	
	bufferWidth = width = newWidth;
	bufferHeight = height = newHeight;
	
	CGRect frame = self.frame;
	float contentScale = bufferWidth / frame.size.width;
	
	NSLog(
		@"Creating ScreenCanvas (WebGL): "
			@"size: %dx%d, "
			@"style: %.0fx%.0f",
		width, height, 
		frame.size.width, frame.size.height
	);
	
	if( contentScale != 1 && contentScale != 2 ) {
		NSLog(
			@"Warning: contentScale for the WebGL ScreenCanvas is %f."
			@"You'll likely get a blank screen. The canvas's style width and height"
			@"must be 1x or 2x the internal width and height.",
			contentScale
		);
	}
	
	if( !glview ) {
		// Create the OpenGL UIView with final screen size and content scaling (retina)
		glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale retainedBacking:YES];
		
		// Append the OpenGL view to Ejecta's main view
		[scriptView addSubview:glview];
	}
	else {
		// Resize an existing view
		glview.frame = frame;
		glview.contentScaleFactor = contentScale;
		glview.layer.contentsScale = contentScale;
	}
	
	GLint previousFrameBuffer;
	GLint previousRenderBuffer;
	glGetIntegerv( GL_FRAMEBUFFER_BINDING, &previousFrameBuffer );
	glGetIntegerv( GL_RENDERBUFFER_BINDING, &previousRenderBuffer );
	
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
	
	// Set up the renderbuffer and some initial OpenGL properties
	[glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);
	
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

- (void)create {
	// Create the frame- and renderbuffers
	glGenFramebuffers(1, &viewFrameBuffer);	
	glGenRenderbuffers(1, &viewRenderBuffer);
	glGenRenderbuffers(1, &depthRenderBuffer);
	
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
	if( depthRenderBuffer ) { glDeleteRenderbuffers(1, &depthRenderBuffer); }
	[glview release];
	[glContext release];
	
	[EAGLContext setCurrentContext:oldContext];
	[super dealloc];
}

- (void)prepare {
	// Bind to the frame/render buffer last bound on this context
	GLuint framebuffer = boundFramebuffer ? boundFramebuffer : viewFrameBuffer;
	GLuint renderbuffer = boundRenderbuffer ? boundRenderbuffer : viewRenderBuffer;
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
	
	// Re-bind textures; they may have been changed in a different context
	GLint boundTexture2D;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture2D);
	if( boundTexture2D ) { glBindTexture(GL_TEXTURE_2D, boundTexture2D); }
	
	GLint boundTextureCube;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &boundTextureCube);
	if( boundTextureCube ) { glBindTexture(GL_TEXTURE_CUBE_MAP, boundTextureCube); }
}

- (void)clear {
	GLfloat c[4];
	glGetFloatv(GL_COLOR_CLEAR_VALUE, c);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glClearColor(c[0], c[1], c[2], c[3]);
}

- (void)bindRenderbuffer {
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
}

- (void)bindFramebuffer {
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
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

- (void)finish {
	glFinish();
}

- (void)present {
	if( !needsPresenting ) { return; }
	
	[glContext presentRenderbuffer:GL_RENDERBUFFER];
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	needsPresenting = NO;
}

@end
