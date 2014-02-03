#import "EJGLProgram2DRadialGradient.h"

@implementation EJGLProgram2DRadialGradient

- (void)getUniforms {
	[super getUniforms];
	
	inner = glGetUniformLocation(program, "inner");
	diff = glGetUniformLocation(program, "diff");
	if(!self.additionalUniforms) {
		self.additionalUniforms = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSValue valueWithPointer:&inner], @"inner",
									[NSValue valueWithPointer:&diff], @"diff", nil];
    }
}

@end
