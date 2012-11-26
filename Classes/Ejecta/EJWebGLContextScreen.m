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

- (id)initWithWidth:(short)widthp height:(short)heightp contentScale:(float)contentScalep {
	if( self = [super init] ) {
		width = widthp;
		height = heightp;
        contentScale = contentScalep;
	}
	return self;
}

- (void)create {
	// Work out the final screen size - this takes the scalingMode, canvas size,
	// screen size and retina properties into account
	CGRect frame = CGRectMake(0, 0, width / contentScale, height / contentScale);
	float aspect = frame.size.width / frame.size.height;
	
	NSLog(
          @"Creating ScreenCanvas: "
          @"size: %dx%d, aspect ratio: %.3f, "
          @"retina: %@ = %dx%d",
          width, height, aspect,
          (contentScale == 2 ? @"yes" : @"no"),
          (int)(frame.size.width * contentScale),
          (int)(frame.size.height * contentScale));
	
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

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &bufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &bufferHeight);

    glGenRenderbuffers(1, &depthRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
    
	// Append the OpenGL view to Impact's main view
	[[EJApp instance] hideLoadingScreen];
	[[EJApp instance].view addSubview:glview];
}

- (void)dealloc {
    if( viewFrameBuffer ) { glDeleteFramebuffers( 1, &viewFrameBuffer); }
	if( viewRenderBuffer ) { glDeleteRenderbuffers(1, &viewRenderBuffer); }
    if( depthRenderBuffer ) { glDeleteRenderbuffers(1, &depthRenderBuffer); }
	[glview release];
	[super dealloc];
}

- (void)prepare {
    glBindFramebuffer(GL_FRAMEBUFFER, viewFrameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderBuffer);
}

- (void)finish {
	glFinish();
}

- (void)present {
    [[EJApp instance].glContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
