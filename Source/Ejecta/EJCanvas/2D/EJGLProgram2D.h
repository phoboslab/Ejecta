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

- (GLint)compileShader:(NSString *)file type:(GLenum)type;
- (void)linkProgram;

+ (id)instance;

@property (nonatomic) GLuint program;
@property (nonatomic) GLuint scale;
@property (nonatomic) GLuint translate;
@property (nonatomic) GLuint textureFormat;

@end
