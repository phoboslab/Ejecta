#import "EJBindingBase.h"
#import "EJGLProgram2D.h"

typedef struct {
	void (*glUniformFunction)(GLint, GLsizei, const void *);
	int count;
	void *values;
	GLint location;
} EJUniform;

@interface EJBindingMaterial : EJBindingBase {
	// TODO: Should it wrap a Material object?
	EJGLProgram2D *program;
	NSString *shaderName;
	BOOL hasChanged;
	int uniformsCount;
	EJUniform *uniforms;
}

@property (readonly, nonatomic) EJGLProgram2D *program;
@property (nonatomic, retain) NSString *shaderName;
@property (nonatomic) BOOL hasChanged;
@property (readonly, nonatomic) int uniformsCount;
@property (readonly, nonatomic) EJUniform *uniforms;

@end
