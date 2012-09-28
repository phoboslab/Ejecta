#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EJTexture.h"
#import "lodepng/lodepng.h"

@implementation EJTexture

static GLint textureFilter = GL_LINEAR;

+ (BOOL)smoothScaling {
	return (textureFilter == GL_LINEAR); 
}

+ (void)setSmoothScaling:(BOOL)smoothScaling { 
	textureFilter = smoothScaling ? GL_LINEAR : GL_NEAREST; 
}



@synthesize textureId;
@synthesize width, height, realWidth, realHeight;

- (id)initWithPath:(NSString *)path {
	// Load directly (blocking)
	
	if( self = [super init] ) {
		fullPath = [path retain];
		GLubyte * pixels = [self loadPixelsFromPath:path];
		[self createTextureWithPixels:pixels format:GL_RGBA];
		free(pixels);
	}

	return self;
}

- (id)initWithPath:(NSString *)path context:(EAGLContext*)context {
	// Load in a low-priority thread (non-blocking)
	
	if( self = [super init] ) {
		fullPath = [path retain];
		GLubyte * pixels = [self loadPixelsFromPath:path];
		
		if( pixels ) {
			EAGLContext * contextTextureThread = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 
									 sharegroup:context.sharegroup];
			[EAGLContext setCurrentContext: contextTextureThread];
			
			[self createTextureWithPixels:pixels format:GL_RGBA];
			glFlush();
			
			[EAGLContext setCurrentContext: nil];
			[contextTextureThread release];
			
			free(pixels);
		}
	}

	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp {
	// Create an empty texture
	
	if( self = [super init] ) {
		fullPath = [@"[Empty]" retain];
		[self setWidth:widthp height:heightp];
		[self createTextureWithPixels:NULL format:GL_RGBA];
	}
	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *)pixels {
	// Creates a texture with the given pixels
	
	if( self = [super init] ) {
		fullPath = [@"[From Pixels]" retain];
		[self setWidth:widthp height:heightp];
		
		if( width != realWidth || height != realHeight ) {
			GLubyte * pixelsPow2 = (GLubyte *)malloc( realWidth * realHeight * 4 );
			memset( pixelsPow2, 0, realWidth * realHeight * 4 );
			for( int y = 0; y < height; y++ ) {
				memcpy( &pixelsPow2[y*realWidth*4], &pixels[y*width*4], width * 4 );
			}
			[self createTextureWithPixels:pixelsPow2 format:GL_RGBA];
			free(pixelsPow2);
		}
		else {
			[self createTextureWithPixels:pixels format:GL_RGBA];
		}
	}
	return self;
}

