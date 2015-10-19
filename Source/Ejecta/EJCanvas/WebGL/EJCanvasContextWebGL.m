#import "EJCanvasContextWebGL.h"
#import "EJJavaScriptView.h"
#import "EJTexture.h"

@implementation EJCanvasContextWebGL

@synthesize boundFramebuffer;
@synthesize boundRenderbuffer;

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
		
		backingStoreRatio = 1;
		bufferWidth = width = widthp;
		bufferHeight = height = heightp;
		
		msaaEnabled = NO;
		msaaSamples = 2;
		
		boundFramebuffer = 0;
		boundRenderbuffer = 0;
	}
	return self;
}

- (void)resizeToWidth:(short)newWidth height:(short)newHeight {
	// This function is a stub - Overwritten in both subclasses
	width = newWidth;
	height = newHeight;
	
	backingStoreRatio = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
	bufferWidth = width * backingStoreRatio;
	bufferHeight = height * backingStoreRatio;
}

- (void)create {
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
	if( depthStencilBuffer ) { glDeleteRenderbuffers(1, &depthStencilBuffer); }
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


- (NSMutableData *)getPixels:(float)scale flipped:(bool)flipped sx:(short)sx sy:(short)sy sw:(short)sw sh:(short)sh {
    
    [self flushBuffers];
    
    NSMutableData *pixels = nil;
    
    // Fast case - no scaling, no flipping
    if( scale == 1 && !flipped ) {
        pixels = [NSMutableData dataWithLength:sw * sh * 4 * sizeof(GLubyte)];
        glReadPixels(sx, sy, sw, sh, GL_RGBA, GL_UNSIGNED_BYTE, pixels.mutableBytes);
    }
    
    // More processing needed - take care of the flipped screen layout and the scaling
    else {
        int internalWidth = sw * scale;
        int internalHeight = sh * scale;
        int internalX = sx * scale;
        int internalY = ((bufferHeight/scale)-sy-sh) * scale;
        
        EJColorRGBA *internalPixels = malloc( internalWidth * internalHeight * sizeof(EJColorRGBA));
        glReadPixels( internalX, internalY, internalWidth, internalHeight, GL_RGBA, GL_UNSIGNED_BYTE, internalPixels );
        
        int size = sw * sh * sizeof(EJColorRGBA);
        EJColorRGBA *scaledPixels = malloc( size );
        int index = 0;
        for( int y = 0; y < sh; y++ ) {
            int rowIndex = (int)((flipped ? sh-y-1 : y) * scale) * internalWidth;
            for( int x = 0; x < sw; x++ ) {
                int internalIndex = rowIndex + (int)(x * scale);
                scaledPixels[ index ] = internalPixels[ internalIndex ];
                index++;
            }
        }
        free(internalPixels);
        
        pixels = [NSMutableData dataWithBytesNoCopy:scaledPixels length:size];
    }
    return pixels;
}

@end
