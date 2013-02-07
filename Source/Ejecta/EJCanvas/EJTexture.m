#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EJTexture.h"
#import "lodepng/lodepng.h"
#import "EJConvertWebGL.h"

#import "EJJavaScriptView.h"


@implementation EJTextureStorage
@synthesize textureId;
@synthesize immutable;

- (id)init {
	if( self = [super init] ) {
		glGenTextures(1, &textureId);
		immutable = NO;
	}
	return self;
}

- (id)initImmutable {
	if( self = [super init] ) {
		glGenTextures(1, &textureId);
		immutable = YES;
	}
	return self;
}

- (void)dealloc {
	if( textureId ) {
		glDeleteTextures(1, &textureId);
	}
	[super dealloc];
}

- (void)bindToTarget:(GLenum)target withParams:(EJTextureParam *)newParams {
	glBindTexture(target, textureId);
	
	// Check if we have to set a param
	if(params[kEJTextureParamMinFilter] != newParams[kEJTextureParamMinFilter]) {
		params[kEJTextureParamMinFilter] = newParams[kEJTextureParamMinFilter];
		glTexParameteri(target, GL_TEXTURE_MIN_FILTER, params[kEJTextureParamMinFilter]);
	}
	if(params[kEJTextureParamMagFilter] != newParams[kEJTextureParamMagFilter]) {
		params[kEJTextureParamMagFilter] = newParams[kEJTextureParamMagFilter];
		glTexParameteri(target, GL_TEXTURE_MAG_FILTER, params[kEJTextureParamMagFilter]);
	}
	if(params[kEJTextureParamWrapS] != newParams[kEJTextureParamWrapS]) {
		params[kEJTextureParamWrapS] = newParams[kEJTextureParamWrapS];
		glTexParameteri(target, GL_TEXTURE_WRAP_S, params[kEJTextureParamWrapS]);
	}
	if(params[kEJTextureParamWrapT] != newParams[kEJTextureParamWrapT]) {
		params[kEJTextureParamWrapT] = newParams[kEJTextureParamWrapT];
		glTexParameteri(target, GL_TEXTURE_WRAP_T, params[kEJTextureParamWrapT]);
	}
}

@end





@implementation EJTexture

@synthesize contentScale;
@synthesize format;
@synthesize width, height;

- (id)initEmptyForWebGL {
	// For WebGL textures; this will not create a textureStorage
	
	if( self = [super init] ) {
		contentScale = 1;
		owningContext = kEJTextureOwningContextWebGL;
		
		params[kEJTextureParamMinFilter] = GL_LINEAR;
		params[kEJTextureParamMagFilter] = GL_LINEAR;
		params[kEJTextureParamWrapS] = GL_REPEAT;
		params[kEJTextureParamWrapT] = GL_REPEAT;
	}
	return self;
}

- (id)initWithPath:(NSString *)path {
	// For loading on the main thread (blocking)
	
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [path retain];
		owningContext = kEJTextureOwningContextCanvas2D;
		
		NSMutableData * pixels = [self loadPixelsFromPath:path];
		[self createWithPixels:pixels format:GL_RGBA];
	}

	return self;
}

+ (id)cachedTextureWithPath:(NSString *)path callback:(void (^)(void))callback {
	// For loading on a background thread (non-blocking), but tries the cache first
	
	EJTexture * texture = [[EJJavaScriptView sharedView].textureCache objectForKey:path];
	if( texture ) {
		// We already have a texture, but it may hasn't finished loading yet. If
		// the texture's loadCallback is still present, add it as an dependency
		// for the current callback.
		
		NSBlockOperation * callbackOp = [NSBlockOperation blockOperationWithBlock:callback];
		if( texture->loadCallback ) {
			[callbackOp addDependency:texture->loadCallback];
		}
		[[NSOperationQueue mainQueue] addOperation:callbackOp];
	}
	else {
		// Create a new texture and add it to the cache
		texture = [[EJTexture alloc] initWithPath:path callback:callback];
		
		[[EJJavaScriptView sharedView].textureCache setObject:texture forKey:path];
		[texture autorelease];
		texture->cached = true;
	}
	return texture;
}

