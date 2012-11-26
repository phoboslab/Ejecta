//
//  EJWebGLContext.m
//  EjectaGL
//
//  Created by vikram on 11/24/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "EJWebGLContextScreen.h"
#import "EJApp.h"

@implementation EJWebGLContextScreen

@synthesize useRetinaResolution;

- (id)initWithWidth:(short)widthp height:(short)heightp {
	if( self = [super init] ) {
		width = widthp;
		height = heightp;
	}
	return self;
}

- (void)create {
	// Work out the final screen size - this takes the scalingMode, canvas size,
	// screen size and retina properties into account
	CGRect frame = CGRectMake(0, 0, width, height);
    float contentScale = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
	float aspect = frame.size.width / frame.size.height;
	
	NSLog(
          @"Creating ScreenCanvas: "
          @"size: %dx%d, aspect ratio: %.3f, "
          @"retina: %@, ",
          width, height, aspect,
          (useRetinaResolution ? @"yes" : @"no")
          );
	
	// Create the OpenGL UIView with final screen size and content scaling (retina)
	glview = [[EAGLView alloc] initWithFrame:frame contentScale:contentScale];
    
	// Create the frame- and renderbuffers
    glGenFramebuffers(1, &viewFrameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
	
	glGenRenderbuffers(1, &viewRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
	
	// Set up the renderbuffer and some initial OpenGL properties
	[[EJApp instance].glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)glview.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderBuffer);
		    
	// Append the OpenGL view to Impact's main view
	[[EJApp instance] hideLoadingScreen];
	[[EJApp instance].view addSubview:glview];
}

- (void)dealloc {
    if( viewFrameBuffer ) { glDeleteFramebuffers( 1, &viewFrameBuffer); }
	if( viewRenderBuffer ) { glDeleteRenderbuffers(1, &viewRenderBuffer); }
	[glview release];
	[super dealloc];
}

- (void)finish {
	glFinish();
}

- (void)present {
    [[EJApp instance].glContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
