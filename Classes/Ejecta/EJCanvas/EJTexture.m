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
@synthesize width, height, realWidth, realHeight;

- (id)initWithPath:(NSString *)path {
	// For loading on the main thread (blocking)
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [path retain];
		GLubyte * pixels = [self loadPixelsFromPath:path];
		[self createTextureWithPixels:pixels format:GL_RGBA];
		free(pixels);
	}

	return self;
}

- (id)initWithPath:(NSString *)path sharegroup:(EAGLSharegroup*)sharegroup {
	// For loading in a background thread
	
	if( self = [super init] ) {
		// If we're running on the main thread for some reason, take care
		// to not corrupt the current EAGLContext
		BOOL isMainThread = [NSThread isMainThread];
	
		contentScale = 1;
		fullPath = [path retain];
		GLubyte * pixels = [self loadPixelsFromPath:path];
		
		if( pixels ) {
			EAGLContext * context;
			if( !isMainThread ) {
				context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:sharegroup];
				[EAGLContext setCurrentContext:context];
			}
			
			[self createTextureWithPixels:pixels format:GL_RGBA];
			
			if( !isMainThread ) {
				glFlush();
				[context release];
			}
			
			free(pixels);
		}
	}

	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum)formatp {
	// Create an empty texture
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [@"[Empty]" retain];
		[self setWidth:widthp height:heightp];
		[self createTextureWithPixels:NULL format:formatp];
	}
	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp {
	// Create an empty RGBA texture
	return [self initWithWidth:widthp height:heightp format:GL_RGBA];
}

- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *)pixels {
	// Creates a texture with the given pixels
	
	if( self = [super init] ) {
		contentScale = 1;
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

- (void)createTextureWithPixels:(GLubyte *)pixels format:(GLenum)formatp {
	// Release previous texture if we had one
	if( textureId ) {
		glDeleteTextures( 1, &textureId );
		textureId = 0;
	}

	GLint maxTextureSize;
	glGetIntegerv( GL_MAX_TEXTURE_SIZE, &maxTextureSize );
	
	if( realWidth > maxTextureSize || realHeight > maxTextureSize ) {
		NSLog(@"Warning: Image %@ larger than MAX_TEXTURE_SIZE (%d)", fullPath, maxTextureSize);
	}
	format = formatp;
		
	bool wasEnabled = glIsEnabled(GL_TEXTURE_2D);
	int boundTexture = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
	
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &textureId);
	glBindTexture(GL_TEXTURE_2D, textureId);
	glTexImage2D(GL_TEXTURE_2D, 0, format, realWidth, realHeight, 0, format, GL_UNSIGNED_BYTE, pixels);
	
	[self setFilter:EJTextureGlobalFilter];
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glBindTexture(GL_TEXTURE_2D, boundTexture);
	if( !wasEnabled ) {	glDisable(GL_TEXTURE_2D); }
}

- (void)setFilter:(GLint)filter {
	textureFilter = filter;
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, textureFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, textureFilter);
}

- (void)updateTextureWithPixels:(GLubyte *)pixels atX:(int)x y:(int)y width:(int)subWidth height:(int)subHeight {
	if( !textureId ) { NSLog(@"No texture to update. Call createTexture... first");	return; }
	
	bool wasEnabled = glIsEnabled(GL_TEXTURE_2D);
	int boundTexture = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
	
	glBindTexture(GL_TEXTURE_2D, textureId);
	glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, subWidth, subHeight, format, GL_UNSIGNED_BYTE, pixels);
	
	glBindTexture(GL_TEXTURE_2D, boundTexture);
	if( !wasEnabled ) {	glDisable(GL_TEXTURE_2D); }
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
	if( EJTextureGlobalFilter != textureFilter ) {
		[self setFilter:EJTextureGlobalFilter];
	}
}



@end
