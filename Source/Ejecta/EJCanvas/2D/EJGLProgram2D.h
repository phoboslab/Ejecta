#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "EJCanvas2DTypes.h"

enum {
	kEJGLProgram2DAttributePos,
	kEJGLProgram2DAttributeUV,
	kEJGLProgram2DAttributeColor,
};

@interface EJGLProgram2D : NSObject {
	GLuint program;
	GLuint scale, translate, textureFormat;
}

- (void)createProgram;

+ (GLint)compileShaderFile:(NSString *)file type:(GLenum)type;
+ (GLint)compileShaderSource:(NSString *)source type:(GLenum)type;
+ (void)linkProgram:(GLuint)program;

@property (nonatomic, readonly) GLuint program;

@property (nonatomic, readonly) GLuint scale;
@property (nonatomic, readonly) GLuint translate;
@property (nonatomic, readonly) GLuint textureFormat;

@end
