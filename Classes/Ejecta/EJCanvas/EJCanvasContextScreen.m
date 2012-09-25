#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContextScreen.h"
#import "EJApp.h"

@implementation EJCanvasContextScreen

@synthesize useRetinaResolution;
@synthesize scalingMode;


- (void)create {
	// Work out the final screen size - this takes the scalingMode, canvas size, 
	// screen size and retina properties into account
	
	CGRect frame = CGRectMake(0, 0, width, height);
	CGSize screen = [EJApp instance].view.bounds.size;
	float contentScale = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
	float aspect = frame.size.width / frame.size.height;
	
	if( scalingMode == kEJScalingModeFitWidth ) {
		frame.size.width = screen.width;
		frame.size.height = screen.width / aspect;
	}
	if( scalingMode == kEJScalingModeFitHeight ) {
		frame.size.width = screen.height * aspect;
		frame.size.height = screen.height;
	}
	float internalScaling = frame.size.width / (float)width;
	[EJApp instance].internalScaling = internalScaling;
	
	viewportWidth = frame.size.width * contentScale;
	viewportHeight = frame.size.height * contentScale;
	
	NSLog(
		@"Creating ScreenCanvas: "
			@"size: %dx%d, aspect ratio: %.3f, "
			@"scaled: %.3f = %.0fx%.0f, "
			@"using retina: %@ = %.0fx%.0f", 
		width, height, aspect, 
		internalScaling, frame.size.width, frame.size.height,
		(useRetinaResolution ? @"yes" : @"no"),
		frame.size.width * contentScale, frame.size.height * contentScale
	);
	
	// Create the OpenGL UIView with final screen size and content scaling (retina)
	glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale];
	
	
	// This creates the framebuffer and our internal vertex buffer
	[super create];
	
	
	// Set up the renderbuffer and some initial OpenGL properties
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[glview.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
	glDisable(GL_CULL_FACE);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_LIGHTING);
	glDisable(GL_DITHER);
	
	glEnable(GL_BLEND);
	
	[self prepare];
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	// Append the OpenGL view to Impact's main view
	[[EJApp instance] hideLoadingScreen];
	[[EJApp instance].view addSubview:glview];
}

- (void)dealloc {
	[glview release];
	glDeleteRenderbuffers(1, &colorRenderbuffer);
	[super dealloc];
}

- (void)createStencilBufferOnce {
	if( stencilBuffer ) { return; }
	[super createStencilBufferOnce];
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
}

- (void)prepare {
	[super prepare];
	
	// Flip the screen - OpenGL has the origin in the bottom left corner. We want the top left.
	glTranslatef(0, height, 0);
	glScalef( 1, -1, 1 );
}

- (EJImageData*)getImageDataSx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh {
	// FIXME: This should take care of the flipped pixel layout and the
	// internal scaling - not sure how to do the latter - it will get mushed :/
	
	[self flushBuffers];
	
	int count = sw * sh * 4;
	GLubyte * pixels = malloc( count * sizeof(GLubyte));
	glReadPixels(sx, height-sy-sh, sw, sh, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	// Flip pixels
	GLubyte * flippedPixels = malloc( count * sizeof(GLubyte));
	int rowWidth = sw * 4;
	for( int rowStart = 0; rowStart < count; rowStart += rowWidth ) {
		memcpy(&flippedPixels[rowStart], &pixels[count-rowStart-rowWidth-1], rowWidth);
	}
	free(pixels);
	
	return [[[EJImageData alloc] initWithWidth:sw height:sh pixels:flippedPixels] autorelease];
}

- (void)resetGLContext {
	[glview resetContext];
}

- (void)present {
	[self flushBuffers];
	[glview.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
