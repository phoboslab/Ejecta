#import "EJCanvasContextWebGLScreen.h"
#import "EJJavaScriptView.h"
#import "EJTexture.h"

@implementation EJCanvasContextWebGLScreen
@synthesize style;
@synthesize view = glview;

- (void)dealloc {
	[glview removeFromSuperview];
	[glview release];
	[super dealloc];
}

- (void)setStyle:(CGRect)newStyle {
	if(
		(style.size.width ? style.size.width : width) != newStyle.size.width ||
		(style.size.height ? style.size.height : height) != newStyle.size.height
	) {
		// Must resize
		style = newStyle;
		
		// Only resize if we already have a viewFrameBuffer. Otherwise the style
		// will be honored in the 'create' call.
		if( viewFrameBuffer ) {
			[self resizeToWidth:width height:height];
		}
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
	
	width = newWidth;
	height = newHeight;
	
	CGRect frame = self.frame;
	float contentScale = MAX(width/frame.size.width, height/frame.size.height);
	
	NSLog(
		@"Creating ScreenCanvas (WebGL): "
			@"size: %dx%d, "
			@"style: %.0fx%.0f, "
			@"antialias: %@, preserveDrawingBuffer: %@",
		width, height, 
		frame.size.width, frame.size.height,
		(msaaEnabled ? [NSString stringWithFormat:@"yes (%d samples)", msaaSamples] : @"no"),
		(preserveDrawingBuffer ? @"yes" : @"no")
	);
	
	if( !glview ) {
		// Create the OpenGL UIView with final screen size and content scaling (retina)
		glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale retainedBacking:preserveDrawingBuffer];
		
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
	
	// The renderbuffer may be bigger than the requested size; make sure to store the real
	// renderbuffer size.
	GLint rbWidth, rbHeight;
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &rbWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &rbHeight);
	bufferWidth = rbWidth;
	bufferHeight = rbHeight;
	

	[self resizeAuxiliaryBuffers];
	
	// Clear
	glViewport(0, 0, width, height);
	[self clear];
	
	
	// Reset to the previously bound frame and renderbuffers
  glBindFramebuffer(previousFrameBuffer, GL_FRAMEBUFFER);
  glBindRenderbuffer(previousRenderBuffer, GL_RENDERBUFFER);
}

- (void)finish {
	glFinish();
}

- (void)present {
	if( !needsPresenting ) { return; }
	
	if( msaaEnabled ) {
		//Bind the MSAA and View frameBuffers and resolve
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msaaFrameBuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, viewFrameBuffer);
		glResolveMultisampleFramebufferAPPLE();
		
		glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
		[glContext presentRenderbuffer:GL_RENDERBUFFER];
		glBindFramebuffer(GL_FRAMEBUFFER, msaaFrameBuffer);
	}
	else {
		glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
		[glContext presentRenderbuffer:GL_RENDERBUFFER];
	}
	
	if( preserveDrawingBuffer ) {
		glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	}
	else {
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	}
	needsPresenting = NO;
}

- (EJTexture *)texture {
	EJCanvasContext *previousContext = scriptView.currentRenderingContext;
	scriptView.currentRenderingContext = self;

	NSMutableData *pixels = [NSMutableData dataWithLength:bufferWidth * bufferHeight * 4 * sizeof(GLubyte)];
	glReadPixels(0, 0, bufferWidth, bufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, pixels.mutableBytes);
	
	[EJTexture flipPixelsY:pixels.mutableBytes bytesPerRow:bufferWidth * 4 rows:bufferHeight];
	EJTexture *texture = [[[EJTexture alloc] initWithWidth:bufferWidth height:bufferHeight pixels:pixels] autorelease];

	scriptView.currentRenderingContext = previousContext;
	return texture;
}

@end
