#import "EJBindingCanvasContextWebGL.h"
#import "EJBindingWebGLObjects.h"
#import "EJDrawable.h"
#import "EJTexture.h"
#import "EJConvertGLArray.h"

#import <JavaScriptCore/JSTypedArray.h>


@implementation EJBindingCanvasContextWebGL

- (id)initWithCanvas:(JSObjectRef)canvas renderingContext:(EJCanvasContextWebGL *)renderingContextp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		ejectaInstance = [EJApp instance]; // Keep a local copy - may be faster?
		renderingContext = [renderingContextp retain];
		jsCanvas = canvas;
		
		buffers = [NSMutableDictionary new];
		programs = [NSMutableDictionary new];
		shaders = [NSMutableDictionary new];
		textures = [NSMutableDictionary new];
		framebuffers = [NSMutableDictionary new];
		renderbuffers = [NSMutableDictionary new];
	}
	return self;
}

- (void)dealloc {
	for( NSNumber * n in buffers ) { GLuint buffer = n.intValue; glDeleteBuffers(1, &buffer); }
	[buffers release];
	
	for( NSNumber * n in programs ) { glDeleteProgram(n.intValue); }
	[programs release];
	
	for( NSNumber * n in shaders ) { glDeleteShader(n.intValue); }
	[shaders release];
	
	for( NSNumber * n in textures ) { GLuint texture = n.intValue; glDeleteTextures(1, &texture); }
	[textures release];
	
	for( NSNumber * n in framebuffers ) { GLuint buffer = n.intValue; glDeleteFramebuffers(1, &buffer); }
	[framebuffers release];
	
	for( NSNumber * n in renderbuffers ) { GLuint buffer = n.intValue; glDeleteRenderbuffers(1, &buffer); }
	[renderbuffers release];
	
	[renderingContext release];
	[super dealloc];
}

- (void)deleteBuffer:(GLuint)buffer {
	NSNumber * key = [NSNumber numberWithInt:buffer];
	if( [buffers objectForKey:key] ) {
		glDeleteBuffers(1, &buffer);
		[buffers removeObjectForKey:key];
	}
}

- (void)deleteProgram:(GLuint)program {
	NSNumber * key = [NSNumber numberWithInt:program];
	if( [programs objectForKey:key] ) {
		glDeleteProgram(program);
		[programs removeObjectForKey:key];
	}
}

- (void)deleteShader:(GLuint)shader {
	NSNumber * key = [NSNumber numberWithInt:shader];
	if( [shaders objectForKey:key] ) {
		glDeleteShader(shader);
		[shaders removeObjectForKey:key];
	}

}
- (void)deleteTexture:(GLuint)texture {
	NSNumber * key = [NSNumber numberWithInt:texture];
	if( [textures objectForKey:key] ) {
		glDeleteTextures(1, &texture);
		[textures removeObjectForKey:key];
	}

}
- (void)deleteRenderbuffer:(GLuint)renderbuffer {
	NSNumber * key = [NSNumber numberWithInt:renderbuffer];
	if( [renderbuffers objectForKey:key] ) {
		glDeleteRenderbuffers(1, &renderbuffer);
		[renderbuffers removeObjectForKey:key];
	}

}
- (void)deleteFramebuffer:(GLuint)framebuffer {
	NSNumber * key = [NSNumber numberWithInt:framebuffer];
	if( [framebuffers objectForKey:key] ) {
		glDeleteFramebuffers(1, &framebuffer);
		[framebuffers removeObjectForKey:key];
	}

}



EJ_BIND_GET(canvas, ctx) {
	return jsCanvas;
}

EJ_BIND_GET(drawingBufferWidth, ctx) {
	return JSValueMakeNumber(ctx, renderingContext.width * renderingContext.backingStoreRatio);
}

EJ_BIND_GET(drawinBufferHeight, ctx) {
	return JSValueMakeNumber(ctx, renderingContext.height * renderingContext.backingStoreRatio);
}



// ------------------------------------------------------------------------------------
// Methods


// Shorthand to directly bind a c function that only takes numbers
#define EJ_BIND_FUNCTION_DIRECT(NAME, BINDING, ...) \
	EJ_BIND_FUNCTION(NAME, ctx, argc, argv) { \
		if( argc < EJ_ARGC(__VA_ARGS__) ) { return NULL; } \
		BINDING( EJ_MAP_EXT(0, _EJ_COMMA, _EJ_BIND_FUNCTION_DIRECT_UNPACK, __VA_ARGS__) ); \
		return NULL;\
	}
#define _EJ_BIND_FUNCTION_DIRECT_UNPACK(INDEX, IGNORED) JSValueToNumberFast(ctx, argv[INDEX])


EJ_BIND_FUNCTION(getContextAttributes, ctx, argc, argv) {
	// TODO WebGLContextAttributes getContextAttributes()
	return NULL;
}

EJ_BIND_FUNCTION(isContextLost, ctx, argc, argv) {
	return JSValueMakeBoolean(ctx, false);
}

EJ_BIND_FUNCTION(getSupportedExtensions, ctx, argc, argv) {
	return JSObjectMakeArray(ctx, 0, NULL, NULL);
}

EJ_BIND_FUNCTION(getExtension, ctx, argc, argv) {
	return NULL;
}

EJ_BIND_FUNCTION(activeTexture, ctx, argc, argv) {
	if ( argc < 1 ) { return NULL; }
	GLenum texture = JSValueToNumberFast(ctx, argv[0]);
	glActiveTexture(texture);
	return NULL;
}

EJ_BIND_FUNCTION(attachShader, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[1]];
	glAttachShader(program, shader);
	return NULL;
}

EJ_BIND_FUNCTION(bindAttribLocation, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLuint index = JSValueToNumberFast(ctx, argv[1]);
	NSString * name = JSValueToNSString(ctx, argv[2]);
	
	glBindAttribLocation(program, index, [name UTF8String]);
	return NULL;
}


