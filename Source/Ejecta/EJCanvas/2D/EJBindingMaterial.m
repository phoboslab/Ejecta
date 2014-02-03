#import "EJBindingMaterial.h"

#import "EJConvertWebGL.h"

@implementation EJBindingMaterial
@synthesize program;
@synthesize hasChanged;
@synthesize uniformsCount;
@synthesize uniforms;

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	hasChanged = false;
	uniformsCount = 0;
	uniforms = NULL;
}

- (void)dealloc {
	[shaderName release];
	shaderName = nil;
	// Remove the uniforms allocated manually
	[self freeUniforms];
	
	[super dealloc];
}

- (void)assignProgramWithName:(NSString *)name {
	// Check first if a shader program with the specified name exists
	EJSharedOpenGLContext *sharedGLContext = scriptView.openGLContext;
	NSString *propertySuffix = @"glProgram2D";
	NSString *selectorName = [propertySuffix stringByAppendingString:name];
	SEL programSelector = NSSelectorFromString(selectorName);
	
	if ([sharedGLContext respondsToSelector:programSelector]) {
		program = [sharedGLContext performSelector:programSelector];
		if (program) {
			if (shaderName) {
				[shaderName release];
			}
			shaderName = [name retain];
			
            [self freeUniforms];
			uniformsCount = program.additionalUniforms.count;
			uniforms = (EJUniform *)malloc(uniformsCount * sizeof(EJUniform));
			int i = 0;
			for (NSString *key in program.additionalUniforms) {
				NSValue *locationValue = [program.additionalUniforms objectForKey:key];
				GLint *location;
				[locationValue getValue:&location];
				uniforms[i].glUniformFunction = NULL;
				uniforms[i].count = 0;
				uniforms[i].values = NULL;
				uniforms[i].location = *location;
				++i;
			}
		}
	} else {
		return;
	}
}

- (void)freeUniforms {
	if (uniforms != NULL) {
		for (int i = 0; i < uniformsCount; ++i) {
			free(uniforms[i].values);
		}
		free(uniforms);
		uniforms = NULL;
		uniformsCount = 0;
	}
}

EJ_BIND_GET(shader, ctx) {
	JSStringRef shader = JSStringCreateWithUTF8CString([shaderName UTF8String]);
	JSValueRef ret = JSValueMakeString(ctx, shader);
	JSStringRelease(shader);
	return ret;
}

EJ_BIND_SET(shader, ctx, value) {
	NSString *newShaderName = JSValueToNSString(ctx, value);
	
	// Same as the old shader name? Nothing to do here
	if ([shaderName isEqualToString:newShaderName]) {
		return;
	}
	
    hasChanged = true;
	
	// Release the old shader name and the program?
	if (shaderName) {
		[shaderName release];
		shaderName = nil;
	}
	[self freeUniforms];
	
	program = nil;
	
	if (!JSValueIsNull(ctx, value) && [newShaderName length]) {
		[self assignProgramWithName:newShaderName];
	}
}

// TODO: Support Matrix uniforms too
EJ_BIND_FUNCTION(setUniform, ctx, argc, argv) {
	if (argc < 2) {
		return NULL;
	}
	
	if (JSValueIsNull(ctx, argv[0]) || JSValueIsNull(ctx, argv[1])) {
		return NULL;
	}
	
	NSString *uniform = JSValueToNSString(ctx, argv[0]);
	NSString *uniformType = JSValueToNSString(ctx, argv[1]);
	
	if ([uniform length] && [uniformType length])  {
		NSValue *locationValue = [program.additionalUniforms objectForKey:uniform];
		if (locationValue) {
			EJUniform *newUniform = NULL;
			GLint *location;

			[locationValue getValue:&location];
			for (int i = 0; i < uniformsCount; ++i) {
				if (uniforms[i].location == *location) {
					newUniform = &uniforms[i];
					break;
				}
			}
			if (newUniform != NULL) {
				GLsizei count = 0;
				void *values;
				size_t uniformArraySize;
				
				// Check if the uniform type is recognized
				// TODO: Capture error?
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"gluniform([1234][f|i])v?"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
				NSUInteger numberMatches = [regex numberOfMatchesInString:uniformType
                                                                  options:0
																	range:NSMakeRange(0, [uniformType length])];
				if (numberMatches == 1) {
					// Extract the uniform type
					NSString *componentType = [regex stringByReplacingMatchesInString:uniformType
                                                                              options:0
																				range:NSMakeRange(0, [uniformType length])
                                                                         withTemplate:@"$1"];

					if ([componentType hasSuffix:@"f"]) {
						values = JSValueToGLfloatArray(ctx, argv[2], 1, &count);
						uniformArraySize = count * sizeof(GLfloat);
					} else if ([uniformType hasSuffix:@"i"]) {
						values = JSValueToGLintArray(ctx, argv[2], 1, &count);
						uniformArraySize = count * sizeof(GLint);
					}
					               
					if (count > 0) {
						void *uniformValues = malloc(uniformArraySize);;
						memcpy(uniformValues, values, uniformArraySize);
						if (newUniform->values != NULL) {
							free(newUniform->values);
						}
						newUniform->values = uniformValues;
						
						if ([componentType isEqualToString:@"1f"]) {
							newUniform->count = count;
							newUniform->glUniformFunction = glUniform1fv;
						} else if ([componentType isEqualToString:@"2f"]) {
							newUniform->count = floor((float)count/2);
							newUniform->glUniformFunction = glUniform2fv;
						} else if ([componentType isEqualToString:@"3f"]) {
							newUniform->count = floor((float)count/3);
							newUniform->glUniformFunction = glUniform3fv;
						} else if ([componentType isEqualToString:@"4f"]) {
							newUniform->count = floor((float)count/4);
							newUniform->glUniformFunction = glUniform4fv;
						} else if ([componentType isEqualToString:@"1i"]) {
							newUniform->count = count;
							newUniform->glUniformFunction = glUniform1iv;
						} else if ([componentType isEqualToString:@"2i"]) {
							newUniform->count = floor((float)count/2);
							newUniform->glUniformFunction = glUniform2iv;
						} else if ([componentType isEqualToString:@"3i"]) {
							newUniform->count = floor((float)count/3);
							newUniform->glUniformFunction = glUniform3iv;
						} else if ([componentType isEqualToString:@"4i"]) {
							newUniform->count = floor((float)count/4);
							newUniform->glUniformFunction = glUniform4iv;
						}
						
						hasChanged = true;
					}
				} else {
					NSLog(@"Warning: Uniform type not recognized. Matrix uniforms and unsigned int types are not currently supported.");
				}
			}
		}
	}
	
	return NULL;
}

@end
