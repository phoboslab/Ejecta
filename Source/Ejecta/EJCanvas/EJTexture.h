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


@interface EJTextureStorage : NSObject {
	EJTextureParams params;
	GLuint textureId;
	BOOL immutable;
}
- (id)init;
- (id)initImmutable;
- (void)bindToTarget:(GLenum)target withParams:(EJTextureParam *)newParams;
@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) BOOL immutable;
@end


typedef enum {
	kEJTextureOwningContextCanvas2D,
	kEJTextureOwningContextWebGL
} EJTextureOwningContext;

@interface EJTexture : NSObject <NSCopying> {
	short width, height;
	NSString * fullPath;
	EJTextureStorage * textureStorage;
	GLenum format;
	GLuint fbo;
	float contentScale;
	
	EJTextureOwningContext owningContext;
	EJTextureParams params;
	id callbackTarget;
	SEL callbackSelector;
}
- (id)initEmptyForWebGL;
- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path loadOnQueue:(NSOperationQueue *)queue withTarget:(id)target selector:(SEL)selector;

- (id)initWithWidth:(int)widthp height:(int)heightp;
- (id)initWithWidth:(int)widthp height:(int)heightp format:(GLenum) format;
- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(NSMutableData *)pixels;
- (id)initAsRenderTargetWithWidth:(int)widthp height:(int)heightp fbo:(GLuint)fbo contentScale:(float)contentScalep;

- (void)ensureMutableKeepPixels:(BOOL)keepPixels forTarget:(GLenum)target;

- (void)createWithTexture:(EJTexture *)other;
- (void)createWithPixels:(NSMutableData *)pixels format:(GLenum)format;
- (void)createWithPixels:(NSMutableData *)pixels format:(GLenum)formatp target:(GLenum)target;
- (void)updateWithPixels:(NSData *)pixels atX:(int)x y:(int)y width:(int)subWidth height:(int)subHeight;

- (NSMutableData *)loadPixelsFromPath:(NSString *)path;
- (NSMutableData *)loadPixelsWithCGImageFromPath:(NSString *)path;
- (NSMutableData *)loadPixelsWithLodePNGFromPath:(NSString *)path;

- (GLint)getParam:(GLenum)pname;
- (void)setParam:(GLenum)pname param:(GLenum)param;

- (void)bind;
- (void)bindToTarget:(GLenum)target;

+ (BOOL)smoothScaling;
+ (void)setSmoothScaling:(BOOL)smoothScaling;

@property (readonly, nonatomic) BOOL isDynamic;
@property (readonly, nonatomic) NSMutableData * pixels;
@property (readonly, nonatomic)	float contentScale;
@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) GLenum format;
@property (readonly, nonatomic) short width, height;

@end
