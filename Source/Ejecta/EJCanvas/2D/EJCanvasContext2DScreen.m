#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContext2DScreen.h"
#import "EJJavaScriptView.h"

@implementation EJCanvasContext2DScreen

@synthesize scalingMode;

- (void)dealloc {
	[glview removeFromSuperview];
	[glview release];
	[super dealloc];
}

- (void)resizeToWidth:(short)newWidth height:(short)newHeight {
	[self flushBuffers];
	
	width = newWidth;
	height = newHeight;
	
	
	// Work out the final screen size - this takes the scalingMode, canvas size, 
	// screen size and retina properties into account
	
	CGRect frame = CGRectMake(0, 0, width, height);
	CGSize screen = scriptView.bounds.size;
	float contentScale = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
	float aspect = frame.size.width / frame.size.height;
	float screenAspect = screen.width / screen.height;
	
	// Scale to fit with borders, or zoom borderless
	if(
		(scalingMode == kEJScalingModeFit && aspect >= screenAspect) ||
		(scalingMode == kEJScalingModeZoom && aspect <= screenAspect)
	) {
		frame.size.width = screen.width;
		frame.size.height = screen.width / aspect;
	}
	else if (
		(scalingMode == kEJScalingModeFit && aspect < screenAspect) ||
		(scalingMode == kEJScalingModeZoom && aspect > screenAspect)
	) {
		frame.size.width = screen.height * aspect;
		frame.size.height = screen.height;
	}
	
	// Center view
	frame.origin.x = (screen.width - frame.size.width)/2;
	frame.origin.y = (screen.height - frame.size.height)/2;
		
	float internalScaling = frame.size.width / (float)width;
	scriptView.internalScaling = internalScaling;
	
	backingStoreRatio = internalScaling * contentScale;
	
	bufferWidth = frame.size.width * contentScale;
	bufferHeight = frame.size.height * contentScale;
	
	NSLog(
		@"Creating ScreenCanvas (2D): "
			@"size: %dx%d, aspect ratio: %.3f, "
			@"scaled: %.3f = %.0fx%.0f, "
			@"retina: %@ = %.0fx%.0f, "
			@"msaa: %@",
		width, height, aspect, 
		internalScaling, frame.size.width, frame.size.height,
		(useRetinaResolution ? @"yes" : @"no"),
		frame.size.width * contentScale, frame.size.height * contentScale,
		(msaaEnabled ? [NSString stringWithFormat:@"yes (%d samples)", msaaSamples] : @"no")
	);
	
	
	if( !glview ) {
		// Create the OpenGL UIView with final screen size and content scaling (retina)
		glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale retainedBacking:YES];
		
		// Append the OpenGL view to Ejecta's main view
		[scriptView addSubview:glview];
	}
	else {
		// Resize an existing view
		glview.frame = frame;
	}
	
	// Set up the renderbuffer
	[glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);
	
	// Flip the screen - OpenGL has the origin in the bottom left corner. We want the top left.
	upsideDown = true;
	
	[super resetFramebuffer];
}

- (void)finish {
	glFinish();
}

- (void)present {
	[self flushBuffers];
	
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
		[glContext presentRenderbuffer:GL_RENDERBUFFER];
	}
	needsPresenting = NO;
}

@end