#define EJ_BIND_BIND(I, NAME) \
	EJ_BIND_FUNCTION(bind##NAME, ctx, argc, argv) { \
		if( argc < 2 ) { return NULL; } \
		GLenum target = JSValueToNumberFast(ctx, argv[0]); \
		GLuint index = [EJBindingWebGL##NAME indexFromJSValue:argv[1]]; \
		glBind##NAME(target, index); \
		return NULL; \
	}

	EJ_MAP(EJ_BIND_BIND, Framebuffer, Renderbuffer, Buffer, Texture);

#undef EJ_BIND_BIND


EJ_BIND_FUNCTION_DIRECT(blendColor, glBlendColor, red, green, blue, alpha);
EJ_BIND_FUNCTION_DIRECT(blendEquation, glBlendEquation, mode);
EJ_BIND_FUNCTION_DIRECT(blendEquationSeparate, glBlendEquationSeparate, modeRGB, modeAlpha);
EJ_BIND_FUNCTION_DIRECT(blendFunc, glBlendFunc, sfactor, dfactor);
EJ_BIND_FUNCTION_DIRECT(blendFuncSeparate, glBlendFuncSeparate, srcRGB, dstRGB, srcAlpha, dstAlpha);

EJ_BIND_FUNCTION(bufferData, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum usage = JSValueToNumberFast(ctx, argv[2]);

	size_t size;
	GLvoid * buffer = JSTypedArrayGetDataPtr(ctx, argv[1], &size);
	if( buffer ) {
		glBufferData(target, size, buffer, usage);
	}
	else {
		// 2nd param is not an array? Must be the size; initialize empty
		GLintptr psize = JSValueToNumberFast(ctx, argv[1]);
		glBufferData(target, psize, NULL, usage);
	}
	return NULL;
}

EJ_BIND_FUNCTION(bufferSubData, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }

	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLintptr offset = JSValueToNumberFast(ctx, argv[2]);

	size_t size;
	GLvoid * buffer = JSTypedArrayGetDataPtr(ctx, argv[1], &size);
	if( buffer ) {
		glBufferSubData(target, offset, size, buffer);
	}
	return NULL;
}

EJ_BIND_FUNCTION(checkFramebufferStatus, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	return JSValueMakeNumber(ctx, glCheckFramebufferStatus(target));
}

EJ_BIND_FUNCTION_DIRECT(clear, glClear, mask);
EJ_BIND_FUNCTION_DIRECT(clearColor, glClearColor, red, green, blue, alpha);
EJ_BIND_FUNCTION_DIRECT(clearDepth, glClearDepthf, depth);
EJ_BIND_FUNCTION_DIRECT(clearStencil, glClearStencil, s);
EJ_BIND_FUNCTION_DIRECT(colorMask, glColorMask, red, green, blue, alpha);

EJ_BIND_FUNCTION(compileShader, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];
	glCompileShader(shader);
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(copyTexImage2D, glCopyTexImage2D, target, level, internalformat, x, y, width, height, border);
EJ_BIND_FUNCTION_DIRECT(copyTexSubImage2D, glCopyTexSubImage2D, target, level, xoffset, yoffset, x, y, width, height);

#define EJ_BIND_CREATE(I, NAME) \
	EJ_BIND_FUNCTION(create##NAME, ctx, argc, argv) { \
		GLuint index; \
		glGen##NAME##s(1, &index); \
		JSObjectRef obj = [EJBindingWebGL##NAME createJSObjectWithContext:ctx webglContext:self index:index]; \
		[buffers setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:index]]; \
		return obj; \
	}

	EJ_MAP(EJ_BIND_CREATE, Framebuffer, Renderbuffer, Buffer, Texture);

#undef EJ_BIND_CREATE


EJ_BIND_FUNCTION(createProgram, ctx, argc, argv) {
	GLuint program = glCreateProgram();
	
	JSObjectRef obj = [EJBindingWebGLProgram createJSObjectWithContext:ctx webglContext:self index:program];
	[programs setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:program]];
	return obj;
}

EJ_BIND_FUNCTION(createShader, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLenum type);

	GLuint shader = glCreateShader(type);
	
	JSObjectRef obj = [EJBindingWebGLShader createJSObjectWithContext:ctx webglContext:self index:shader];
	[shaders setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:shader]];
	return obj;
}

EJ_BIND_FUNCTION_DIRECT(cullFace, glCullFace, mode);


