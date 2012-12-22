#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

typedef enum {
	kEJTextureParamMinFilter,
	kEJTextureParamMagFilter,
	kEJTextureParamWrapS,
	kEJTextureParamWrapT,
	kEJTextureParamLast
} EJTextureParam;

typedef EJTextureParam EJTextureParams[kEJTextureParamLast];


@interface EJTextureObject : NSObject {
	EJTextureParams params;
	GLuint textureId;
	BOOL immutable;
}
- (void)bindToTarget:(GLenum)target withParams:(EJTextureParam *)newParams;
@property (readonly, nonatomic) GLuint textureId;
@property (nonatomic) BOOL immutable;
@end



typedef enum {
	kEJTextureOwningContextCanvas2D,
	kEJTextureOwningContextWebGL
} EJTextureOwningContext;

@interface EJTexture : NSObject {
	short width, height;
	NSString * fullPath;
	EJTextureObject * textureObject;
	GLenum format;
	float contentScale;
	
	EJTextureOwningContext owningContext;
	EJTextureParams params;
}
- (id)initEmptyForWebGL;
- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path sharegroup:(EAGLSharegroup*)sharegroup;
- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum) format;
- (id)initWithWidth:(int)widthp height:(int)heightp;
- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(const GLubyte *)pixels;

- (void)ensureMutableKeepPixels:(BOOL)keepPixels forTarget:(GLenum)target;

- (void)createWithTexture:(EJTexture *)other;
- (void)createWithPixels:(const GLubyte *)pixels format:(GLenum)format;
- (void)createWithPixels:(const GLubyte *)pixels format:(GLenum)formatp target:(GLenum)target;
- (void)updateWithPixels:(const GLubyte *)pixels atX:(int)x y:(int)y width:(int)subWidth height:(int)subHeight;

- (GLubyte *)loadPixelsFromPath:(NSString *)path;
- (GLubyte *)loadPixelsWithCGImageFromPath:(NSString *)path;
- (GLubyte *)loadPixelsWithLodePNGFromPath:(NSString *)path;

- (GLint)getParam:(GLenum)pname;
- (void)setParam:(GLenum)pname param:(GLenum)param;

- (void)bind;
- (void)bindToTarget:(GLenum)target;

+ (BOOL)smoothScaling;
+ (void)setSmoothScaling:(BOOL)smoothScaling;

@property (readonly, nonatomic) NSMutableData * pixels;
@property (readonly, nonatomic)	float contentScale;
@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) GLenum format;
@property (readonly, nonatomic) short width, height;

@end
