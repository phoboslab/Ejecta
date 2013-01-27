#import "EJGLProgram2DRadialGradient.h"

@implementation EJGLProgram2DRadialGradient

@synthesize inner, diff;

- (void)createProgram {
	program = glCreateProgram();
	GLuint vertexShader = [EJGLProgram2D compileShaderFile:@"Default.vsh" type:GL_VERTEX_SHADER];
	GLuint fragmentShader = [EJGLProgram2D compileShaderFile:@"RadialGradient.fsh" type:GL_FRAGMENT_SHADER];

	glAttachShader(program, vertexShader);
	glAttachShader(program, fragmentShader);
	
	glBindAttribLocation(program, kEJGLProgram2DAttributePos, "pos");
	glBindAttribLocation(program, kEJGLProgram2DAttributeUV, "uv");
	glBindAttribLocation(program, kEJGLProgram2DAttributeColor, "color");
	
	[EJGLProgram2D linkProgram:program];
	
	scale = glGetUniformLocation(program, "scale");
	translate = glGetUniformLocation(program, "translate");
	
	inner = glGetUniformLocation(program, "inner");
	diff = glGetUniformLocation(program, "diff");
	
	if( vertexShader ) {
		glDetachShader(program, vertexShader);
		glDeleteShader(vertexShader);
	}
	if( fragmentShader ) {
		glDetachShader(program, fragmentShader);
		glDeleteShader(fragmentShader);
	}
}

@end
