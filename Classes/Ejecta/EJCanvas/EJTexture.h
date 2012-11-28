#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface EJTexture : NSObject {
	short width, height, realWidth, realHeight;
	NSString * fullPath;
	GLuint textureId;
    GLubyte *pixels;
	GLenum format;
	float contentScale;
	GLint textureFilter;
}
- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path sharegroup:(EAGLSharegroup*)sharegroup;
- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum) format;
- (id)initWithWidth:(int)widthp height:(int)heightp;
- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *)pixels;

- (void)setWidth:(int)width height:(int)height;

- (GLubyte *)loadPixelsFromPath:(NSString *)path;
- (GLubyte *)loadPixelsWithCGImageFromPath:(NSString *)path;
- (GLubyte *)loadPixelsWithLodePNGFromPath:(NSString *)path;
- (GLubyte *)getFlippedYPixels;

- (void)updateTextureWithPixels:(GLubyte *)pixels atX:(int)x y:(int)y width:(int)subWidth height:(int)subHeight;
- (void)bind;

+ (BOOL)smoothScaling;
+ (void)setSmoothScaling:(BOOL)smoothScaling;

@property (readonly, nonatomic)	float contentScale;
@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) GLubyte *pixels;
@property (readonly, nonatomic) short width, height, realWidth, realHeight;

@end
