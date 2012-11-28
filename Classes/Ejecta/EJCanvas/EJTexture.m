#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EJTexture.h"
#import "lodepng/lodepng.h"

@implementation EJTexture

// Textures check this global filter state when binding
static GLint EJTextureGlobalFilter = GL_LINEAR;

+ (BOOL)smoothScaling {
	return (EJTextureGlobalFilter == GL_LINEAR); 
}

+ (void)setSmoothScaling:(BOOL)smoothScaling {
	EJTextureGlobalFilter = smoothScaling ? GL_LINEAR : GL_NEAREST; 
}



@synthesize contentScale;
@synthesize textureId;
@synthesize pixels;
@synthesize width, height, realWidth, realHeight;

- (id)initWithPath:(NSString *)path {
	// For loading on the main thread (blocking)
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [path retain];
		pixels = [self loadPixelsFromPath:path];
	}

	return self;
}

- (id)initWithPath:(NSString *)path sharegroup:(EAGLSharegroup*)sharegroup {
	// For loading in a background thread
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [path retain];
		pixels = [self loadPixelsFromPath:path];
	}

	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum)formatp {
	// Create an empty texture
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [@"[Empty]" retain];
		[self setWidth:widthp height:heightp];
	}
	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp {
	// Create an empty RGBA texture
	return [self initWithWidth:widthp height:heightp format:GL_RGBA];
}

- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *)pixelsp {
	// Creates a texture with the given pixels
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [@"[From Pixels]" retain];
		[self setWidth:widthp height:heightp];
		
        // TODO(vikram): review this change
        pixels = (GLubyte *)malloc( realWidth * realHeight * 4 );
        memset( pixels, 0, realWidth * realHeight * 4 );
        for( int y = 0; y < height; y++ ) {
            memcpy( &pixels[y*realWidth*4], &pixelsp[y*width*4], width * 4 );
        }
	}
	return self;
}

- (void)dealloc {
	[fullPath release];
    if (pixels) { free(pixels); }
	[super dealloc];
}

- (void)setWidth:(int)widthp height:(int)heightp {
	width = widthp;
	height = heightp;
	
	// The internal (real) size of the texture needs to be a power of two
	realWidth = pow(2, ceil(log2( width )));
	realHeight = pow(2, ceil(log2( height )));
}

- (GLubyte *)loadPixelsFromPath:(NSString *)path {
	// Try @2x texture?
	if( [UIScreen mainScreen].scale == 2 ) {
		NSString * path2x = [[[path stringByDeletingPathExtension]
			stringByAppendingString:@"@2x"]
			stringByAppendingPathExtension:[path pathExtension]];
		
		if( [[NSFileManager defaultManager] fileExistsAtPath:path2x] ) {
			contentScale = 2;
			path = path2x;
		}
	}
	
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
	
	GLubyte * retPixels = (GLubyte *) malloc( realWidth * realHeight * 4);
	memset( retPixels, 0, realWidth * realHeight * 4 );
	CGContextRef context = CGBitmapContextCreate(retPixels, realWidth, realHeight, 8, realWidth * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(context, CGRectMake(0.0, realHeight - height, (CGFloat)width, (CGFloat)height), image);
	CGContextRelease(context);
	[tmpImage release];
	
	return retPixels;
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
		GLubyte * retPixels = malloc( realWidth * realHeight * 4 );
		memset(retPixels, 0x00, realWidth * realHeight * 4 );
		
		for( int y = 0; y < height; y++ ) {
			memcpy( &retPixels[y*realWidth*4], &origPixels[y*width*4], width*4 );
		}
		
		free( origPixels );
		return retPixels;
	}
}

- (GLubyte *)getFlippedYPixels {
    if (!pixels) return NULL;
    
    GLubyte *retPixels = (GLubyte *)malloc(realWidth * realHeight * 4);
    
    // TODO(viks): Is there a faster way to do this?
    // Copy pixels but invert in Y direction
    for( int y = 0; y < height; y++ ) {
        memcpy( &retPixels[y*realWidth*4], &pixels[(height - y - 1)*width*4], width*4 );
    }
    
    return retPixels;
}

- (void)updateTextureWithPixels:(GLubyte *)pixels atX:(int)x y:(int)y width:(int)subWidth height:(int)subHeight {
    // HACK HACK: Exists only to make old 2D code compile. To be resolved during merge with real Ejecta.
}

- (void)bind {
    // HACK HACK: Exists only to make old 2D code compile. To be resolved during merge with real Ejecta.
}


@end