#define EJ_BIND_DELETE_OBJECT(I, NAME) \
	EJ_BIND_FUNCTION(delete##NAME, ctx, argc, argv) { \
		if( argc < 1 ) { return NULL; } \
		GLuint index = [EJBindingWebGL##NAME indexFromJSValue:argv[0]]; \
		[self delete##NAME:index]; \
		return NULL; \
	}

	EJ_MAP(EJ_BIND_DELETE_OBJECT, Buffer, Framebuffer, Renderbuffer, Shader, Texture, Program);

#undef EJ_BIND_DELETE_OBJECT


EJ_BIND_FUNCTION_DIRECT(depthFunc, glDepthFunc, func);
EJ_BIND_FUNCTION_DIRECT(depthMask, glDepthMask, flag);
EJ_BIND_FUNCTION_DIRECT(depthRange, glDepthRangef, zNear, zFar);

EJ_BIND_FUNCTION(detachShader, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLuint shader = [EJBindingWebGLProgram indexFromJSValue:argv[1]];
	glDetachShader(program, shader);
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(disable, glDisable, cap);
EJ_BIND_FUNCTION_DIRECT(disableVertexAttribArray, glDisableVertexAttribArray, index);
EJ_BIND_FUNCTION_DIRECT(drawArrays, glDrawArrays, mode, first, count);

EJ_BIND_FUNCTION(drawElements, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	EJ_UNPACK_ARGV(GLenum mode, GLsizei count, GLenum type);
	GLvoid *offset = (GLvoid *)((long)JSValueToNumberFast(ctx, argv[3]));
	
	glDrawElements(mode, count, type, offset);
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(enable, glEnable, cap);
EJ_BIND_FUNCTION_DIRECT(enableVertexAttribArray, glEnableVertexAttribArray, index);

EJ_BIND_FUNCTION(flush, ctx, argc, argv) {
	glFlush();
	return NULL;
}

EJ_BIND_FUNCTION(finish, ctx, argc, argv) {
	glFinish();
	return NULL;
}

EJ_BIND_FUNCTION(framebufferRenderbuffer, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	EJ_UNPACK_ARGV(GLenum target, GLenum attachment, GLenum renderbuffertarget);
	GLuint renderbuffer = [EJBindingWebGLRenderbuffer indexFromJSValue:argv[3]];
	
	glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
	return NULL;
}

EJ_BIND_FUNCTION(framebufferTexture2D, ctx, argc, argv) {
	if( argc < 5 ) { return NULL; }
	
	EJ_UNPACK_ARGV(GLenum target, GLenum attachment, GLenum textarget);
	GLuint texture = [EJBindingWebGLTexture indexFromJSValue:argv[3]];
	GLint level = JSValueToNumberFast(ctx, argv[4]);
	
	glFramebufferTexture2D(target, attachment, textarget, texture, level);
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(frontFace, glFrontFace, mode);
EJ_BIND_FUNCTION_DIRECT(generateMipmap, glGenerateMipmap, mode);

EJ_BIND_FUNCTION(getActiveAttrib, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	
	GLint buffsize;
	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &buffsize);
	
	GLchar * namebuffer = malloc(buffsize);
	GLsizei length;
	GLint size;
	GLenum type;
	glGetActiveAttrib(program, index, buffsize, &length, &size, &type, namebuffer);
	
	NSString * name = [NSString stringWithUTF8String:namebuffer];
	free(namebuffer);
	
	return [EJBindingWebGLActiveInfo createJSObjectWithContext:ctx size:size type:type name:name];
}

EJ_BIND_FUNCTION(getActiveUniform, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	
	GLint buffsize;
	glGetProgramiv(program, GL_ACTIVE_UNIFORM_MAX_LENGTH, &buffsize);
	
	GLchar * namebuffer = malloc(buffsize);
	GLsizei length;
	GLint size;
	GLenum type;
	glGetActiveUniform(program, index, buffsize, &length, &size, &type, namebuffer);
	
	NSString * name = [NSString stringWithUTF8String:namebuffer];
	free(namebuffer);
	
	return [EJBindingWebGLActiveInfo createJSObjectWithContext:ctx size:size type:type name:name];
}

EJ_BIND_FUNCTION(getAttachedShaders, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	
	GLint count;
	glGetProgramiv(program, GL_ATTACHED_SHADERS, &count);
	
	GLuint * list = malloc(count * sizeof(GLint));
	glGetAttachedShaders(program, count, NULL, list);
	
	JSValueRef * args = malloc(count * sizeof(JSObjectRef));
	for( int i = 0; i < count; i++ ) {
		args[i] = [[shaders objectForKey:[NSNumber numberWithInt:list[i]]] pointerValue];
	}
	JSObjectRef array = JSObjectMakeArray(ctx, count, args, NULL);
	free(args);
	free(list);
	
	return array;
}

EJ_BIND_FUNCTION(getAttribLocation, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	NSString * name = JSValueToNSString(ctx, argv[1]);

	return JSValueMakeNumber(ctx, glGetAttribLocation(program, [name UTF8String]));
}

EJ_BIND_FUNCTION(getFramebufferAttachmentParameter, ctx, argc, argv) {	
	EJ_UNPACK_ARGV(GLenum target, GLenum attachment, GLenum pname);
	
	GLint param;
	glGetFramebufferAttachmentParameteriv(target, attachment, pname, &param);
	
	if( pname == GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME ) {
		// Object names have to be wrapped in a WebGLObject, so figure out the type first
		GLint ptype;
		glGetFramebufferAttachmentParameteriv(target, attachment, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, &ptype);
		
		if( ptype == GL_RENDERBUFFER ) {
			return [[renderbuffers objectForKey:[NSNumber numberWithInt:param]] pointerValue];
		}
		else if( ptype == GL_TEXTURE ) {
			return [[textures objectForKey:[NSNumber numberWithInt:param]] pointerValue];
		}
	}
	
	return JSValueMakeNumber(ctx, param);
}

EJ_BIND_FUNCTION(getProgramParameter, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	
	GLint value;
	glGetProgramiv(program, pname, &value);
	return JSValueMakeNumber(ctx, value);
}

EJ_BIND_FUNCTION(getProgramInfoLog, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	
	// Get the info log size
	GLint size;
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &size);
	
	// Get the actual log message and return it
	GLchar * message = (GLchar *)malloc(size);
	glGetProgramInfoLog(program, size, &size, message);
	
	JSStringRef jss = JSStringCreateWithUTF8CString(message);
	JSValueRef ret = JSValueMakeString(ctx, jss);
	
	JSStringRelease(jss);
	free(message);
	
	return ret;
}

EJ_BIND_FUNCTION(getRenderbufferParameter, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLenum target, GLenum pname);
	
	GLint value;
	glGetRenderbufferParameteriv(target, pname, &value);
	return JSValueMakeNumber(ctx, value);
}

EJ_BIND_FUNCTION(getShaderParameter, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	
	GLint value;
	glGetShaderiv(shader, pname, &value);
	return JSValueMakeNumber(ctx, value);
}

EJ_BIND_FUNCTION(getShaderInfoLog, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];

	// Get the info log size
	GLint size;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &size);
	
	// Get the actual log message and return it
	GLchar * message = (GLchar *)malloc(size);
	glGetShaderInfoLog(shader, size, &size, message);
	
	JSStringRef jss = JSStringCreateWithUTF8CString(message);
	JSValueRef ret = JSValueMakeString(ctx, jss);

	JSStringRelease(jss);
	free(message);
	
	return ret;
}

EJ_BIND_FUNCTION(getShaderSource, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];
	// Get the info log size
	GLint size;
	glGetShaderiv(shader, GL_SHADER_SOURCE_LENGTH, &size);
	
	// Get the actual shader source and return it
	GLchar * source = (GLchar *)malloc(size);
	glGetShaderSource(shader, size, &size, source);
	
	JSStringRef jss = JSStringCreateWithUTF8CString(source);
	JSValueRef ret = JSValueMakeString(ctx, jss);

	JSStringRelease(jss);
	free(source);
	
	return ret;
}

EJ_BIND_FUNCTION(getTexParameter, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLenum target, GLenum pname);
	
	GLint value;
	glGetTexParameteriv(target, pname, &value);
	return JSValueMakeNumber(ctx, value);
}

EJ_BIND_FUNCTION(getUniform, ctx, argc, argv) {
	// TODO
	return NULL;
}

EJ_BIND_FUNCTION(getUniformLocation, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	NSString * name = JSValueToNSString(ctx, argv[1]);
	
	GLuint uniform = glGetUniformLocation(program, [name UTF8String]);
	return [EJBindingWebGLUniformLocation createJSObjectWithContext:ctx webglContext:self index:uniform];
}

EJ_BIND_FUNCTION(getVertexAttrib, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLuint index, GLenum pname);
	
	if( pname == GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING ) {
		GLint buffer;
		glGetVertexAttribiv(index, pname, &buffer);
		return [[buffers objectForKey:[NSNumber numberWithInt:buffer]] pointerValue];
	}
	else if( pname == GL_CURRENT_VERTEX_ATTRIB ) {
		JSObjectRef array = JSTypedArrayMake(ctx, kJSTypedArrayTypeFloat32Array, 4);
		GLint * values = JSTypedArrayGetDataPtr(ctx, array, NULL);
		glGetVertexAttribiv(index, pname, values);
		return array;
	}
	else {
		GLint value;
		glGetVertexAttribiv(index, pname, &value);
		return JSValueMakeNumber(ctx, value);
	}
}

