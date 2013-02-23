#import "EJGLProgram2D.h"

@implementation EJGLProgram2D

@synthesize program;
@synthesize screen;

- (id)initWithVertexShader:(NSString *)vertexShaderFile fragmentShader:(NSString *)fragmentShaderFile {
	if( self = [super init] ) {
		program = glCreateProgram();
		GLuint vertexShader = [EJGLProgram2D compileShaderFile:vertexShaderFile type:GL_VERTEX_SHADER];
		GLuint fragmentShader = [EJGLProgram2D compileShaderFile:fragmentShaderFile type:GL_FRAGMENT_SHADER];

		glAttachShader(program, vertexShader);
		glAttachShader(program, fragmentShader);
		
		[self bindAttributeLocations];
		
		[EJGLProgram2D linkProgram:program];

		[self getUniforms];
		
		glDetachShader(program, vertexShader);
		glDeleteShader(vertexShader);
		
		glDetachShader(program, fragmentShader);
		glDeleteShader(fragmentShader);
	}
	return self;
}

- (void)dealloc {
	if( program ) { glDeleteProgram(program); }
	[super dealloc];
}

- (void)bindAttributeLocations {
	glBindAttribLocation(program, kEJGLProgram2DAttributePos, "pos");
	glBindAttribLocation(program, kEJGLProgram2DAttributeUV, "uv");
	glBindAttribLocation(program, kEJGLProgram2DAttributeColor, "color");
}

- (void)getUniforms {
	screen = glGetUniformLocation(program, "screen");
}

+ (GLint)compileShaderFile:(NSString *)file type:(GLenum)type {
	NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], file];
	NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	if( !source ) {
		NSLog(@"Failed to load shader file %@", file);
		return 0;
	}

	return [EJGLProgram2D compileShaderSource:source type:type];
}

+ (GLint)compileShaderSource:(NSString *)source type:(GLenum)type {
	const GLchar *glsource = (GLchar *)[source UTF8String];
	
	GLint shader = glCreateShader(type);
	glShaderSource(shader, 1, &glsource, NULL);
	glCompileShader(shader);

	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if( status == 0 ) {
		GLint logLength;
		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
		if( logLength > 0 ) {
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(shader, logLength, &logLength, log);
			NSLog(@"Shader compile log:\n%s", log);
			free(log);
		}
		glDeleteShader(shader);
		return 0;
	}

	return shader;
}

+ (void)linkProgram:(GLuint)program {
	GLint status;
	glLinkProgram(program);

	glGetProgramiv(program, GL_LINK_STATUS, &status);
	if( status == 0 ) {
		GLint logLength;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
		if( logLength > 0 ) {
			GLchar *log = (GLchar *)malloc(logLength);
			glGetProgramInfoLog(program, logLength, &logLength, log);
			NSLog(@"Program link log:\n%s", log);
			free(log);
		}
	}
}

@end