- (id)initWithString:(NSString *)string font:(UIFont *)font fill:(BOOL)fill lineWidth:(float)lineWidth contentScale:(float)contentScale {
	if( self = [super init] ) {		
		CGSize boundingBox = [string sizeWithFont:font];		
		[self setWidth:boundingBox.width*contentScale height:boundingBox.height*contentScale];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
		GLubyte * pixels = (GLubyte *) malloc( realWidth * realHeight);
		memset( pixels, 0, realWidth * realHeight);
		CGContextRef context = CGBitmapContextCreate(pixels, realWidth, realHeight, 8, realWidth, colorSpace, kCGImageAlphaNone);
		CGColorSpaceRelease(colorSpace);
			
		// Fill or stroke?
		if( fill ) {
			CGContextSetTextDrawingMode(context, kCGTextFill);
			CGContextSetGrayFillColor(context, 1.0, 1.0);
		}
		else {
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextSetGrayStrokeColor(context, 1.0, 1.0);
			CGContextSetLineWidth(context, lineWidth);
		}

		UIGraphicsPushContext(context);
		CGContextTranslateCTM(context, 0.0, realHeight);
		CGContextScaleCTM(context, contentScale, -1.0*contentScale);
		
		[string drawInRect:CGRectMake(0, 0, width, height)
			  withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
		
		UIGraphicsPopContext();
		
		[self createTextureWithPixels:pixels format:GL_ALPHA];
		
		CGContextRelease(context);
		free(pixels);
	}
	return self;
}

- (void)dealloc {
	[fullPath release];
	glDeleteTextures( 1, &textureId );
	[super dealloc];
}

- (void)setWidth:(int)widthp height:(int)heightp {
	width = widthp;
	height = heightp;
	
	// The internal (real) size of the texture needs to be a power of two
	realWidth = pow(2, ceil(log2( width )));
	realHeight = pow(2, ceil(log2( height )));
}

- (void)createTextureWithPixels:(GLubyte *)pixels format:(GLenum) format {
	GLint maxTextureSize;
	glGetIntegerv( GL_MAX_TEXTURE_SIZE, &maxTextureSize );
	
	if( realWidth > maxTextureSize || realHeight > maxTextureSize ) {
		NSLog(@"Warning: Image %@ larger than MAX_TEXTURE_SIZE (%d)", fullPath, maxTextureSize);
	}
		
	bool wasEnabled = glIsEnabled(GL_TEXTURE_2D);
	int boundTexture = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
	
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &textureId);
	glBindTexture(GL_TEXTURE_2D, textureId);
	glTexImage2D(GL_TEXTURE_2D, 0, format, realWidth, realHeight, 0, format, GL_UNSIGNED_BYTE, pixels);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, textureFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, textureFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glBindTexture(GL_TEXTURE_2D, boundTexture);
	if( !wasEnabled ) {	glDisable(GL_TEXTURE_2D); }
}

- (GLubyte *)loadPixelsFromPath:(NSString *)path {
	// All CGImage functions return pixels with premultiplied alpha and there's no
	// way to opt-out - thanks Apple, awesome idea.
	// So, for PNG images we use the lodepng library instead.
	
	return [[path pathExtension] isEqualToString:@"png"]
		? [self loadPixelsWithLodePNGFromPath:path]
		: [self loadPixelsWithCGImageFromPath:path];
}

- (GLubyte *)loadPixelsWithCGImageFromPath:(NSString *)path {	
	UIImage * tmpImage = [[UIImage alloc] initWithContentsOfFile:path];
	CGImageRef image = tmpImage.CGImage;
		
	[self setWidth:CGImageGetWidth(image) height:CGImageGetHeight(image)];
	
	GLubyte * pixels = (GLubyte *) malloc( realWidth * realHeight * 4);
	memset( pixels, 0, realWidth * realHeight * 4 );
	CGContextRef context = CGBitmapContextCreate(pixels, realWidth, realHeight, 8, realWidth * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(context, CGRectMake(0.0, realHeight - height, (CGFloat)width, (CGFloat)height), image);
	CGContextRelease(context);
	[tmpImage release];
	
	return pixels;
}

- (GLubyte *)loadPixelsWithLodePNGFromPath:(NSString *)path {
	unsigned int w, h;
	unsigned char * origPixels = NULL;
	unsigned int error = lodepng_decode32_file(&origPixels, &w, &h, [path UTF8String]);
	
	if( error ) {
		NSLog(@"Error Loading image %@ - %u: %s", path, error, lodepng_error_text(error));
		return origPixels;
	}
	
	[self setWidth:w height:h];
	
	// If the image is already in the correct (power of 2) size, just return
	// the original pixels unmodified
	if( width == realWidth && height == realHeight ) {
		return origPixels;
	}
	
	// Copy the original pixels into the upper left corner of a larger
	// (power of 2) pixel buffer, free the original pixels and return
	// the larger buffer
	else {
		GLubyte * pixels = malloc( realWidth * realHeight * 4 );
		memset(pixels, 0x00, realWidth * realHeight * 4 );
		
		for( int y = 0; y < height; y++ ) {
			memcpy( &pixels[y*realWidth*4], &origPixels[y*width*4], width*4 );
		}
		
		free( origPixels );
		return pixels;
	}
}

- (void)bind {
	glBindTexture(GL_TEXTURE_2D, textureId);
}



@end