EJ_BIND_FUNCTION(getVertexAttribOffset, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLuint index, GLenum pname);
	
	GLvoid * pointer;
	glGetVertexAttribPointerv(index, pname, &pointer);
	return JSValueMakeNumber(ctx, (int)pointer);
}

EJ_BIND_FUNCTION_DIRECT(hint, glHint, target, mode);


#define EJ_BIND_IS_OBJECT(I, NAME) \
	EJ_BIND_FUNCTION(is##NAME, ctx, argc, argv) { \
		if( argc < 1 ) { return NULL; } \
		GLuint index = [EJBindingWebGL##NAME indexFromJSValue:argv[0]]; \
		return JSValueMakeBoolean(ctx, glIs##NAME(index)); \
	} \

	EJ_MAP(EJ_BIND_IS_OBJECT, Buffer, Framebuffer, Program, Renderbuffer, Shader, Texture);

#undef EJ_BIND_IS_OBJECT


EJ_BIND_FUNCTION_DIRECT(isEnabled, glIsEnabled, cap);
EJ_BIND_FUNCTION_DIRECT(lineWidth, glLineWidth, width);

EJ_BIND_FUNCTION(linkProgram, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	glLinkProgram(program);
	return NULL;
}

EJ_BIND_FUNCTION(pixelStorei, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLenum pname, GLint param);
	
	if( pname == GL_UNPACK_FLIP_Y_WEBGL ) {
		unpackFlipY = param;
	}
	else if( pname == GL_UNPACK_PREMULTIPLY_ALPHA_WEBGL ) {
		premultiplyAlpha = param;
	}
	else {
		glPixelStorei(pname, param);
	}
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(polygonOffset, glPolygonOffset, factor, units);

EJ_BIND_FUNCTION(readPixels, ctx, argc, argv) {
	if( argc < 7 ) { return NULL; }
	EJ_UNPACK_ARGV(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type);
	
	size_t size;
	void * pixels = JSTypedArrayGetDataPtr(ctx, argv[6], &size);
	if( size >= width * height * 4 ) {
		glReadPixels(x, y, width, height, format, type, pixels);
	}
	
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(renderbufferStorage, glRenderbufferStorage, target, internalformat, width, height);
EJ_BIND_FUNCTION_DIRECT(sampleCoverage, glSampleCoverage, value, invert);
EJ_BIND_FUNCTION_DIRECT(scissor, glScissor, x, y, width, height);

EJ_BIND_FUNCTION(shaderSource, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];
	const GLchar * source = [JSValueToNSString(ctx, argv[1]) UTF8String];
	
	glShaderSource(shader, 1, &source, NULL);
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(stencilFunc, glStencilFunc, func, ref, mask);
EJ_BIND_FUNCTION_DIRECT(stencilFuncSeparate, glStencilFuncSeparate, face, func, ref, mask);
EJ_BIND_FUNCTION_DIRECT(stencilMask, glStencilMask, mask);
EJ_BIND_FUNCTION_DIRECT(stencilMaskSeparate, glStencilMaskSeparate, face, mask);
EJ_BIND_FUNCTION_DIRECT(stencilOp, glStencilOp, fail, zfail, zpass);
EJ_BIND_FUNCTION_DIRECT(stencilOpSeparate, glStencilOpSeparate, face, fail, zfail, zpass);

EJ_BIND_FUNCTION(texImage2D, ctx, argc, argv) {	
	// TODO
	return NULL;
}

EJ_BIND_FUNCTION_DIRECT(texParameteri, glTexParameteri, target, pname, param);
EJ_BIND_FUNCTION_DIRECT(texParameterf, glTexParameterf, target, pname, param);


#define EJ_BIND_UNIFORM(NAME, ... ) \
	EJ_BIND_FUNCTION(uniform##NAME, ctx, argc, argv) { \
		if( argc < EJ_ARGC(__VA_ARGS__)+1 ) { return NULL; } \
		GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]]; \
		glUniform##NAME( uniform, EJ_MAP_EXT(1, _EJ_COMMA, _EJ_BIND_FUNCTION_DIRECT_UNPACK, __VA_ARGS__) ); \
		return NULL; \
	}

	EJ_BIND_UNIFORM(1f, x);
	EJ_BIND_UNIFORM(2f, x, y);
	EJ_BIND_UNIFORM(3f, x, y, z);
	EJ_BIND_UNIFORM(4f, x, y, z, w);
	EJ_BIND_UNIFORM(1i, x);
	EJ_BIND_UNIFORM(2i, x, y);
	EJ_BIND_UNIFORM(3i, x, y, z);
	EJ_BIND_UNIFORM(4i, x, y, z, w);

#undef EJ_BIND_UNIFORM


#define EJ_BIND_UNIFORM_V(NAME, LENGTH, TYPE) \
	EJ_BIND_FUNCTION(uniform##NAME, ctx, argc, argv) { \
		if ( argc < 2 ) { return NULL; } \
		GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]]; \
		TYPE * values = JSValueTo##TYPE##Array(ctx, argv[1], LENGTH); \
		if( values ) { \
			glUniform##NAME(uniform, 1, values); \
		} \
		return NULL; \
	} \

	EJ_BIND_UNIFORM_V(1fv, 1, GLfloat);
	EJ_BIND_UNIFORM_V(2fv, 2, GLfloat);
	EJ_BIND_UNIFORM_V(3fv, 3, GLfloat);
	EJ_BIND_UNIFORM_V(4fv, 4, GLfloat);
	EJ_BIND_UNIFORM_V(1iv, 1, GLint);
	EJ_BIND_UNIFORM_V(2iv, 2, GLint);
	EJ_BIND_UNIFORM_V(3iv, 3, GLint);
	EJ_BIND_UNIFORM_V(4iv, 4, GLint);

#undef EJ_BIND_UNIFORM_V


#define EJ_BIND_UNIFORM_MATRIX_V(NAME, LENGTH, TYPE) \
	EJ_BIND_FUNCTION(uniformMatrix##NAME, ctx, argc, argv) { \
		if ( argc < 3 ) { return NULL; } \
		GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]]; \
		GLboolean transpose = JSValueToNumberFast(ctx, argv[1]); \
		TYPE * values = JSValueTo##TYPE##Array(ctx, argv[2], LENGTH); \
		if( values ) { \
			glUniformMatrix##NAME(uniform, 1, transpose, values); \
		} \
		return NULL; \
	} \

	EJ_BIND_UNIFORM_MATRIX_V(2fv, 4, GLfloat);
	EJ_BIND_UNIFORM_MATRIX_V(3fv, 9, GLfloat);
	EJ_BIND_UNIFORM_MATRIX_V(4fv, 16, GLfloat);

