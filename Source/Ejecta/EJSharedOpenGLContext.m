#import "EJSharedOpenGLContext.h"
#import "EJCanvas/2D/EJCanvasShaders.h"

@implementation EJSharedOpenGLContext

@synthesize programFlat;
@synthesize programTexture;
@synthesize programAlphaTexture;
@synthesize programPattern;
@synthesize programRadialGradient;
@synthesize glContext2D;
@synthesize glSharegroup;

static EJSharedOpenGLContext *sharedOpenGLContext;
+ (EJSharedOpenGLContext *)instance {
	if( !sharedOpenGLContext ) {
		sharedOpenGLContext = [[EJSharedOpenGLContext new] autorelease];
	}
    return sharedOpenGLContext;
}

- (id)init {
	if( self = [super init] ) {
		glContext2D = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		glSharegroup = glContext2D.sharegroup;
	}
	return self;
}

- (void)dealloc {
	sharedOpenGLContext = nil;
	
	[programFlat release];
	[programTexture release];
	[programAlphaTexture release];
	[programPattern release];
	[programRadialGradient release];
	[glContext2D release];
	[vertexBuffer release];
	
	[EAGLContext setCurrentContext:nil];
	[super dealloc];
}

- (NSMutableData *)vertexBuffer {
	if( !vertexBuffer ) {
		vertexBuffer = [[NSMutableData alloc] initWithLength:EJ_OPENGL_VERTEX_BUFFER_SIZE];
	}
	return vertexBuffer;
}

#define EJ_GL_PROGRAM_GETTER(TYPE, NAME) \
	- (TYPE *)program##NAME { \
		if( !program##NAME ) { \
			program##NAME = [[TYPE alloc] initWithVertexShader:EJShaderVertex fragmentShader:EJShader##NAME]; \
		} \
	return program##NAME; \
	}

EJ_GL_PROGRAM_GETTER(EJGLProgram2D, Flat);
EJ_GL_PROGRAM_GETTER(EJGLProgram2D, Texture);
EJ_GL_PROGRAM_GETTER(EJGLProgram2D, AlphaTexture);
EJ_GL_PROGRAM_GETTER(EJGLProgram2D, Pattern);
EJ_GL_PROGRAM_GETTER(EJGLProgram2DRadialGradient, RadialGradient);

#undef EJ_GL_PROGRAM_GETTER

@end
