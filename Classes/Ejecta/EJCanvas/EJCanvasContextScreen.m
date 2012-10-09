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
	
    backingStoreRatio = internalScaling * contentScale;
	
	bufferWidth = viewportWidth = frame.size.width * contentScale;
	bufferHeight = viewportHeight = frame.size.height * contentScale;
	
	NSLog(
		@"Creating ScreenCanvas: "
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
	glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale];
	
	// This creates the frame- and renderbuffers
	[super create];
	
	// Set up the renderbuffer and some initial OpenGL properties
	[glview.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);
	
	glDisable(GL_CULL_FACE);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_LIGHTING);
	glDisable(GL_DITHER);
	
	glEnable(GL_BLEND);
	
	[self prepare];
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	// Append the OpenGL view to Impact's main view
	[[EJApp instance] hideLoadingScreen];
	[[EJApp instance].view addSubview:glview];
}

- (void)dealloc {
	[glview release];
	[super dealloc];
}

- (void)prepare {
	[super prepare];
	
	// Flip the screen - OpenGL has the origin in the bottom left corner. We want the top left.
	glTranslatef(0, height, 0);
	glScalef( 1, -1, 1 );
}

- (EJImageData*)getImageDataSx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh {
	// FIXME: This takes care of the flipped pixel layout and the internal scaling.
	// The latter will mush pixel; not sure how to fix it - print warning instead.
	
	if( backingStoreRatio != 1 && [EJTexture smoothScaling] ) {
		NSLog(
			@"Warning: The screen canvas has been scaled; getImageData() may not work as expected. "
			@"Set imageSmoothingEnabled=false or use an off-screen Canvas for more accurate results."
		);
	}
	
	[self flushBuffers];
	
	// Read pixels; take care of the upside down screen layout and the backingStoreRatio
	int internalWidth = sw * backingStoreRatio;
	int internalHeight = sh * backingStoreRatio;
	int internalX = sx * backingStoreRatio;
	int internalY = (height-sy-sh) * backingStoreRatio;
	
	EJColorRGBA * internalPixels = malloc( internalWidth * internalHeight * sizeof(EJColorRGBA));
	glReadPixels( internalX, internalY, internalWidth, internalHeight, GL_RGBA, GL_UNSIGNED_BYTE, internalPixels );
	
	// Flip and scale pixels to requested size
	EJColorRGBA * pixels = malloc( sw * sh * sizeof(EJColorRGBA));
	int index = 0;
	for( int y = 0; y < sh; y++ ) {
		for( int x = 0; x < sw; x++ ) {
			int internalIndex = (int)((sh-y-1) * backingStoreRatio) * internalWidth + (int)(x * backingStoreRatio);
			pixels[ index ] = internalPixels[ internalIndex ];
			index++;
		}
	}
	free(internalPixels);
	
	return [[[EJImageData alloc] initWithWidth:sw height:sh pixels:(GLubyte *)pixels] autorelease];
}

- (void)finish {
	glFinish();
}

- (void)resetGLContext {
	[glview resetContext];
}

- (void)present {
	[self flushBuffers];
	
	if( msaaEnabled ) {
		//Bind the MSAA and View frameBuffers and resolve
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msaaFrameBuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, viewFrameBuffer);
		glResolveMultisampleFramebufferAPPLE();
		
		glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
		[glview.context presentRenderbuffer:GL_RENDERBUFFER];
		glBindFramebuffer(GL_FRAMEBUFFER, msaaFrameBuffer);
	}
	else {
		[glview.context presentRenderbuffer:GL_RENDERBUFFER];
	}	
}

@end