#undef EJ_BIND_UNIFORM_MATRIX_V


EJ_BIND_FUNCTION_DIRECT(vertexAttrib1f, glVertexAttrib1f, index, x);
EJ_BIND_FUNCTION_DIRECT(vertexAttrib2f, glVertexAttrib2f, index, x, y);
EJ_BIND_FUNCTION_DIRECT(vertexAttrib3f, glVertexAttrib3f, index, x, y, z);
EJ_BIND_FUNCTION_DIRECT(vertexAttrib4f, glVertexAttrib4f, index, x, y, z, w);

#define EJ_BIND_VERTEXATTRIB_V(NAME, LENGTH, TYPE) \
	EJ_BIND_FUNCTION(vertexAttrib##NAME, ctx, argc, argv) { \
		if ( argc < 2 ) { return NULL; } \
		GLuint index = JSValueToNumberFast(ctx, argv[0]); \
		TYPE * values = JSValueTo##TYPE##Array(ctx, argv[1], LENGTH); \
		if( values ) { \
			glVertexAttrib##NAME(index, values); \
		} \
		return NULL; \
	} \

	EJ_BIND_VERTEXATTRIB_V(1fv, 1, GLfloat);
	EJ_BIND_VERTEXATTRIB_V(2fv, 2, GLfloat);
	EJ_BIND_VERTEXATTRIB_V(3fv, 3, GLfloat);
	EJ_BIND_VERTEXATTRIB_V(4fv, 4, GLfloat);

#undef EJ_BIND_VERTEXATTRIB_V


