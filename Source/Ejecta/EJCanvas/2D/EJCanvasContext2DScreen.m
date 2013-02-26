#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContext2DScreen.h"
#import "EJJavaScriptView.h"

@implementation EJCanvasContext2DScreen

@synthesize scalingMode;


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
	
	// Create the OpenGL UIView with final screen size and content scaling (retina)
	glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale retainedBacking:YES];

	// This creates the frame- and renderbuffers
	[super create];
	
	// Set up the renderbuffer and some initial OpenGL properties
	[glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);
	
	// Flip the screen - OpenGL has the origin in the bottom left corner. We want the top left.
	upsideDown = true;
	
	[self prepare];
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	// Append the OpenGL view to Ejecta's main view
	[scriptView addSubview:glview];
}

- (void)dealloc {
	[glview removeFromSuperview];
	[glview release];
	[super dealloc];
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
