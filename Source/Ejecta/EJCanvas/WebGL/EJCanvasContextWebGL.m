#import "EJCanvasContextWebGL.h"
#import "EJJavaScriptView.h"

@implementation EJCanvasContextWebGL

@synthesize useRetinaResolution;
@synthesize backingStoreRatio;
@synthesize scalingMode;

- (id)initWithScriptView:(EJJavaScriptView *)scriptViewp width:(short)widthp height:(short)heightp {
	if( self = [super init] ) {
		scriptView = scriptViewp;
		glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2
			sharegroup:scriptView.openGLContext.glSharegroup];
		
		bufferWidth = width = widthp;
		bufferHeight = height = heightp;
		
		msaaEnabled = NO;
		msaaSamples = 2;
	}
	return self;
}

- (void)create {
	// Work out the final screen size - this takes the scalingMode, canvas size,
	// screen size and retina properties into account
	CGRect frame = CGRectMake(0, 0, width, height);
	CGSize screen = scriptView.bounds.size;
	float contentScale = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
	float aspect = frame.size.width / frame.size.height;
	
	if( scalingMode == kEJScalingModeFitWidth ) {
		frame.size.width = screen.width;
		frame.size.height = screen.width / aspect;
	}
	else if( scalingMode == kEJScalingModeFitHeight ) {
		frame.size.width = screen.height * aspect;
		frame.size.height = screen.height;
	}
	float internalScaling = frame.size.width / (float)width;
	scriptView.internalScaling = internalScaling;
	
	backingStoreRatio = internalScaling * contentScale;
	
	NSLog(
		@"Creating ScreenCanvas (WebGL): "
			@"size: %dx%d, aspect ratio: %.3f, "
			@"scaled: %.3f = %.0fx%.0f, "
			@"retina: %@ = %.0fx%.0f",
		width, height, aspect,
		internalScaling, frame.size.width, frame.size.height,
		(useRetinaResolution ? @"yes" : @"no"),
		frame.size.width * contentScale, frame.size.height * contentScale
	);
	
	// Create the OpenGL UIView with final screen size and content scaling (retina)
	glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale retainedBacking:NO];
	
	// Create the frame- and renderbuffers
	glGenFramebuffers(1, &viewFrameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
	
	glGenRenderbuffers(1, &viewRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
	
	// Set up the renderbuffer and some initial OpenGL properties
	[glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);

	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &bufferWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &bufferHeight);

	glGenRenderbuffers(1, &depthRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
	
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glViewport(0, 0, width * backingStoreRatio, height * backingStoreRatio);
	
	// Append the OpenGL view to Impact's main view
	[scriptView addSubview:glview];
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
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
	
	// Re-bind textures; they may have been changed in a different context
	GLint boundTexture2D;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture2D);
	if( boundTexture2D ) { glBindTexture(GL_TEXTURE_2D, boundTexture2D); }
	
	GLint boundTextureCube;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &boundTextureCube);
	if( boundTextureCube ) { glBindTexture(GL_TEXTURE_CUBE_MAP, boundTextureCube); }
}

- (void)bindRenderbuffer {
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
}

- (void)bindFramebuffer {
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
}


- (void)setWidth:(short)newWidth {
	if( newWidth != width ) {
		NSLog(@"Warning: Can't change size of the screen rendering context");
	}
}

- (void)setHeight:(short)newHeight {
	if( newHeight != height ) {
		NSLog(@"Warning: Can't change size of the screen rendering context");
	}
}

- (void)finish {
	glFinish();
}

- (void)present {
	[glContext presentRenderbuffer:GL_RENDERBUFFER];
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
}

@end