EJ_BIND_FUNCTION(useProgram, ctx, argc, argv) {
	if ( argc < 1 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	
	glUseProgram(program);
	return NULL;
}

EJ_BIND_FUNCTION(validateProgram, ctx, argc, argv) {
	if ( argc < 1 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	
	glValidateProgram(program);
	return NULL;
}

EJ_BIND_FUNCTION(vertexAttribPointer, ctx, argc, argv) {
	if ( argc < 5 ) { return NULL; }
	EJ_UNPACK_ARGV(GLuint index, GLuint itemSize, GLenum type, GLboolean normalized, GLsizei stride);
	
	// TODO(viks): Is the following completly safe?
	GLvoid * offset = (GLvoid *)((long)JSValueToNumberFast(ctx, argv[5]));
	
	glVertexAttribPointer(index, itemSize, type, normalized, stride, offset);
	return NULL;
}

EJ_BIND_FUNCTION(viewport, ctx, argc, argv) {
	EJ_UNPACK_ARGV(GLint x, GLint y, GLsizei w, GLsizei h);
	
	float scale = renderingContext.backingStoreRatio;
	glViewport(x * scale, y * scale, w * scale, h * scale);
	return NULL;
}

#undef EJ_BIND_FUNCTION_DIRECT





// ------------------------------------------------------------------------------------
// Constants


#define EJ_BIND_CONST_GL(NAME) EJ_BIND_CONST(NAME, GL_##NAME)

// ClearBufferMask
EJ_BIND_CONST_GL(DEPTH_BUFFER_BIT);
EJ_BIND_CONST_GL(STENCIL_BUFFER_BIT);
EJ_BIND_CONST_GL(COLOR_BUFFER_BIT);

// Boolean
EJ_BIND_CONST_GL(FALSE);
EJ_BIND_CONST_GL(TRUE);

// BeginMode
EJ_BIND_CONST_GL(POINTS);
EJ_BIND_CONST_GL(LINES);
EJ_BIND_CONST_GL(LINE_LOOP);
EJ_BIND_CONST_GL(LINE_STRIP);
EJ_BIND_CONST_GL(TRIANGLES);
EJ_BIND_CONST_GL(TRIANGLE_STRIP);
EJ_BIND_CONST_GL(TRIANGLE_FAN);

// AlphaFunction (not supported in ES20);
// GL_NEVER
// GL_LESS
// GL_EQUAL
// GL_LEQUAL
// GL_GREATER
// GL_NOTEQUAL
// GL_GEQUAL
// GL_ALWAYS

// BlendingFactorDest
EJ_BIND_CONST_GL(ZERO);
EJ_BIND_CONST_GL(ONE);
EJ_BIND_CONST_GL(SRC_COLOR);
EJ_BIND_CONST_GL(ONE_MINUS_SRC_COLOR);
EJ_BIND_CONST_GL(SRC_ALPHA);
EJ_BIND_CONST_GL(ONE_MINUS_SRC_ALPHA);
EJ_BIND_CONST_GL(DST_ALPHA);
EJ_BIND_CONST_GL(ONE_MINUS_DST_ALPHA);

// BlendingFactorSrc
// GL_ZERO
// GL_ONE
EJ_BIND_CONST_GL(DST_COLOR);
EJ_BIND_CONST_GL(ONE_MINUS_DST_COLOR);
EJ_BIND_CONST_GL(SRC_ALPHA_SATURATE);
// GL_SRC_ALPHA

// GL_ONE_MINUS_SRC_ALPHA
// GL_DST_ALPHA
// GL_ONE_MINUS_DST_ALPHA

// BlendEquationSeparate
EJ_BIND_CONST_GL(FUNC_ADD);
EJ_BIND_CONST_GL(BLEND_EQUATION);
EJ_BIND_CONST_GL(BLEND_EQUATION_RGB);
EJ_BIND_CONST_GL(BLEND_EQUATION_ALPHA);

// BlendSubtract
EJ_BIND_CONST_GL(FUNC_SUBTRACT);
EJ_BIND_CONST_GL(FUNC_REVERSE_SUBTRACT);

// Separate Blend Functions
EJ_BIND_CONST_GL(BLEND_DST_RGB);
EJ_BIND_CONST_GL(BLEND_SRC_RGB);
EJ_BIND_CONST_GL(BLEND_DST_ALPHA);
EJ_BIND_CONST_GL(BLEND_SRC_ALPHA);
EJ_BIND_CONST_GL(CONSTANT_COLOR);
EJ_BIND_CONST_GL(ONE_MINUS_CONSTANT_COLOR);
EJ_BIND_CONST_GL(CONSTANT_ALPHA);
EJ_BIND_CONST_GL(ONE_MINUS_CONSTANT_ALPHA);
EJ_BIND_CONST_GL(BLEND_COLOR);

// Buffer Objects
EJ_BIND_CONST_GL(ARRAY_BUFFER);
EJ_BIND_CONST_GL(ELEMENT_ARRAY_BUFFER);
EJ_BIND_CONST_GL(ARRAY_BUFFER_BINDING);
EJ_BIND_CONST_GL(ELEMENT_ARRAY_BUFFER_BINDING);

EJ_BIND_CONST_GL(STREAM_DRAW);
EJ_BIND_CONST_GL(STATIC_DRAW);
EJ_BIND_CONST_GL(DYNAMIC_DRAW);

EJ_BIND_CONST_GL(BUFFER_SIZE);
EJ_BIND_CONST_GL(BUFFER_USAGE);

EJ_BIND_CONST_GL(CURRENT_VERTEX_ATTRIB);

// CullFaceMode
EJ_BIND_CONST_GL(FRONT);
EJ_BIND_CONST_GL(BACK);
EJ_BIND_CONST_GL(FRONT_AND_BACK);

// EnableCap
EJ_BIND_CONST_GL(TEXTURE_2D);
EJ_BIND_CONST_GL(CULL_FACE);
EJ_BIND_CONST_GL(BLEND);
EJ_BIND_CONST_GL(DITHER);
EJ_BIND_CONST_GL(STENCIL_TEST);
EJ_BIND_CONST_GL(DEPTH_TEST);
EJ_BIND_CONST_GL(SCISSOR_TEST);
EJ_BIND_CONST_GL(POLYGON_OFFSET_FILL);
EJ_BIND_CONST_GL(SAMPLE_ALPHA_TO_COVERAGE);
EJ_BIND_CONST_GL(SAMPLE_COVERAGE);

// ErrorCode
EJ_BIND_CONST_GL(NO_ERROR);
EJ_BIND_CONST_GL(INVALID_ENUM);
EJ_BIND_CONST_GL(INVALID_VALUE);
EJ_BIND_CONST_GL(INVALID_OPERATION);
EJ_BIND_CONST_GL(OUT_OF_MEMORY);

// FrontFaceDirection
EJ_BIND_CONST_GL(CW);
EJ_BIND_CONST_GL(CCW);

// GetPName
EJ_BIND_CONST_GL(LINE_WIDTH);
EJ_BIND_CONST_GL(ALIASED_POINT_SIZE_RANGE);
EJ_BIND_CONST_GL(ALIASED_LINE_WIDTH_RANGE);
EJ_BIND_CONST_GL(CULL_FACE_MODE);
EJ_BIND_CONST_GL(FRONT_FACE);
EJ_BIND_CONST_GL(DEPTH_RANGE);
EJ_BIND_CONST_GL(DEPTH_WRITEMASK);
EJ_BIND_CONST_GL(DEPTH_CLEAR_VALUE);
EJ_BIND_CONST_GL(DEPTH_FUNC);
EJ_BIND_CONST_GL(STENCIL_CLEAR_VALUE);
EJ_BIND_CONST_GL(STENCIL_FUNC);
EJ_BIND_CONST_GL(STENCIL_FAIL);
EJ_BIND_CONST_GL(STENCIL_PASS_DEPTH_FAIL);
EJ_BIND_CONST_GL(STENCIL_PASS_DEPTH_PASS);
EJ_BIND_CONST_GL(STENCIL_REF);
EJ_BIND_CONST_GL(STENCIL_VALUE_MASK);
EJ_BIND_CONST_GL(STENCIL_WRITEMASK);
EJ_BIND_CONST_GL(STENCIL_BACK_FUNC);
EJ_BIND_CONST_GL(STENCIL_BACK_FAIL);
EJ_BIND_CONST_GL(STENCIL_BACK_PASS_DEPTH_FAIL);
EJ_BIND_CONST_GL(STENCIL_BACK_PASS_DEPTH_PASS);
EJ_BIND_CONST_GL(STENCIL_BACK_REF);
EJ_BIND_CONST_GL(STENCIL_BACK_VALUE_MASK);
EJ_BIND_CONST_GL(STENCIL_BACK_WRITEMASK);
EJ_BIND_CONST_GL(VIEWPORT);
EJ_BIND_CONST_GL(SCISSOR_BOX);
// GL_SCISSOR_TEST
EJ_BIND_CONST_GL(COLOR_CLEAR_VALUE);
EJ_BIND_CONST_GL(COLOR_WRITEMASK);
EJ_BIND_CONST_GL(UNPACK_ALIGNMENT);
EJ_BIND_CONST_GL(PACK_ALIGNMENT);
EJ_BIND_CONST_GL(MAX_TEXTURE_SIZE);
EJ_BIND_CONST_GL(MAX_VIEWPORT_DIMS);
EJ_BIND_CONST_GL(SUBPIXEL_BITS);
EJ_BIND_CONST_GL(RED_BITS);
EJ_BIND_CONST_GL(GREEN_BITS);
EJ_BIND_CONST_GL(BLUE_BITS);
EJ_BIND_CONST_GL(ALPHA_BITS);
EJ_BIND_CONST_GL(DEPTH_BITS);
EJ_BIND_CONST_GL(STENCIL_BITS);
EJ_BIND_CONST_GL(POLYGON_OFFSET_UNITS);
// GL_POLYGON_OFFSET_FILL
EJ_BIND_CONST_GL(POLYGON_OFFSET_FACTOR);
EJ_BIND_CONST_GL(TEXTURE_BINDING_2D);
EJ_BIND_CONST_GL(SAMPLE_BUFFERS);
EJ_BIND_CONST_GL(SAMPLES);
EJ_BIND_CONST_GL(SAMPLE_COVERAGE_VALUE);
EJ_BIND_CONST_GL(SAMPLE_COVERAGE_INVERT);

// GetTextureParameter
// GL_TEXTURE_MAG_FILTER
// GL_TEXTURE_MIN_FILTER
// GL_TEXTURE_WRAP_S
// GL_TEXTURE_WRAP_T

EJ_BIND_CONST_GL(NUM_COMPRESSED_TEXTURE_FORMATS);
EJ_BIND_CONST_GL(COMPRESSED_TEXTURE_FORMATS);

// HintMode
EJ_BIND_CONST_GL(DONT_CARE);
EJ_BIND_CONST_GL(FASTEST);
EJ_BIND_CONST_GL(NICEST);

// HintTarget
EJ_BIND_CONST_GL(GENERATE_MIPMAP_HINT);

// DataType
EJ_BIND_CONST_GL(BYTE);
EJ_BIND_CONST_GL(UNSIGNED_BYTE);
EJ_BIND_CONST_GL(SHORT);
EJ_BIND_CONST_GL(UNSIGNED_SHORT);
EJ_BIND_CONST_GL(INT);
EJ_BIND_CONST_GL(UNSIGNED_INT);
EJ_BIND_CONST_GL(FLOAT);
EJ_BIND_CONST_GL(FIXED);

// PixelFormat
EJ_BIND_CONST_GL(DEPTH_COMPONENT);
EJ_BIND_CONST_GL(ALPHA);
EJ_BIND_CONST_GL(RGB);
EJ_BIND_CONST_GL(RGBA);
EJ_BIND_CONST_GL(LUMINANCE);
EJ_BIND_CONST_GL(LUMINANCE_ALPHA);

// PixelType
// GL_UNSIGNED_BYTE
EJ_BIND_CONST_GL(UNSIGNED_SHORT_4_4_4_4);
EJ_BIND_CONST_GL(UNSIGNED_SHORT_5_5_5_1);
EJ_BIND_CONST_GL(UNSIGNED_SHORT_5_6_5);

// Shaders
EJ_BIND_CONST_GL(FRAGMENT_SHADER);
EJ_BIND_CONST_GL(VERTEX_SHADER);
EJ_BIND_CONST_GL(MAX_VERTEX_ATTRIBS);
EJ_BIND_CONST_GL(MAX_VERTEX_UNIFORM_VECTORS);
EJ_BIND_CONST_GL(MAX_VARYING_VECTORS);
EJ_BIND_CONST_GL(MAX_COMBINED_TEXTURE_IMAGE_UNITS);
EJ_BIND_CONST_GL(MAX_VERTEX_TEXTURE_IMAGE_UNITS);
EJ_BIND_CONST_GL(MAX_TEXTURE_IMAGE_UNITS);
EJ_BIND_CONST_GL(MAX_FRAGMENT_UNIFORM_VECTORS);
EJ_BIND_CONST_GL(SHADER_TYPE);
EJ_BIND_CONST_GL(DELETE_STATUS);
EJ_BIND_CONST_GL(LINK_STATUS);
EJ_BIND_CONST_GL(VALIDATE_STATUS);
EJ_BIND_CONST_GL(ATTACHED_SHADERS);
EJ_BIND_CONST_GL(ACTIVE_UNIFORMS);
EJ_BIND_CONST_GL(ACTIVE_UNIFORM_MAX_LENGTH);
EJ_BIND_CONST_GL(ACTIVE_ATTRIBUTES);
EJ_BIND_CONST_GL(ACTIVE_ATTRIBUTE_MAX_LENGTH);
EJ_BIND_CONST_GL(SHADING_LANGUAGE_VERSION);
EJ_BIND_CONST_GL(CURRENT_PROGRAM);

// StencilFunction
EJ_BIND_CONST_GL(NEVER);
EJ_BIND_CONST_GL(LESS);
EJ_BIND_CONST_GL(EQUAL);
EJ_BIND_CONST_GL(LEQUAL);
EJ_BIND_CONST_GL(GREATER);
EJ_BIND_CONST_GL(NOTEQUAL);
EJ_BIND_CONST_GL(GEQUAL);
EJ_BIND_CONST_GL(ALWAYS);

// StencilOp
// GL_ZERO
EJ_BIND_CONST_GL(KEEP);
EJ_BIND_CONST_GL(REPLACE);
EJ_BIND_CONST_GL(INCR);
EJ_BIND_CONST_GL(DECR);
EJ_BIND_CONST_GL(INVERT);
EJ_BIND_CONST_GL(INCR_WRAP);
EJ_BIND_CONST_GL(DECR_WRAP);

// StringName
EJ_BIND_CONST_GL(VENDOR);
EJ_BIND_CONST_GL(RENDERER);
EJ_BIND_CONST_GL(VERSION);
EJ_BIND_CONST_GL(EXTENSIONS);

// TextureMagFilter
EJ_BIND_CONST_GL(NEAREST);
EJ_BIND_CONST_GL(LINEAR);

// TextureMinFilter
// GL_NEAREST
// GL_LINEAR
EJ_BIND_CONST_GL(NEAREST_MIPMAP_NEAREST);
EJ_BIND_CONST_GL(LINEAR_MIPMAP_NEAREST);
EJ_BIND_CONST_GL(NEAREST_MIPMAP_LINEAR);
EJ_BIND_CONST_GL(LINEAR_MIPMAP_LINEAR);

// TextureParameterName
EJ_BIND_CONST_GL(TEXTURE_MAG_FILTER);
EJ_BIND_CONST_GL(TEXTURE_MIN_FILTER);
EJ_BIND_CONST_GL(TEXTURE_WRAP_S);
EJ_BIND_CONST_GL(TEXTURE_WRAP_T);

// TextureTarget
// GL_TEXTURE_2D
EJ_BIND_CONST_GL(TEXTURE);

EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP);
EJ_BIND_CONST_GL(TEXTURE_BINDING_CUBE_MAP);
EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP_POSITIVE_X);
EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP_NEGATIVE_X);
EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP_POSITIVE_Y);
EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP_NEGATIVE_Y);
EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP_POSITIVE_Z);
EJ_BIND_CONST_GL(TEXTURE_CUBE_MAP_NEGATIVE_Z);
EJ_BIND_CONST_GL(MAX_CUBE_MAP_TEXTURE_SIZE);

