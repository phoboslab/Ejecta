// Subclass of EJGLProgramm2D for the radial gradient fragment shader, because
// this shader has two special uniforms that describe the gradient.

#import "EJGLProgram2D.h"

@interface EJGLProgram2DRadialGradient : EJGLProgram2D {
	GLuint inner, diff;
}

@property (nonatomic, readonly) GLuint inner;
@property (nonatomic, readonly) GLuint diff;

@end
