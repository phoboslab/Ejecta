// The Texture class is used for everything that provides pixel data in some way
// and should be drawable to a Context. The most obvious use case is as the
// pixel data of an Image element. However, Canvas elements themselfs may need
// to be drawn to other Canvases and thus create a Texture of their contents on
// the fly.

// EJTexture is also extensively used in 2D Contexts for Fonts, Gradients,
// Patterns and ImageData.

// A lot of work goes into making sure that Textures can be shared between
// different 2D and WebGL contexts and keeping track of mutability. The actual
// Texture Data is held in a separate EJTextureStorage class, so that 2D and
// WebGL textures can share the same data, but have different binding
// attributes. This also allows us to release and reload the texture's pixel
// data on demand while keeping the Texture itself around.

// All textures are represented with premultiplied alpha in memory. However,
// ImageData objects for 2D Canvases expect the raw pixel data to be
// unpremultiplied, so this class provides some static methods to premultiply
// and unpremultiply raw pixel data.

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "EJTextureStorage.h"

@interface EJTexture : NSObject <NSCopying> {
	BOOL cached;
	BOOL drawFlippedY;
	BOOL isCompressed;
	BOOL lazyLoaded;
	BOOL dimensionsKnown;
	short width, height;
	NSString *fullPath;
	EJTextureStorage *textureStorage;
	GLenum format;
	GLuint fbo;
	
	EJTextureParams params;
	NSBlockOperation *loadCallback;
}
- (id)initEmptyForWebGL;
- (id)initWithPath:(NSString *)path;
+ (id)cachedTextureWithPath:(NSString *)path loadOnQueue:(NSOperationQueue *)queue callback:(NSOperation *)callback;
- (id)initWithPath:(NSString *)path loadOnQueue:(NSOperationQueue *)queue callback:(NSOperation *)callback;

- (id)initWithWidth:(int)widthp height:(int)heightp;
- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum) format;
- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(NSData *)pixels;
- (id)initAsRenderTargetWithWidth:(int)widthp height:(int)heightp fbo:(GLuint)fbo;
- (id)initWithUIImage:(UIImage *)image;

- (void)maybeReleaseStorage;

- (void)ensureMutableKeepPixels:(BOOL)keepPixels forTarget:(GLenum)target;

- (void)createWithTexture:(EJTexture *)other;
- (void)createWithPixels:(NSData *)pixels format:(GLenum)format;
- (void)createWithPixels:(NSData *)pixels format:(GLenum)formatp target:(GLenum)target;
- (void)uploadCompressedPixels:(NSData *)pixels target:(GLenum)target;
- (void)updateWithPixels:(NSData *)pixels atX:(int)x y:(int)y width:(int)subWidth height:(int)subHeight;

- (NSMutableData *)loadPixelsFromPath:(NSString *)path;
- (NSMutableData *)loadPixelsFromUIImage:(UIImage *)image;

- (GLint)getParam:(GLenum)pname;
- (void)setParam:(GLenum)pname param:(GLenum)param;

- (void)bindWithFilter:(GLenum)filter;
- (void)bindToTarget:(GLenum)target;

- (UIImage *)image;
+ (UIImage *)imageWithPixels:(NSData *)pixels width:(int)width height:(int)height;

+ (void)premultiplyPixels:(const GLubyte *)inPixels to:(GLubyte *)outPixels byteLength:(int)byteLength format:(GLenum)format;
+ (void)unPremultiplyPixels:(const GLubyte *)inPixels to:(GLubyte *)outPixels byteLength:(int)byteLength format:(GLenum)format;
+ (void)flipPixelsY:(GLubyte *)pixels bytesPerRow:(int)bytesPerRow rows:(int)rows;

@property (readwrite, nonatomic) BOOL drawFlippedY;
@property (readonly, nonatomic) BOOL isDynamic;
@property (readonly, nonatomic) BOOL lazyLoaded;
@property (readonly, nonatomic) NSMutableData *pixels;
@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) GLenum format;
@property (readonly, nonatomic) short width, height;
@property (readonly, nonatomic) NSTimeInterval lastUsed;

@end