// TextureUnit
EJ_BIND_CONST_GL(TEXTURE0);
EJ_BIND_CONST_GL(TEXTURE1);
EJ_BIND_CONST_GL(TEXTURE2);
EJ_BIND_CONST_GL(TEXTURE3);
EJ_BIND_CONST_GL(TEXTURE4);
EJ_BIND_CONST_GL(TEXTURE5);
EJ_BIND_CONST_GL(TEXTURE6);
EJ_BIND_CONST_GL(TEXTURE7);
EJ_BIND_CONST_GL(TEXTURE8);
EJ_BIND_CONST_GL(TEXTURE9);
EJ_BIND_CONST_GL(TEXTURE10);
EJ_BIND_CONST_GL(TEXTURE11);
EJ_BIND_CONST_GL(TEXTURE12);
EJ_BIND_CONST_GL(TEXTURE13);
EJ_BIND_CONST_GL(TEXTURE14);
EJ_BIND_CONST_GL(TEXTURE15);
EJ_BIND_CONST_GL(TEXTURE16);
EJ_BIND_CONST_GL(TEXTURE17);
EJ_BIND_CONST_GL(TEXTURE18);
EJ_BIND_CONST_GL(TEXTURE19);
EJ_BIND_CONST_GL(TEXTURE20);
EJ_BIND_CONST_GL(TEXTURE21);
EJ_BIND_CONST_GL(TEXTURE22);
EJ_BIND_CONST_GL(TEXTURE23);
EJ_BIND_CONST_GL(TEXTURE24);
EJ_BIND_CONST_GL(TEXTURE25);
EJ_BIND_CONST_GL(TEXTURE26);
EJ_BIND_CONST_GL(TEXTURE27);
EJ_BIND_CONST_GL(TEXTURE28);
EJ_BIND_CONST_GL(TEXTURE29);
EJ_BIND_CONST_GL(TEXTURE30);
EJ_BIND_CONST_GL(TEXTURE31);
EJ_BIND_CONST_GL(ACTIVE_TEXTURE);