- (id)initWithPath:(NSString *)path callback:(void (^)(void))callback {
	// For loading on a background thread (non-blocking)
	if( self = [super init] ) {
		contentScale = 1;
		fullPath = [path retain];
		owningContext = kEJTextureOwningContextCanvas2D;
		
		// Load the image file in a background thread
		loadCallback = [[NSBlockOperation blockOperationWithBlock:callback] retain];
		[[EJJavaScriptView sharedView].opQueue addOperationWithBlock:^{
			NSMutableData * pixels = [self loadPixelsFromPath:path];
			
			// Upload the pixel data in the main thread, otherwise the GLContext gets confused.	
			// We could use a sharegroup here, but it turned out quite buggy and has little
			// benefits - the main bottleneck is loading the image file.
			[[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
				[self createWithPixels:pixels format:GL_RGBA];
				[loadCallback start];
				[loadCallback release];
				loadCallback = NULL;
			}]];
			
		}];
	}
	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp {
	// Create an empty RGBA texture
	return [self initWithWidth:widthp height:heightp format:GL_RGBA];
}

- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum)formatp {
	// Create an empty texture
	
	if( self = [super init] ) {
		contentScale = 1;
		owningContext = kEJTextureOwningContextCanvas2D;
		
		width = widthp;
		height = heightp;
		[self createWithPixels:NULL format:formatp];
	}
	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(NSData *)pixels {
	// Creates a texture with the given pixels
	
	if( self = [super init] ) {
		contentScale = 1;
		owningContext = kEJTextureOwningContextCanvas2D;
		
		width = widthp;
		height = heightp;
		[self createWithPixels:pixels format:GL_RGBA];
	}
	return self;
}

- (id)initAsRenderTargetWithWidth:(int)widthp height:(int)heightp fbo:(GLuint)fbop contentScale:(float)contentScalep {
	if( self = [self initWithWidth:widthp*contentScalep height:heightp*contentScalep] ) {
		fbo = fbop;
		contentScale = contentScalep;
	}
	return self;
}

- (void)dealloc {
	if( cached ) {
		[[EJJavaScriptView sharedView].textureCache removeObjectForKey:fullPath];
	}
	[fullPath release];
	[textureStorage release];
	[super dealloc];
}

- (void)ensureMutableKeepPixels:(BOOL)keepPixels forTarget:(GLenum)target {

	// If we have a TextureStorage but it's not mutable (i.e. created by Canvas2D) and
	// we're not the only owner of it, we have to create a new TextureStorage
	if( textureStorage && textureStorage.immutable && textureStorage.retainCount > 1 ) {
	
		// Keep pixel data of the old TextureStorage when creating the new?
		if( keepPixels ) {
			NSMutableData * pixels = self.pixels;
			if( pixels ) {
				[self createWithPixels:pixels format:GL_RGBA target:target];
			}
		}
		else {
			[textureStorage release];
			textureStorage = NULL;
		}
	}
	
	if( !textureStorage ) {
		textureStorage = [[EJTextureStorage alloc] init];
	}
}

- (GLuint)textureId {
	return textureStorage.textureId;
}

- (BOOL)isDynamic {
	return !fullPath;
}

- (id)copyWithZone:(NSZone *)zone {
	EJTexture * copy = [[EJTexture allocWithZone:zone] init];
	
	// This retains the textureStorage object and sets the associated properties
	[copy createWithTexture:self];
	
	// Copy texture parameters and owningContext, not handled
	// by createWithTexture
	memcpy(copy->params, params, sizeof(EJTextureParams));
	copy->owningContext = owningContext;
	
	if( self.isDynamic ) {
		// We want a static copy. So if this texture is used by an FBO, we have to
		// re-create the texture from pixels again
		[copy createWithPixels:self.pixels format:format];
	}

	return copy;
}

- (void)createWithTexture:(EJTexture *)other {
	[textureStorage release];
	[fullPath release];
	
	format = other->format;
	contentScale = other->contentScale;
	fullPath = [other->fullPath retain];
	
	width = other->width;
	height = other->height;
	
	textureStorage = [other->textureStorage retain];
}

- (void)createWithPixels:(NSData *)pixels format:(GLenum)formatp {
	[self createWithPixels:pixels format:formatp target:GL_TEXTURE_2D];
}

- (void)createWithPixels:(NSData *)pixels format:(GLenum)formatp target:(GLenum)target {
	// Release previous texture if we had one
	if( textureStorage ) {
		[textureStorage release];
		textureStorage = NULL;
	}
	
	// Set the default texture params for Canvas2D
	params[kEJTextureParamMinFilter] = GL_LINEAR;
	params[kEJTextureParamMagFilter] = GL_LINEAR;
	params[kEJTextureParamWrapS] = GL_CLAMP_TO_EDGE;
	params[kEJTextureParamWrapT] = GL_CLAMP_TO_EDGE;

	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	
	if( width > maxTextureSize || height > maxTextureSize ) {
		NSLog(@"Warning: Image %@ larger than MAX_TEXTURE_SIZE (%d)", fullPath ? fullPath : @"[Dynamic]", maxTextureSize);
	}
	format = formatp;
	
	GLint boundTexture = 0;
	GLenum bindingName = (target == GL_TEXTURE_2D)
		? GL_TEXTURE_BINDING_2D
		: GL_TEXTURE_BINDING_CUBE_MAP;
	glGetIntegerv(bindingName, &boundTexture);
	
	textureStorage = [[EJTextureStorage alloc] initImmutable];
	[textureStorage bindToTarget:target withParams:params];
	glTexImage2D(target, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, pixels.bytes);
	glBindTexture(target, boundTexture);
}

- (void)updateWithPixels:(NSData *)pixels atX:(int)sx y:(int)sy width:(int)sw height:(int)sh {	
	int boundTexture = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
	
	glBindTexture(GL_TEXTURE_2D, textureStorage.textureId);
	glTexSubImage2D(GL_TEXTURE_2D, 0, sx, sy, sw, sh, format, GL_UNSIGNED_BYTE, pixels.bytes);
	
	glBindTexture(GL_TEXTURE_2D, boundTexture);
}

- (NSMutableData *)pixels {
	if( fullPath ) {
		return [self loadPixelsFromPath:fullPath];
	}
	else if( fbo ) {
		GLint boundFrameBuffer;
		glGetIntegerv( GL_FRAMEBUFFER_BINDING, &boundFrameBuffer );
		
		glBindFramebuffer(GL_FRAMEBUFFER, fbo);
		
		int size = width * height * EJGetBytesPerPixel(GL_UNSIGNED_BYTE, format);
		NSMutableData * data = [NSMutableData dataWithLength:size];
		glReadPixels(0, 0, width, height, format, GL_UNSIGNED_BYTE, data.mutableBytes);
		
		glBindFramebuffer(GL_FRAMEBUFFER, boundFrameBuffer);
		return data;
	}

	NSLog(@"Warning: Can't get pixels from texture - dynamicly created but not attached to an FBO.");
	return NULL;
}

- (NSMutableData *)loadPixelsFromPath:(NSString *)path {
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

- (NSMutableData *)loadPixelsWithCGImageFromPath:(NSString *)path {	
	UIImage * tmpImage = [[UIImage alloc] initWithContentsOfFile:path];
	CGImageRef image = tmpImage.CGImage;
	
	width = CGImageGetWidth(image);
	height = CGImageGetHeight(image);
	
	NSMutableData * pixels = [NSMutableData dataWithLength:width*height*4];
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(pixels.mutableBytes, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	[tmpImage release];
	
	return pixels;
}

- (NSMutableData *)loadPixelsWithLodePNGFromPath:(NSString *)path {
	unsigned int w, h;
	unsigned char * pixels = NULL;
	unsigned int error = lodepng_decode32_file(&pixels, &w, &h, [path UTF8String]);
	
	if( error ) {
		NSLog(@"Error Loading image %@ - %u: %s", path, error, lodepng_error_text(error));
	}
	width = w;
	height = h;
	
	return [NSMutableData dataWithBytesNoCopy:pixels length:w*h*4];
}

- (GLint)getParam:(GLenum)pname {
	if(pname == GL_TEXTURE_MIN_FILTER) return params[kEJTextureParamMinFilter];
	if(pname == GL_TEXTURE_MAG_FILTER) return params[kEJTextureParamMagFilter];
	if(pname == GL_TEXTURE_WRAP_S) return params[kEJTextureParamWrapS];
	if(pname == GL_TEXTURE_WRAP_T) return params[kEJTextureParamWrapT];
	return 0;
}

- (void)setParam:(GLenum)pname param:(GLenum)param {
	if(pname == GL_TEXTURE_MIN_FILTER) params[kEJTextureParamMinFilter] = param;
	else if(pname == GL_TEXTURE_MAG_FILTER) params[kEJTextureParamMagFilter] = param;
	else if(pname == GL_TEXTURE_WRAP_S) params[kEJTextureParamWrapS] = param;
	else if(pname == GL_TEXTURE_WRAP_T) params[kEJTextureParamWrapT] = param;
}

- (void)bindWithFilter:(GLenum)filter {
	params[kEJTextureParamMinFilter] = filter;
	params[kEJTextureParamMagFilter] = filter;
	[textureStorage bindToTarget:GL_TEXTURE_2D withParams:params];
}

- (void)bindToTarget:(GLenum)target {
	[textureStorage bindToTarget:target withParams:params];
}



@end
