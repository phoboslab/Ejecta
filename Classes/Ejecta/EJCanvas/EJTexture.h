#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface EJTexture : NSObject {
	short width, height, realWidth, realHeight;
	NSString * fullPath;
	GLuint textureId;
}
- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path context:(EAGLContext*)context;
- (id)initWithWidth:(int)widthp height:(int)heightp;
- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *)pixels;
- (id)initWithString:(NSString *)string font:(UIFont *)font fill:(BOOL)fill lineWidth:(float)lineWidth;

- (void)setWidth:(int)width height:(int)height;
- (void)createTextureWithPixels:(GLubyte *)pixels format:(GLenum) format;

- (GLubyte *)loadPixelsFromPath:(NSString *)path;
- (GLubyte *)loadPixelsWithCGImageFromPath:(NSString *)path;
- (GLubyte *)loadPixelsWithLodePNGFromPath:(NSString *)path;

- (void)bind;

+ (BOOL)smoothScaling;
+ (void)setSmoothScaling:(BOOL)smoothScaling;

@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) short width, height, realWidth, realHeight;

@end