// TextureWrapMode
EJ_BIND_CONST_GL(REPEAT);
EJ_BIND_CONST_GL(CLAMP_TO_EDGE);
EJ_BIND_CONST_GL(MIRRORED_REPEAT);

// Uniform Types
EJ_BIND_CONST_GL(FLOAT_VEC2);
EJ_BIND_CONST_GL(FLOAT_VEC3);
EJ_BIND_CONST_GL(FLOAT_VEC4);
EJ_BIND_CONST_GL(INT_VEC2);
EJ_BIND_CONST_GL(INT_VEC3);
EJ_BIND_CONST_GL(INT_VEC4);
EJ_BIND_CONST_GL(BOOL);
EJ_BIND_CONST_GL(BOOL_VEC2);
EJ_BIND_CONST_GL(BOOL_VEC3);
EJ_BIND_CONST_GL(BOOL_VEC4);
EJ_BIND_CONST_GL(FLOAT_MAT2);
EJ_BIND_CONST_GL(FLOAT_MAT3);
EJ_BIND_CONST_GL(FLOAT_MAT4);
EJ_BIND_CONST_GL(SAMPLER_2D);
EJ_BIND_CONST_GL(SAMPLER_CUBE);

// Vertex Arrays
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_ENABLED);
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_SIZE);
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_STRIDE);
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_TYPE);
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_NORMALIZED);
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_POINTER);
EJ_BIND_CONST_GL(VERTEX_ATTRIB_ARRAY_BUFFER_BINDING);

// Read Format
EJ_BIND_CONST_GL(IMPLEMENTATION_COLOR_READ_TYPE);
EJ_BIND_CONST_GL(IMPLEMENTATION_COLOR_READ_FORMAT);

// Shader Source
EJ_BIND_CONST_GL(COMPILE_STATUS);
EJ_BIND_CONST_GL(INFO_LOG_LENGTH);
EJ_BIND_CONST_GL(SHADER_SOURCE_LENGTH);
EJ_BIND_CONST_GL(SHADER_COMPILER);

// Shader Binary
EJ_BIND_CONST_GL(SHADER_BINARY_FORMATS);
EJ_BIND_CONST_GL(NUM_SHADER_BINARY_FORMATS);

// Shader Precision-Specified Types
EJ_BIND_CONST_GL(LOW_FLOAT);
EJ_BIND_CONST_GL(MEDIUM_FLOAT);
EJ_BIND_CONST_GL(HIGH_FLOAT);
EJ_BIND_CONST_GL(LOW_INT);
EJ_BIND_CONST_GL(MEDIUM_INT);
EJ_BIND_CONST_GL(HIGH_INT);

// Framebuffer Object.
EJ_BIND_CONST_GL(FRAMEBUFFER);
EJ_BIND_CONST_GL(RENDERBUFFER);

EJ_BIND_CONST_GL(RGBA4);
EJ_BIND_CONST_GL(RGB5_A1);
EJ_BIND_CONST_GL(RGB565);
EJ_BIND_CONST_GL(DEPTH_COMPONENT16);
EJ_BIND_CONST_GL(STENCIL_INDEX);
EJ_BIND_CONST_GL(STENCIL_INDEX8);

EJ_BIND_CONST_GL(RENDERBUFFER_WIDTH);
EJ_BIND_CONST_GL(RENDERBUFFER_HEIGHT);
EJ_BIND_CONST_GL(RENDERBUFFER_INTERNAL_FORMAT);
EJ_BIND_CONST_GL(RENDERBUFFER_RED_SIZE);
EJ_BIND_CONST_GL(RENDERBUFFER_GREEN_SIZE);
EJ_BIND_CONST_GL(RENDERBUFFER_BLUE_SIZE);
EJ_BIND_CONST_GL(RENDERBUFFER_ALPHA_SIZE);
EJ_BIND_CONST_GL(RENDERBUFFER_DEPTH_SIZE);
EJ_BIND_CONST_GL(RENDERBUFFER_STENCIL_SIZE);

EJ_BIND_CONST_GL(FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE);
EJ_BIND_CONST_GL(FRAMEBUFFER_ATTACHMENT_OBJECT_NAME);
EJ_BIND_CONST_GL(FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL);
EJ_BIND_CONST_GL(FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE);

EJ_BIND_CONST_GL(COLOR_ATTACHMENT0);
EJ_BIND_CONST_GL(DEPTH_ATTACHMENT);
EJ_BIND_CONST_GL(STENCIL_ATTACHMENT);

EJ_BIND_CONST_GL(NONE);

EJ_BIND_CONST_GL(FRAMEBUFFER_COMPLETE);
EJ_BIND_CONST_GL(FRAMEBUFFER_INCOMPLETE_ATTACHMENT);
EJ_BIND_CONST_GL(FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT);
EJ_BIND_CONST_GL(FRAMEBUFFER_INCOMPLETE_DIMENSIONS);
EJ_BIND_CONST_GL(FRAMEBUFFER_UNSUPPORTED);

EJ_BIND_CONST_GL(FRAMEBUFFER_BINDING);
EJ_BIND_CONST_GL(RENDERBUFFER_BINDING);
EJ_BIND_CONST_GL(MAX_RENDERBUFFER_SIZE);

EJ_BIND_CONST_GL(INVALID_FRAMEBUFFER_OPERATION);

// WebGL-specific enums
EJ_BIND_CONST_GL(UNPACK_FLIP_Y_WEBGL);
EJ_BIND_CONST_GL(UNPACK_PREMULTIPLY_ALPHA_WEBGL);
EJ_BIND_CONST_GL(CONTEXT_LOST_WEBGL);
EJ_BIND_CONST_GL(UNPACK_COLORSPACE_CONVERSION_WEBGL);
EJ_BIND_CONST_GL(BROWSER_DEFAULT_WEBGL);

#undef EJ_BIND_CONST_GL

@end
