#import "EJGLProgram2DTint.h"

@implementation EJGLProgram2DTint

- (void)getUniforms {
	[super getUniforms];
	
    tintAdd = glGetUniformLocation(program, "tintAdd");
    tintMul = glGetUniformLocation(program, "tintMul");
    if(!self.additionalUniforms) {
        self.additionalUniforms = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSValue valueWithPointer:&tintAdd], @"tintAdd",
                                   [NSValue valueWithPointer:&tintMul], @"tintMul", nil];
    }
}

@end
