#import "EJGLProgram2D.h"

@implementation EJGLProgram2D
@synthesize program;

@synthesize scale, translate, textureFormat;

static EJGLProgram2D * instance = NULL;

+ (id)instance {
	if( !instance ) {
		instance = [[[EJGLProgram2D alloc] init] autorelease];
	}
	return instance;
}

- (id)init {
	if( self = [super init] ) {
		program = glCreateProgram();
		GLuint vertexShader = [self compileShader:@"EJGLProgram2D.vsh" type:GL_VERTEX_SHADER];
		GLuint fragmentShader = [self compileShader:@"EJGLProgram2D.fsh" type:GL_FRAGMENT_SHADER];

		glAttachShader(program, vertexShader);
		glAttachShader(program, fragmentShader);
		
		glBindAttribLocation(program, kEJGLProgram2DAttributePos, "pos");
		glBindAttribLocation(program, kEJGLProgram2DAttributeUV, "uv");
		glBindAttribLocation(program, kEJGLProgram2DAttributeColor, "color");
		
		[self linkProgram];
		
		scale = glGetUniformLocation(program, "scale");
		translate = glGetUniformLocation(program, "translate");
		textureFormat = glGetUniformLocation(program, "textureFormat");
		
		if( vertexShader ) {
			glDetachShader(program, vertexShader);
			glDeleteShader(vertexShader);
		}
		if( fragmentShader ) {
			glDetachShader(program, fragmentShader);
			glDeleteShader(fragmentShader);
		}
	}
	return self;
}

- (void)dealloc {
	if( program ) {
		glDeleteProgram(program);
	}
	[super dealloc];
}

- (GLint)compileShader:(NSString *)file type:(GLenum)type {
	NSString * path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], file];
	const GLchar * source = (GLchar *)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return NO;
	}

	GLint shader = glCreateShader(type);
	glShaderSource(shader, 1, &source, NULL);
	glCompileShader(shader);

	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
		GLint logLength;
		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
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

- (void)linkProgram {
    GLint status;
    glLinkProgram(program);

    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if( status == 0 ) {
		GLint logLength;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
			GLchar *log = (GLchar *)malloc(logLength);
			glGetProgramInfoLog(program, logLength, &logLength, log);
			NSLog(@"Program link log:\n%s", log);
			free(log);
		}
    }
}

@end
