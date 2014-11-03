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
	GLuint screen;
}

- (id)initWithVertexShader:(NSString *)vertexShaderFile fragmentShader:(NSString *)fragmentShaderFile;
- (id)initWithVertexShaderSource:(NSString *)vertexShaderSource fragmentShaderSource:(NSString *)fragmentShaderSource;
- (void)bindAttributeLocations;
- (void)getUniforms;

+ (GLint)compileShaderFile:(NSString *)file type:(GLenum)type;
+ (GLint)compileShaderSource:(NSString *)source type:(GLenum)type;
+ (void)linkProgram:(GLuint)program;

@property (nonatomic, readonly) GLuint program;
@property (nonatomic, readonly) GLuint screen;

@end
