#import "EJBindingCanvasContextWebGL.h"
#import "EJBindingWebGLObjects.h"
#import "EJDrawable.h"
#import "EJTexture.h"

#import <JavaScriptCore/JSTypedArray.h>


static union {
	GLfloat asFloat[16];
	GLint asInt[16];
} JSValueToArrayBuffer;

GLfloat * JSValueToGLfloatArray(JSContextRef ctx, JSValueRef value, size_t expectedSize) {
	if( JSTypedArrayGetType(ctx, value) == kJSTypedArrayTypeFloat32Array ) {
		size_t byteLength;
		GLfloat * arrayValue = JSTypedArrayGetDataPtr(ctx, value, &byteLength);			
		if( arrayValue && (byteLength/sizeof(GLfloat)) >= expectedSize ) {
			return arrayValue;
		}
	}
	else if( JSValueIsObject(ctx, value) ) {
		JSObjectRef jsArray = (JSObjectRef)value;
		for (int i = 0; i < expectedSize; i++) {
			JSValueToArrayBuffer.asFloat[i] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
		}
		return JSValueToArrayBuffer.asFloat;
	}
	
	return NULL;
}

GLint * JSValueToGLintArray(JSContextRef ctx, JSValueRef value, size_t expectedSize) {
	if( JSTypedArrayGetType(ctx, value) == kJSTypedArrayTypeInt32Array ) {
		size_t byteLength;
		GLint * arrayValue = JSTypedArrayGetDataPtr(ctx, value, &byteLength);
		if( arrayValue && (byteLength/sizeof(GLint)) >= expectedSize ) {
			return arrayValue;
		}
	}
	else if( JSValueIsObject(ctx, value) ) {
		JSObjectRef jsArray = (JSObjectRef)value;
		for (int i = 0; i < expectedSize; i++) {
			JSValueToArrayBuffer.asInt[i] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
		}
		return JSValueToArrayBuffer.asInt;
	}
	
	return NULL;
}


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

EJ_BIND_FUNCTION(bindFramebuffer, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLuint framebuffer = [EJBindingWebGLFramebuffer indexFromJSValue:argv[1]];
	glBindFramebuffer(target, framebuffer);
	return NULL;
}

EJ_BIND_FUNCTION(bindRenderbuffer, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLuint renderbuffer = [EJBindingWebGLRenderbuffer indexFromJSValue:argv[1]];
	glBindRenderbuffer(target, renderbuffer);
	return NULL;
}

EJ_BIND_FUNCTION(bindBuffer, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLuint buffer = [EJBindingWebGLBuffer indexFromJSValue:argv[1]];
	glBindBuffer(target, buffer);
	return NULL;
}

EJ_BIND_FUNCTION(bindTexture, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLuint texture = [EJBindingWebGLTexture indexFromJSValue:argv[1]];
	glBindTexture(target, texture);
	return NULL;
}

EJ_BIND_FUNCTION(blendColor, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLclampf
		red = JSValueToNumberFast(ctx, argv[0]),
		green = JSValueToNumberFast(ctx, argv[1]),
		blue = JSValueToNumberFast(ctx, argv[2]),
		alpha = JSValueToNumberFast(ctx, argv[3]);
		
	glBlendColor(red, green, blue, alpha);
	return NULL;
}

EJ_BIND_FUNCTION(blendEquation, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum mode = JSValueToNumberFast(ctx, argv[0]);
	glBlendEquation(mode);
	return NULL;
}

EJ_BIND_FUNCTION(blendEquationSeparate, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum modeRGB = JSValueToNumberFast(ctx, argv[0]);
	GLenum modeAlpha = JSValueToNumberFast(ctx, argv[0]);
	glBlendEquationSeparate(modeRGB, modeAlpha);
	return NULL;
}

EJ_BIND_FUNCTION(blendFunc, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum sfactor = JSValueToNumberFast(ctx, argv[0]);
	GLenum dfactor = JSValueToNumberFast(ctx, argv[1]);
	glBlendFunc(sfactor, dfactor);
	return NULL;
}

EJ_BIND_FUNCTION(blendFuncSeparate, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum srcRGB = JSValueToNumberFast(ctx, argv[0]);
	GLenum dstRGB = JSValueToNumberFast(ctx, argv[1]);
	GLenum srcAlpha = JSValueToNumberFast(ctx, argv[0]);
	GLenum dstAlpha = JSValueToNumberFast(ctx, argv[1]);
	
	glBlendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
	return NULL;
}

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

EJ_BIND_FUNCTION(clear, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }

	GLbitfield mask = JSValueToNumberFast(ctx, argv[0]);
	glClear(mask);
	return NULL;
}

EJ_BIND_FUNCTION(clearColor, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLclampf
		red = JSValueToNumberFast(ctx, argv[0]),
		green = JSValueToNumberFast(ctx, argv[1]),
		blue = JSValueToNumberFast(ctx, argv[2]),
		alpha = JSValueToNumberFast(ctx, argv[3]);
	
	glClearColor(red, green, blue, alpha);
	return NULL;
}

EJ_BIND_FUNCTION(clearDepth, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }

	GLclampf depth = JSValueToNumberFast(ctx, argv[0]);
	glClearDepthf(depth);
	return NULL;
}

EJ_BIND_FUNCTION(clearStencil, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }

	GLint s = JSValueToNumberFast(ctx, argv[0]);
	glClearStencil(s);
	return NULL;
}

EJ_BIND_FUNCTION(colorMask, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLboolean
		red = JSValueToNumberFast(ctx, argv[0]),
		green = JSValueToNumberFast(ctx, argv[1]),
		blue = JSValueToNumberFast(ctx, argv[2]),
		alpha = JSValueToNumberFast(ctx, argv[3]);
	
	glColorMask(red, green, blue, alpha);
	return NULL;
}

EJ_BIND_FUNCTION(compileShader, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];
	glCompileShader(shader);
	return NULL;
}

EJ_BIND_FUNCTION(copyTexImage2D, ctx, argc, argv) {
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLint level = JSValueToNumberFast(ctx, argv[1]);
	GLenum internalformat = JSValueToNumberFast(ctx, argv[2]);
	GLint x = JSValueToNumberFast(ctx, argv[3]);
	GLint y = JSValueToNumberFast(ctx, argv[4]);
	GLsizei width = JSValueToNumberFast(ctx, argv[5]);
	GLsizei height = JSValueToNumberFast(ctx, argv[6]);
	GLint border = JSValueToNumberFast(ctx, argv[7]);
	
	glCopyTexImage2D(target, level, internalformat, x, y, width, height, border);
	return NULL;
}

EJ_BIND_FUNCTION(copyTexSubImage2D, ctx, argc, argv) {
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLint level = JSValueToNumberFast(ctx, argv[1]);
	GLint xoffset = JSValueToNumberFast(ctx, argv[2]);
	GLint yoffset = JSValueToNumberFast(ctx, argv[3]);
	GLint x = JSValueToNumberFast(ctx, argv[4]);
	GLint y = JSValueToNumberFast(ctx, argv[5]);
	GLsizei width = JSValueToNumberFast(ctx, argv[6]);
	GLsizei height = JSValueToNumberFast(ctx, argv[7]);
	
	glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
	return NULL;
}

EJ_BIND_FUNCTION(createBuffer, ctx, argc, argv) {
	GLuint buffer;
	glGenBuffers(1, &buffer);
	
	JSObjectRef obj = [EJBindingWebGLBuffer createJSObjectWithContext:ctx webglContext:self index:buffer];
	[buffers setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:buffer]];
	return obj;
}

EJ_BIND_FUNCTION(createFramebuffer, ctx, argc, argv) {
	GLuint framebuffer;
	glGenFramebuffers(1, &framebuffer);
	
	JSObjectRef obj = [EJBindingWebGLFramebuffer createJSObjectWithContext:ctx webglContext:self index:framebuffer];
	[framebuffers setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:framebuffer]];
	return obj;
}

EJ_BIND_FUNCTION(createProgram, ctx, argc, argv) {
	GLuint program = glCreateProgram();
	
	JSObjectRef obj = [EJBindingWebGLProgram createJSObjectWithContext:ctx webglContext:self index:program];
	[programs setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:program]];
	return obj;
}

EJ_BIND_FUNCTION(createRenderbuffer, ctx, argc, argv) {
	GLuint renderbuffer;
	glGenFramebuffers(1, &renderbuffer);
	
	JSObjectRef obj = [EJBindingWebGLRenderbuffer createJSObjectWithContext:ctx webglContext:self index:renderbuffer];
	[renderbuffers setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:renderbuffer]];
	return obj;
}

EJ_BIND_FUNCTION(createShader, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum type =  JSValueToNumberFast(ctx, argv[0]);
	GLuint shader = glCreateShader(type);
	
	JSObjectRef obj = [EJBindingWebGLShader createJSObjectWithContext:ctx webglContext:self index:shader];
	[shaders setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:shader]];
	return obj;
}

EJ_BIND_FUNCTION(createTexture, ctx, argc, argv) {
	GLuint texture;
	glGenTextures(1, &texture);
	
	JSObjectRef obj = [EJBindingWebGLTexture createJSObjectWithContext:ctx webglContext:self index:texture];
	[textures setObject:[NSValue valueWithPointer:obj] forKey:[NSNumber numberWithInt:texture]];
	return obj;
}

EJ_BIND_FUNCTION(cullFace, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum mode = JSValueToNumberFast(ctx, argv[0]);
	glCullFace(mode);
	return NULL;
}

#define EJ_BIND_DELETE_OBJECT(NAME) \
	EJ_BIND_FUNCTION(delete##NAME, ctx, argc, argv) { \
		if( argc < 1 ) { return NULL; } \
		GLuint index = [EJBindingWebGL##NAME indexFromJSValue:argv[0]]; \
		[self delete##NAME:index]; \
		return NULL; \
	}

EJ_BIND_DELETE_OBJECT(Buffer);
EJ_BIND_DELETE_OBJECT(Framebuffer);
EJ_BIND_DELETE_OBJECT(Renderbuffer);
EJ_BIND_DELETE_OBJECT(Shader);
EJ_BIND_DELETE_OBJECT(Texture);
EJ_BIND_DELETE_OBJECT(Program);

#undef EJ_BIND_DELETE_OBJECT


EJ_BIND_FUNCTION(depthFunc, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum func = JSValueToNumberFast(ctx, argv[0]);
	glDepthFunc(func);
	return NULL;
}

EJ_BIND_FUNCTION(depthMask, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLboolean flag = JSValueToNumberFast(ctx, argv[0]);
	glDepthMask(flag);
	return NULL;
}

EJ_BIND_FUNCTION(depthRange, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLclampf zNear = JSValueToNumberFast(ctx, argv[0]);
	GLclampf zFar = JSValueToNumberFast(ctx, argv[1]);
	glDepthRangef(zNear, zFar);
	return NULL;
}

EJ_BIND_FUNCTION(detachShader, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	GLuint shader = [EJBindingWebGLProgram indexFromJSValue:argv[1]];
	glDetachShader(program, shader);
	return NULL;
}

EJ_BIND_FUNCTION(disable, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum cap = JSValueToNumberFast(ctx, argv[0]);
	glDisable(cap);
	return NULL;
}

EJ_BIND_FUNCTION(disableVertexAttribArray, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	glDisableVertexAttribArray(index);
	return NULL;
}

EJ_BIND_FUNCTION(drawArrays, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	GLenum mode = JSValueToNumberFast(ctx, argv[0]);
	GLenum first = JSValueToNumberFast(ctx, argv[1]);
	GLsizei count = JSValueToNumberFast(ctx, argv[2]);

	glDrawArrays(mode, first, count);
	return NULL;
}

EJ_BIND_FUNCTION(drawElements, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLenum mode = JSValueToNumberFast(ctx, argv[0]);
	GLsizei count = JSValueToNumberFast(ctx, argv[1]);
	GLenum type = JSValueToNumberFast(ctx, argv[2]);
	GLvoid *offset = (GLvoid *)((long)JSValueToNumberFast(ctx, argv[3]));
	
	glDrawElements(mode, count, type, offset);
	return NULL;
}

EJ_BIND_FUNCTION(enable, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum cap = JSValueToNumberFast(ctx, argv[0]);
	glEnable(cap);
	return NULL;
}

EJ_BIND_FUNCTION(enableVertexAttribArray, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	glEnableVertexAttribArray(index);
	return NULL;
}

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
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum attachment = JSValueToNumberFast(ctx, argv[1]);
	GLenum renderbuffertarget = JSValueToNumberFast(ctx, argv[2]);
	GLuint renderbuffer = [EJBindingWebGLRenderbuffer indexFromJSValue:argv[3]];
	
	glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
	return NULL;
}

EJ_BIND_FUNCTION(framebufferTexture2D, ctx, argc, argv) {
	if( argc < 5 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum attachment = JSValueToNumberFast(ctx, argv[1]);
	GLenum textarget = JSValueToNumberFast(ctx, argv[2]);
	GLuint texture = [EJBindingWebGLTexture indexFromJSValue:argv[3]];
	GLint level = JSValueToNumberFast(ctx, argv[4]);
	
	glFramebufferTexture2D(target, attachment, textarget, texture, level);
	return NULL;
}

EJ_BIND_FUNCTION(frontFace, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum mode = JSValueToNumberFast(ctx, argv[0]);
	glFrontFace(mode);
	return NULL;
}

EJ_BIND_FUNCTION(generateMipmap, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	glGenerateMipmap(target);
	return NULL;
}

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
	if( argc < 3 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum attachment = JSValueToNumberFast(ctx, argv[1]);
	GLenum pname = JSValueToNumberFast(ctx, argv[2]);
	
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
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	
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
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum pname = JSValueToNumberFast(ctx, argv[0]);
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
	if( argc < 2 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	
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
	if( argc < 2 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	
	//EJ_UNPACK_ARGV(GLuint index, GLenum pname);
	
	GLvoid * pointer;
	glGetVertexAttribPointerv(index, pname, &pointer);
	return JSValueMakeNumber(ctx, (int)pointer);
}

EJ_BIND_FUNCTION(hint, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum mode = JSValueToNumberFast(ctx, argv[1]);
	glHint(target, mode);
	return NULL;
}

#define EJ_BIND_IS_OBJECT(NAME) \
	EJ_BIND_FUNCTION(is##NAME, ctx, argc, argv) { \
		if( argc < 1 ) { return NULL; } \
		GLuint index = [EJBindingWebGL##NAME indexFromJSValue:argv[0]]; \
		return JSValueMakeBoolean(ctx, glIs##NAME(index)); \
	} \

EJ_BIND_IS_OBJECT(Buffer);
EJ_BIND_IS_OBJECT(Framebuffer);
EJ_BIND_IS_OBJECT(Program);
EJ_BIND_IS_OBJECT(Renderbuffer);
EJ_BIND_IS_OBJECT(Shader);
EJ_BIND_IS_OBJECT(Texture);

#undef EJ_BIND_IS_OBJECT

EJ_BIND_FUNCTION(isEnabled, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLenum cap = JSValueToNumberFast(ctx, argv[0]);
	return JSValueMakeBoolean(ctx, glIsEnabled(cap));
}

EJ_BIND_FUNCTION(lineWidth, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLfloat width = JSValueToNumberFast(ctx, argv[0]);
	glLineWidth(width);
	return NULL;
}

EJ_BIND_FUNCTION(linkProgram, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint program = [EJBindingWebGLProgram indexFromJSValue:argv[0]];
	glLinkProgram(program);
	return NULL;
}

EJ_BIND_FUNCTION(pixelStorei, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum pname = JSValueToNumberFast(ctx, argv[0]);
	GLint param = JSValueToNumberFast(ctx, argv[1]);
	
	if( pname == EJ_UNPACK_FLIP_Y_WEBGL ) {
		unpackFlipY = param;
	}
	else if( pname == EJ_UNPACK_PREMULTIPLY_ALPHA_WEBGL ) {
		premultiplyAlpha = param;
	}
	else {
		glPixelStorei(pname, param);
	}
	return NULL;
}

EJ_BIND_FUNCTION(polygonOffset, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLfloat factor = JSValueToNumberFast(ctx, argv[0]);
	GLfloat units = JSValueToNumberFast(ctx, argv[1]);
	
	glPolygonOffset(factor, units);
	return NULL;
}

EJ_BIND_FUNCTION(readPixels, ctx, argc, argv) {
	if( argc < 7 ) { return NULL; }
	
	GLint x = JSValueToNumberFast(ctx, argv[0]);
	GLint y = JSValueToNumberFast(ctx, argv[1]);
	GLsizei width = JSValueToNumberFast(ctx, argv[2]);
	GLsizei height = JSValueToNumberFast(ctx, argv[3]);
	GLenum format = JSValueToNumberFast(ctx, argv[4]);
	GLenum type = JSValueToNumberFast(ctx, argv[5]);
	
	size_t size;
	void * pixels = JSTypedArrayGetDataPtr(ctx, argv[6], &size);
	if( size >= width * height * 4 ) {
		glReadPixels(x, y, width, height, format, type, pixels);
	}
	
	return NULL;
}

EJ_BIND_FUNCTION(renderbufferStorage, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum internalformat = JSValueToNumberFast(ctx, argv[1]);
	GLsizei width = JSValueToNumberFast(ctx, argv[2]);
	GLsizei height = JSValueToNumberFast(ctx, argv[3]);
	
	glRenderbufferStorage(target, internalformat, width, height);
	return NULL;
}

EJ_BIND_FUNCTION(sampleCoverage, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLclampf value = JSValueToNumberFast(ctx, argv[0]);
	GLboolean invert = JSValueToNumberFast(ctx, argv[1]);
	
	glSampleCoverage(value, invert);
	return NULL;
}

EJ_BIND_FUNCTION(scissor, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLint x = JSValueToNumberFast(ctx, argv[0]);
	GLint y = JSValueToNumberFast(ctx, argv[1]);
	GLsizei width = JSValueToNumberFast(ctx, argv[2]);
	GLsizei height = JSValueToNumberFast(ctx, argv[3]);
	
	glScissor(x, y, width, height);
	return NULL;
}

EJ_BIND_FUNCTION(shaderSource, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLuint shader = [EJBindingWebGLShader indexFromJSValue:argv[0]];
	const GLchar * source = [JSValueToNSString(ctx, argv[1]) UTF8String];
	
	glShaderSource(shader, 1, &source, NULL);
	return NULL;
}

EJ_BIND_FUNCTION(stencilFunc, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	GLenum func = JSValueToNumberFast(ctx, argv[0]);
	GLint ref = JSValueToNumberFast(ctx, argv[1]);
	GLuint mask = JSValueToNumberFast(ctx, argv[2]);
	
	glStencilFunc(func, ref, mask);
	return NULL;
}

EJ_BIND_FUNCTION(stencilFuncSeparate, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLenum face = JSValueToNumberFast(ctx, argv[0]);
	GLenum func = JSValueToNumberFast(ctx, argv[1]);
	GLint ref = JSValueToNumberFast(ctx, argv[2]);
	GLuint mask = JSValueToNumberFast(ctx, argv[3]);
	
	glStencilFuncSeparate(face, func, ref, mask);
	return NULL;
}

EJ_BIND_FUNCTION(stencilMask, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	
	GLuint mask = JSValueToNumberFast(ctx, argv[0]);
	
	glStencilMask(mask);
	return NULL;
}

EJ_BIND_FUNCTION(stencilMaskSeparate, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	GLenum face = JSValueToNumberFast(ctx, argv[0]);
	GLuint mask = JSValueToNumberFast(ctx, argv[1]);
	
	glStencilMaskSeparate(face, mask);
	return NULL;
}

EJ_BIND_FUNCTION(stencilOp, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	GLenum fail = JSValueToNumberFast(ctx, argv[0]);
	GLenum zfail = JSValueToNumberFast(ctx, argv[1]);
	GLenum zpass = JSValueToNumberFast(ctx, argv[2]);
	
	glStencilOp(fail, zfail, zpass);
	return NULL;
}

EJ_BIND_FUNCTION(stencilOpSeparate, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	GLenum face = JSValueToNumberFast(ctx, argv[0]);
	GLenum fail = JSValueToNumberFast(ctx, argv[1]);
	GLenum zfail = JSValueToNumberFast(ctx, argv[2]);
	GLenum zpass = JSValueToNumberFast(ctx, argv[3]);
	
	glStencilOpSeparate(face, fail, zfail, zpass);
	return NULL;
}

EJ_BIND_FUNCTION(texImage2D, ctx, argc, argv) {	
	// TODO
	return NULL;
}

EJ_BIND_FUNCTION(texParameteri, ctx, argc, argv) {
	if ( argc < 3 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	GLint param = JSValueToNumberFast(ctx, argv[2]);
	
	glTexParameteri(target, pname, param);
	return NULL;
}

EJ_BIND_FUNCTION(texParameterf, ctx, argc, argv) {
	if ( argc < 3 ) { return NULL; }
	
	GLenum target = JSValueToNumberFast(ctx, argv[0]);
	GLenum pname = JSValueToNumberFast(ctx, argv[1]);
	GLfloat param = JSValueToNumberFast(ctx, argv[2]);
	
	glTexParameterf(target, pname, param);
	return NULL;
}

EJ_BIND_FUNCTION(uniform1f, ctx, argc, argv) {
	if ( argc < 2 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	
	glUniform1f(uniform, x);
	return NULL;
}

EJ_BIND_FUNCTION(uniform1i, ctx, argc, argv) {
	if ( argc < 2 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLint x = JSValueToNumberFast(ctx, argv[1]);
	
	glUniform1i(uniform, x);
	return NULL;
}

EJ_BIND_FUNCTION(uniform2f, ctx, argc, argv) {
	if ( argc < 3 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	GLfloat y = JSValueToNumberFast(ctx, argv[2]);
	
	glUniform2f(uniform, x, y);
	return NULL;
}

EJ_BIND_FUNCTION(uniform2i, ctx, argc, argv) {
	if ( argc < 3 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLint x = JSValueToNumberFast(ctx, argv[1]);
	GLint y = JSValueToNumberFast(ctx, argv[2]);
	
	glUniform2i(uniform, x, y);
	return NULL;
}

EJ_BIND_FUNCTION(uniform3f, ctx, argc, argv) {
	if ( argc < 4 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	GLfloat y = JSValueToNumberFast(ctx, argv[2]);
	GLfloat z = JSValueToNumberFast(ctx, argv[3]);
	
	glUniform3f(uniform, x, y, z);
	return NULL;
}

EJ_BIND_FUNCTION(uniform3i, ctx, argc, argv) {
	if ( argc < 4 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLint x = JSValueToNumberFast(ctx, argv[1]);
	GLint y = JSValueToNumberFast(ctx, argv[2]);
	GLint z = JSValueToNumberFast(ctx, argv[3]);
	
	glUniform3i(uniform, x, y, z);
	return NULL;
}

EJ_BIND_FUNCTION(uniform4f, ctx, argc, argv) {
	if ( argc < 5 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	GLfloat y = JSValueToNumberFast(ctx, argv[2]);
	GLfloat z = JSValueToNumberFast(ctx, argv[3]);
	GLfloat w = JSValueToNumberFast(ctx, argv[4]);
	
	glUniform4f(uniform, x, y, z, w);
	return NULL;
}

EJ_BIND_FUNCTION(uniform4i, ctx, argc, argv) {
	if ( argc < 5 ) { return NULL; }
	
	GLuint uniform = [EJBindingWebGLUniformLocation indexFromJSValue:argv[0]];
	GLint x = JSValueToNumberFast(ctx, argv[1]);
	GLint y = JSValueToNumberFast(ctx, argv[2]);
	GLint z = JSValueToNumberFast(ctx, argv[3]);
	GLint w = JSValueToNumberFast(ctx, argv[4]);
	
	glUniform4i(uniform, x, y, z, w);
	return NULL;
}

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


EJ_BIND_FUNCTION(vertexAttrib1f, ctx, argc, argv) {
	if ( argc < 2 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	
	glVertexAttrib1f(index, x);
	return NULL;
}

EJ_BIND_FUNCTION(vertexAttrib2f, ctx, argc, argv) {
	if ( argc < 3 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	GLfloat y = JSValueToNumberFast(ctx, argv[2]);
	
	glVertexAttrib2f(index, x, y);
	return NULL;
}

EJ_BIND_FUNCTION(vertexAttrib3f, ctx, argc, argv) {
	if ( argc < 4 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	GLfloat y = JSValueToNumberFast(ctx, argv[2]);
	GLfloat z = JSValueToNumberFast(ctx, argv[3]);
	
	glVertexAttrib3f(index, x, y, z);
	return NULL;
}

EJ_BIND_FUNCTION(vertexAttrib4f, ctx, argc, argv) {
	if ( argc < 5 ) { return NULL; }
	
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLfloat x = JSValueToNumberFast(ctx, argv[1]);
	GLfloat y = JSValueToNumberFast(ctx, argv[2]);
	GLfloat z = JSValueToNumberFast(ctx, argv[3]);
	GLfloat w = JSValueToNumberFast(ctx, argv[4]);
	
	glVertexAttrib4f(index, x, y, z, w);
	return NULL;
}

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
	GLuint index = JSValueToNumberFast(ctx, argv[0]);
	GLuint itemSize = JSValueToNumberFast(ctx, argv[1]);
	GLenum type = JSValueToNumberFast(ctx, argv[2]);
	GLboolean normalized = JSValueToBoolean(ctx, argv[3]);
	GLsizei stride = JSValueToNumberFast(ctx, argv[4]);
	
	// TODO(viks): Is the following completly safe?
	GLvoid * offset = (GLvoid *)((long)JSValueToNumberFast(ctx, argv[5]));
	
	glVertexAttribPointer(index, itemSize, type, normalized, stride, offset);
	return NULL;
}

EJ_BIND_FUNCTION(viewport, ctx, argc, argv) {
	if ( argc < 4 ) { return NULL; }
	
	float scale = renderingContext.backingStoreRatio;
	GLint x = JSValueToNumberFast(ctx, argv[0]) * scale;
	GLint y = JSValueToNumberFast(ctx, argv[1]) * scale;
	GLsizei w = JSValueToNumberFast(ctx, argv[2]) * scale;
	GLsizei h = JSValueToNumberFast(ctx, argv[3]) * scale;
	
	glViewport(x, y, w, h);
	return NULL;
}


// ClearBufferMask
EJ_BIND_CONST(DEPTH_BUFFER_BIT, GL_DEPTH_BUFFER_BIT);
EJ_BIND_CONST(STENCIL_BUFFER_BIT, GL_STENCIL_BUFFER_BIT);
EJ_BIND_CONST(COLOR_BUFFER_BIT, GL_COLOR_BUFFER_BIT);

// Boolean
EJ_BIND_CONST(FALSE, GL_FALSE);
EJ_BIND_CONST(TRUE, GL_TRUE);

// BeginMode
EJ_BIND_CONST(POINTS, GL_POINTS);
EJ_BIND_CONST(LINES, GL_LINES);
EJ_BIND_CONST(LINE_LOOP, GL_LINE_LOOP);
EJ_BIND_CONST(LINE_STRIP, GL_LINE_STRIP);
EJ_BIND_CONST(TRIANGLES, GL_TRIANGLES);
EJ_BIND_CONST(TRIANGLE_STRIP, GL_TRIANGLE_STRIP);
EJ_BIND_CONST(TRIANGLE_FAN, GL_TRIANGLE_FAN);

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
EJ_BIND_CONST(ZERO, GL_ZERO);
EJ_BIND_CONST(ONE, GL_ONE);
EJ_BIND_CONST(SRC_COLOR, GL_SRC_COLOR);
EJ_BIND_CONST(ONE_MINUS_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
EJ_BIND_CONST(SRC_ALPHA, GL_SRC_ALPHA);
EJ_BIND_CONST(ONE_MINUS_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
EJ_BIND_CONST(DST_ALPHA, GL_DST_ALPHA);
EJ_BIND_CONST(ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);

// BlendingFactorSrc
// GL_ZERO
// GL_ONE
EJ_BIND_CONST(DST_COLOR, GL_DST_COLOR);
EJ_BIND_CONST(ONE_MINUS_DST_COLOR, GL_ONE_MINUS_DST_COLOR);
EJ_BIND_CONST(SRC_ALPHA_SATURATE, GL_SRC_ALPHA_SATURATE);
// GL_SRC_ALPHA

// GL_ONE_MINUS_SRC_ALPHA
// GL_DST_ALPHA
// GL_ONE_MINUS_DST_ALPHA

// BlendEquationSeparate
EJ_BIND_CONST(FUNC_ADD, GL_FUNC_ADD);
EJ_BIND_CONST(BLEND_EQUATION, GL_BLEND_EQUATION);
EJ_BIND_CONST(BLEND_EQUATION_RGB, GL_BLEND_EQUATION_RGB); // same as BLEND_EQUATION
EJ_BIND_CONST(BLEND_EQUATION_ALPHA, GL_BLEND_EQUATION_ALPHA);

// BlendSubtract
EJ_BIND_CONST(FUNC_SUBTRACT, GL_FUNC_SUBTRACT);
EJ_BIND_CONST(FUNC_REVERSE_SUBTRACT, GL_FUNC_REVERSE_SUBTRACT);

// Separate Blend Functions
EJ_BIND_CONST(BLEND_DST_RGB, GL_BLEND_DST_RGB);
EJ_BIND_CONST(BLEND_SRC_RGB, GL_BLEND_SRC_RGB);
EJ_BIND_CONST(BLEND_DST_ALPHA, GL_BLEND_DST_ALPHA);
EJ_BIND_CONST(BLEND_SRC_ALPHA, GL_BLEND_SRC_ALPHA);
EJ_BIND_CONST(CONSTANT_COLOR, GL_CONSTANT_COLOR);
EJ_BIND_CONST(ONE_MINUS_CONSTANT_COLOR, GL_ONE_MINUS_CONSTANT_COLOR);
EJ_BIND_CONST(CONSTANT_ALPHA, GL_CONSTANT_ALPHA);
EJ_BIND_CONST(ONE_MINUS_CONSTANT_ALPHA, GL_ONE_MINUS_CONSTANT_ALPHA);
EJ_BIND_CONST(BLEND_COLOR, GL_BLEND_COLOR);

// Buffer Objects
EJ_BIND_CONST(ARRAY_BUFFER, GL_ARRAY_BUFFER);
EJ_BIND_CONST(ELEMENT_ARRAY_BUFFER, GL_ELEMENT_ARRAY_BUFFER);
EJ_BIND_CONST(ARRAY_BUFFER_BINDING, GL_ARRAY_BUFFER_BINDING);
EJ_BIND_CONST(ELEMENT_ARRAY_BUFFER_BINDING, GL_ELEMENT_ARRAY_BUFFER_BINDING);

EJ_BIND_CONST(STREAM_DRAW, GL_STREAM_DRAW);
EJ_BIND_CONST(STATIC_DRAW, GL_STATIC_DRAW);
EJ_BIND_CONST(DYNAMIC_DRAW, GL_DYNAMIC_DRAW);

EJ_BIND_CONST(BUFFER_SIZE, GL_BUFFER_SIZE);
EJ_BIND_CONST(BUFFER_USAGE, GL_BUFFER_USAGE);

EJ_BIND_CONST(CURRENT_VERTEX_ATTRIB, GL_CURRENT_VERTEX_ATTRIB);

// CullFaceMode
EJ_BIND_CONST(FRONT, GL_FRONT);
EJ_BIND_CONST(BACK, GL_BACK);
EJ_BIND_CONST(FRONT_AND_BACK, GL_FRONT_AND_BACK);

// EnableCap
EJ_BIND_CONST(TEXTURE_2D, GL_TEXTURE_2D);
EJ_BIND_CONST(CULL_FACE, GL_CULL_FACE);
EJ_BIND_CONST(BLEND, GL_BLEND);
EJ_BIND_CONST(DITHER, GL_DITHER);
EJ_BIND_CONST(STENCIL_TEST, GL_STENCIL_TEST);
EJ_BIND_CONST(DEPTH_TEST, GL_DEPTH_TEST);
EJ_BIND_CONST(SCISSOR_TEST, GL_SCISSOR_TEST);
EJ_BIND_CONST(POLYGON_OFFSET_FILL, GL_POLYGON_OFFSET_FILL);
EJ_BIND_CONST(SAMPLE_ALPHA_TO_COVERAGE, GL_SAMPLE_ALPHA_TO_COVERAGE);
EJ_BIND_CONST(SAMPLE_COVERAGE, GL_SAMPLE_COVERAGE);

// ErrorCode
EJ_BIND_CONST(NO_ERROR, GL_NO_ERROR);
EJ_BIND_CONST(INVALID_ENUM, GL_INVALID_ENUM);
EJ_BIND_CONST(INVALID_VALUE, GL_INVALID_VALUE);
EJ_BIND_CONST(INVALID_OPERATION, GL_INVALID_OPERATION);
EJ_BIND_CONST(OUT_OF_MEMORY, GL_OUT_OF_MEMORY);

// FrontFaceDirection
EJ_BIND_CONST(CW, GL_CW);
EJ_BIND_CONST(CCW, GL_CCW);

// GetPName
EJ_BIND_CONST(LINE_WIDTH, GL_LINE_WIDTH);
EJ_BIND_CONST(ALIASED_POINT_SIZE_RANGE, GL_ALIASED_POINT_SIZE_RANGE);
EJ_BIND_CONST(ALIASED_LINE_WIDTH_RANGE, GL_ALIASED_LINE_WIDTH_RANGE);
EJ_BIND_CONST(CULL_FACE_MODE, GL_CULL_FACE_MODE);
EJ_BIND_CONST(FRONT_FACE, GL_FRONT_FACE);
EJ_BIND_CONST(DEPTH_RANGE, GL_DEPTH_RANGE);
EJ_BIND_CONST(DEPTH_WRITEMASK, GL_DEPTH_WRITEMASK);
EJ_BIND_CONST(DEPTH_CLEAR_VALUE, GL_DEPTH_CLEAR_VALUE);
EJ_BIND_CONST(DEPTH_FUNC, GL_DEPTH_FUNC);
EJ_BIND_CONST(STENCIL_CLEAR_VALUE, GL_STENCIL_CLEAR_VALUE);
EJ_BIND_CONST(STENCIL_FUNC, GL_STENCIL_FUNC);
EJ_BIND_CONST(STENCIL_FAIL, GL_STENCIL_FAIL);
EJ_BIND_CONST(STENCIL_PASS_DEPTH_FAIL, GL_STENCIL_PASS_DEPTH_FAIL);
EJ_BIND_CONST(STENCIL_PASS_DEPTH_PASS, GL_STENCIL_PASS_DEPTH_PASS);
EJ_BIND_CONST(STENCIL_REF, GL_STENCIL_REF);
EJ_BIND_CONST(STENCIL_VALUE_MASK, GL_STENCIL_VALUE_MASK);
EJ_BIND_CONST(STENCIL_WRITEMASK, GL_STENCIL_WRITEMASK);
EJ_BIND_CONST(STENCIL_BACK_FUNC, GL_STENCIL_BACK_FUNC);
EJ_BIND_CONST(STENCIL_BACK_FAIL, GL_STENCIL_BACK_FAIL);
EJ_BIND_CONST(STENCIL_BACK_PASS_DEPTH_FAIL, GL_STENCIL_BACK_PASS_DEPTH_FAIL);
EJ_BIND_CONST(STENCIL_BACK_PASS_DEPTH_PASS, GL_STENCIL_BACK_PASS_DEPTH_PASS);
EJ_BIND_CONST(STENCIL_BACK_REF, GL_STENCIL_BACK_REF);
EJ_BIND_CONST(STENCIL_BACK_VALUE_MASK, GL_STENCIL_BACK_VALUE_MASK);
EJ_BIND_CONST(STENCIL_BACK_WRITEMASK, GL_STENCIL_BACK_WRITEMASK);
EJ_BIND_CONST(VIEWPORT, GL_VIEWPORT);
EJ_BIND_CONST(SCISSOR_BOX, GL_SCISSOR_BOX);
// GL_SCISSOR_TEST
EJ_BIND_CONST(COLOR_CLEAR_VALUE, GL_COLOR_CLEAR_VALUE);
EJ_BIND_CONST(COLOR_WRITEMASK, GL_COLOR_WRITEMASK);
EJ_BIND_CONST(UNPACK_ALIGNMENT, GL_UNPACK_ALIGNMENT);
EJ_BIND_CONST(PACK_ALIGNMENT, GL_PACK_ALIGNMENT);
EJ_BIND_CONST(MAX_TEXTURE_SIZE, GL_MAX_TEXTURE_SIZE);
EJ_BIND_CONST(MAX_VIEWPORT_DIMS, GL_MAX_VIEWPORT_DIMS);
EJ_BIND_CONST(SUBPIXEL_BITS, GL_SUBPIXEL_BITS);
EJ_BIND_CONST(RED_BITS, GL_RED_BITS);
EJ_BIND_CONST(GREEN_BITS, GL_GREEN_BITS);
EJ_BIND_CONST(BLUE_BITS, GL_BLUE_BITS);
EJ_BIND_CONST(ALPHA_BITS, GL_ALPHA_BITS);
EJ_BIND_CONST(DEPTH_BITS, GL_DEPTH_BITS);
EJ_BIND_CONST(STENCIL_BITS, GL_STENCIL_BITS);
EJ_BIND_CONST(POLYGON_OFFSET_UNITS, GL_POLYGON_OFFSET_UNITS);
// GL_POLYGON_OFFSET_FILL
EJ_BIND_CONST(POLYGON_OFFSET_FACTOR, GL_POLYGON_OFFSET_FACTOR);
EJ_BIND_CONST(TEXTURE_BINDING_2D, GL_TEXTURE_BINDING_2D);
EJ_BIND_CONST(SAMPLE_BUFFERS, GL_SAMPLE_BUFFERS);
EJ_BIND_CONST(SAMPLES, GL_SAMPLES);
EJ_BIND_CONST(SAMPLE_COVERAGE_VALUE, GL_SAMPLE_COVERAGE_VALUE);
EJ_BIND_CONST(SAMPLE_COVERAGE_INVERT, GL_SAMPLE_COVERAGE_INVERT);

// GetTextureParameter
// GL_TEXTURE_MAG_FILTER
// GL_TEXTURE_MIN_FILTER
// GL_TEXTURE_WRAP_S
// GL_TEXTURE_WRAP_T

EJ_BIND_CONST(NUM_COMPRESSED_TEXTURE_FORMATS, GL_NUM_COMPRESSED_TEXTURE_FORMATS);
EJ_BIND_CONST(COMPRESSED_TEXTURE_FORMATS, GL_COMPRESSED_TEXTURE_FORMATS);

// HintMode
EJ_BIND_CONST(DONT_CARE, GL_DONT_CARE);
EJ_BIND_CONST(FASTEST, GL_FASTEST);
EJ_BIND_CONST(NICEST, GL_NICEST);

// HintTarget
EJ_BIND_CONST(GENERATE_MIPMAP_HINT, GL_GENERATE_MIPMAP_HINT);

// DataType
EJ_BIND_CONST(BYTE, GL_BYTE);
EJ_BIND_CONST(UNSIGNED_BYTE, GL_UNSIGNED_BYTE);
EJ_BIND_CONST(SHORT, GL_SHORT);
EJ_BIND_CONST(UNSIGNED_SHORT, GL_UNSIGNED_SHORT);
EJ_BIND_CONST(INT, GL_INT);
EJ_BIND_CONST(UNSIGNED_INT, GL_UNSIGNED_INT);
EJ_BIND_CONST(FLOAT, GL_FLOAT);
EJ_BIND_CONST(FIXED, GL_FIXED);

// PixelFormat
EJ_BIND_CONST(DEPTH_COMPONENT, GL_DEPTH_COMPONENT);
EJ_BIND_CONST(ALPHA, GL_ALPHA);
EJ_BIND_CONST(RGB, GL_RGB);
EJ_BIND_CONST(RGBA, GL_RGBA);
EJ_BIND_CONST(LUMINANCE, GL_LUMINANCE);
EJ_BIND_CONST(LUMINANCE_ALPHA, GL_LUMINANCE_ALPHA);

// PixelType
// GL_UNSIGNED_BYTE
EJ_BIND_CONST(UNSIGNED_SHORT_4_4_4_4, GL_UNSIGNED_SHORT_4_4_4_4);
EJ_BIND_CONST(UNSIGNED_SHORT_5_5_5_1, GL_UNSIGNED_SHORT_5_5_5_1);
EJ_BIND_CONST(UNSIGNED_SHORT_5_6_5, GL_UNSIGNED_SHORT_5_6_5);

// Shaders
EJ_BIND_CONST(FRAGMENT_SHADER, GL_FRAGMENT_SHADER);
EJ_BIND_CONST(VERTEX_SHADER, GL_VERTEX_SHADER);
EJ_BIND_CONST(MAX_VERTEX_ATTRIBS, GL_MAX_VERTEX_ATTRIBS);
EJ_BIND_CONST(MAX_VERTEX_UNIFORM_VECTORS, GL_MAX_VERTEX_UNIFORM_VECTORS);
EJ_BIND_CONST(MAX_VARYING_VECTORS, GL_MAX_VARYING_VECTORS);
EJ_BIND_CONST(MAX_COMBINED_TEXTURE_IMAGE_UNITS, GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS);
EJ_BIND_CONST(MAX_VERTEX_TEXTURE_IMAGE_UNITS, GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS);
EJ_BIND_CONST(MAX_TEXTURE_IMAGE_UNITS, GL_MAX_TEXTURE_IMAGE_UNITS);
EJ_BIND_CONST(MAX_FRAGMENT_UNIFORM_VECTORS, GL_MAX_FRAGMENT_UNIFORM_VECTORS);
EJ_BIND_CONST(SHADER_TYPE, GL_SHADER_TYPE);
EJ_BIND_CONST(DELETE_STATUS, GL_DELETE_STATUS);
EJ_BIND_CONST(LINK_STATUS, GL_LINK_STATUS);
EJ_BIND_CONST(VALIDATE_STATUS, GL_VALIDATE_STATUS);
EJ_BIND_CONST(ATTACHED_SHADERS, GL_ATTACHED_SHADERS);
EJ_BIND_CONST(ACTIVE_UNIFORMS, GL_ACTIVE_UNIFORMS);
EJ_BIND_CONST(ACTIVE_UNIFORM_MAX_LENGTH, GL_ACTIVE_UNIFORM_MAX_LENGTH);
EJ_BIND_CONST(ACTIVE_ATTRIBUTES, GL_ACTIVE_ATTRIBUTES);
EJ_BIND_CONST(ACTIVE_ATTRIBUTE_MAX_LENGTH, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH);
EJ_BIND_CONST(SHADING_LANGUAGE_VERSION, GL_SHADING_LANGUAGE_VERSION);
EJ_BIND_CONST(CURRENT_PROGRAM, GL_CURRENT_PROGRAM);

// StencilFunction
EJ_BIND_CONST(NEVER, GL_NEVER);
EJ_BIND_CONST(LESS, GL_LESS);
EJ_BIND_CONST(EQUAL, GL_EQUAL);
EJ_BIND_CONST(LEQUAL, GL_LEQUAL);
EJ_BIND_CONST(GREATER, GL_GREATER);
EJ_BIND_CONST(NOTEQUAL, GL_NOTEQUAL);
EJ_BIND_CONST(GEQUAL, GL_GEQUAL);
EJ_BIND_CONST(ALWAYS, GL_ALWAYS);

// StencilOp
// GL_ZERO
EJ_BIND_CONST(KEEP, GL_KEEP);
EJ_BIND_CONST(REPLACE, GL_REPLACE);
EJ_BIND_CONST(INCR, GL_INCR);
EJ_BIND_CONST(DECR, GL_DECR);
EJ_BIND_CONST(INVERT, GL_INVERT);
EJ_BIND_CONST(INCR_WRAP, GL_INCR_WRAP);
EJ_BIND_CONST(DECR_WRAP, GL_DECR_WRAP);

// StringName
EJ_BIND_CONST(VENDOR, GL_VENDOR);
EJ_BIND_CONST(RENDERER, GL_RENDERER);
EJ_BIND_CONST(VERSION, GL_VERSION);
EJ_BIND_CONST(EXTENSIONS, GL_EXTENSIONS);

// TextureMagFilter
EJ_BIND_CONST(NEAREST, GL_NEAREST);
EJ_BIND_CONST(LINEAR, GL_LINEAR);

// TextureMinFilter
// GL_NEAREST
// GL_LINEAR
EJ_BIND_CONST(NEAREST_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_NEAREST);
EJ_BIND_CONST(LINEAR_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_NEAREST);
EJ_BIND_CONST(NEAREST_MIPMAP_LINEAR, GL_NEAREST_MIPMAP_LINEAR);
EJ_BIND_CONST(LINEAR_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR);

// TextureParameterName
EJ_BIND_CONST(TEXTURE_MAG_FILTER, GL_TEXTURE_MAG_FILTER);
EJ_BIND_CONST(TEXTURE_MIN_FILTER, GL_TEXTURE_MIN_FILTER);
EJ_BIND_CONST(TEXTURE_WRAP_S, GL_TEXTURE_WRAP_S);
EJ_BIND_CONST(TEXTURE_WRAP_T, GL_TEXTURE_WRAP_T);

// TextureTarget
// GL_TEXTURE_2D
EJ_BIND_CONST(TEXTURE, GL_TEXTURE);

EJ_BIND_CONST(TEXTURE_CUBE_MAP, GL_TEXTURE_CUBE_MAP);
EJ_BIND_CONST(TEXTURE_BINDING_CUBE_MAP, GL_TEXTURE_BINDING_CUBE_MAP);
EJ_BIND_CONST(TEXTURE_CUBE_MAP_POSITIVE_X, GL_TEXTURE_CUBE_MAP_POSITIVE_X);
EJ_BIND_CONST(TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TEXTURE_CUBE_MAP_NEGATIVE_X);
EJ_BIND_CONST(TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_POSITIVE_Y);
EJ_BIND_CONST(TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y);
EJ_BIND_CONST(TEXTURE_CUBE_MAP_POSITIVE_Z, GL_TEXTURE_CUBE_MAP_POSITIVE_Z);
EJ_BIND_CONST(TEXTURE_CUBE_MAP_NEGATIVE_Z, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);
EJ_BIND_CONST(MAX_CUBE_MAP_TEXTURE_SIZE, GL_MAX_CUBE_MAP_TEXTURE_SIZE);

// TextureUnit
EJ_BIND_CONST(TEXTURE0, GL_TEXTURE0);
EJ_BIND_CONST(TEXTURE1, GL_TEXTURE1);
EJ_BIND_CONST(TEXTURE2, GL_TEXTURE2);
EJ_BIND_CONST(TEXTURE3, GL_TEXTURE3);
EJ_BIND_CONST(TEXTURE4, GL_TEXTURE4);
EJ_BIND_CONST(TEXTURE5, GL_TEXTURE5);
EJ_BIND_CONST(TEXTURE6, GL_TEXTURE6);
EJ_BIND_CONST(TEXTURE7, GL_TEXTURE7);
EJ_BIND_CONST(TEXTURE8, GL_TEXTURE8);
EJ_BIND_CONST(TEXTURE9, GL_TEXTURE9);
EJ_BIND_CONST(TEXTURE10, GL_TEXTURE10);
EJ_BIND_CONST(TEXTURE11, GL_TEXTURE11);
EJ_BIND_CONST(TEXTURE12, GL_TEXTURE12);
EJ_BIND_CONST(TEXTURE13, GL_TEXTURE13);
EJ_BIND_CONST(TEXTURE14, GL_TEXTURE14);
EJ_BIND_CONST(TEXTURE15, GL_TEXTURE15);
EJ_BIND_CONST(TEXTURE16, GL_TEXTURE16);
EJ_BIND_CONST(TEXTURE17, GL_TEXTURE17);
EJ_BIND_CONST(TEXTURE18, GL_TEXTURE18);
EJ_BIND_CONST(TEXTURE19, GL_TEXTURE19);
EJ_BIND_CONST(TEXTURE20, GL_TEXTURE20);
EJ_BIND_CONST(TEXTURE21, GL_TEXTURE21);
EJ_BIND_CONST(TEXTURE22, GL_TEXTURE22);
EJ_BIND_CONST(TEXTURE23, GL_TEXTURE23);
EJ_BIND_CONST(TEXTURE24, GL_TEXTURE24);
EJ_BIND_CONST(TEXTURE25, GL_TEXTURE25);
EJ_BIND_CONST(TEXTURE26, GL_TEXTURE26);
EJ_BIND_CONST(TEXTURE27, GL_TEXTURE27);
EJ_BIND_CONST(TEXTURE28, GL_TEXTURE28);
EJ_BIND_CONST(TEXTURE29, GL_TEXTURE29);
EJ_BIND_CONST(TEXTURE30, GL_TEXTURE30);
EJ_BIND_CONST(TEXTURE31, GL_TEXTURE31);
EJ_BIND_CONST(ACTIVE_TEXTURE, GL_ACTIVE_TEXTURE);

// TextureWrapMode
EJ_BIND_CONST(REPEAT, GL_REPEAT);
EJ_BIND_CONST(CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE);
EJ_BIND_CONST(MIRRORED_REPEAT, GL_MIRRORED_REPEAT);

// Uniform Types
EJ_BIND_CONST(FLOAT_VEC2, GL_FLOAT_VEC2);
EJ_BIND_CONST(FLOAT_VEC3, GL_FLOAT_VEC3);
EJ_BIND_CONST(FLOAT_VEC4, GL_FLOAT_VEC4);
EJ_BIND_CONST(INT_VEC2, GL_INT_VEC2);
EJ_BIND_CONST(INT_VEC3, GL_INT_VEC3);
EJ_BIND_CONST(INT_VEC4, GL_INT_VEC4);
EJ_BIND_CONST(BOOL, GL_BOOL);
EJ_BIND_CONST(BOOL_VEC2, GL_BOOL_VEC2);
EJ_BIND_CONST(BOOL_VEC3, GL_BOOL_VEC3);
EJ_BIND_CONST(BOOL_VEC4, GL_BOOL_VEC4);
EJ_BIND_CONST(FLOAT_MAT2, GL_FLOAT_MAT2);
EJ_BIND_CONST(FLOAT_MAT3, GL_FLOAT_MAT3);
EJ_BIND_CONST(FLOAT_MAT4, GL_FLOAT_MAT4);
EJ_BIND_CONST(SAMPLER_2D, GL_SAMPLER_2D);
EJ_BIND_CONST(SAMPLER_CUBE, GL_SAMPLER_CUBE);

// Vertex Arrays
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_ENABLED, GL_VERTEX_ATTRIB_ARRAY_ENABLED);
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_SIZE, GL_VERTEX_ATTRIB_ARRAY_SIZE);
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_STRIDE, GL_VERTEX_ATTRIB_ARRAY_STRIDE);
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_TYPE, GL_VERTEX_ATTRIB_ARRAY_TYPE);
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_NORMALIZED, GL_VERTEX_ATTRIB_ARRAY_NORMALIZED);
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_POINTER, GL_VERTEX_ATTRIB_ARRAY_POINTER);
EJ_BIND_CONST(VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING);

// Read Format
EJ_BIND_CONST(IMPLEMENTATION_COLOR_READ_TYPE, GL_IMPLEMENTATION_COLOR_READ_TYPE);
EJ_BIND_CONST(IMPLEMENTATION_COLOR_READ_FORMAT, GL_IMPLEMENTATION_COLOR_READ_FORMAT);

// Shader Source
EJ_BIND_CONST(COMPILE_STATUS, GL_COMPILE_STATUS);
EJ_BIND_CONST(INFO_LOG_LENGTH, GL_INFO_LOG_LENGTH);
EJ_BIND_CONST(SHADER_SOURCE_LENGTH, GL_SHADER_SOURCE_LENGTH);
EJ_BIND_CONST(SHADER_COMPILER, GL_SHADER_COMPILER);

// Shader Binary
EJ_BIND_CONST(SHADER_BINARY_FORMATS, GL_SHADER_BINARY_FORMATS);
EJ_BIND_CONST(NUM_SHADER_BINARY_FORMATS, GL_NUM_SHADER_BINARY_FORMATS);

// Shader Precision-Specified Types
EJ_BIND_CONST(LOW_FLOAT, GL_LOW_FLOAT);
EJ_BIND_CONST(MEDIUM_FLOAT, GL_MEDIUM_FLOAT);
EJ_BIND_CONST(HIGH_FLOAT, GL_HIGH_FLOAT);
EJ_BIND_CONST(LOW_INT, GL_LOW_INT);
EJ_BIND_CONST(MEDIUM_INT, GL_MEDIUM_INT);
EJ_BIND_CONST(HIGH_INT, GL_HIGH_INT);

// Framebuffer Object.
EJ_BIND_CONST(FRAMEBUFFER, GL_FRAMEBUFFER);
EJ_BIND_CONST(RENDERBUFFER, GL_RENDERBUFFER);

EJ_BIND_CONST(RGBA4, GL_RGBA4);
EJ_BIND_CONST(RGB5_A1, GL_RGB5_A1);
EJ_BIND_CONST(RGB565, GL_RGB565);
EJ_BIND_CONST(DEPTH_COMPONENT16, GL_DEPTH_COMPONENT16);
EJ_BIND_CONST(STENCIL_INDEX, GL_STENCIL_INDEX);
EJ_BIND_CONST(STENCIL_INDEX8, GL_STENCIL_INDEX8);

EJ_BIND_CONST(RENDERBUFFER_WIDTH, GL_RENDERBUFFER_WIDTH);
EJ_BIND_CONST(RENDERBUFFER_HEIGHT, GL_RENDERBUFFER_HEIGHT);
EJ_BIND_CONST(RENDERBUFFER_INTERNAL_FORMAT, GL_RENDERBUFFER_INTERNAL_FORMAT);
EJ_BIND_CONST(RENDERBUFFER_RED_SIZE, GL_RENDERBUFFER_RED_SIZE);
EJ_BIND_CONST(RENDERBUFFER_GREEN_SIZE, GL_RENDERBUFFER_GREEN_SIZE);
EJ_BIND_CONST(RENDERBUFFER_BLUE_SIZE, GL_RENDERBUFFER_BLUE_SIZE);
EJ_BIND_CONST(RENDERBUFFER_ALPHA_SIZE, GL_RENDERBUFFER_ALPHA_SIZE);
EJ_BIND_CONST(RENDERBUFFER_DEPTH_SIZE, GL_RENDERBUFFER_DEPTH_SIZE);
EJ_BIND_CONST(RENDERBUFFER_STENCIL_SIZE, GL_RENDERBUFFER_STENCIL_SIZE);

EJ_BIND_CONST(FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE);
EJ_BIND_CONST(FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME);
EJ_BIND_CONST(FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL, GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL);
EJ_BIND_CONST(FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE, GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE);

EJ_BIND_CONST(COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT0);
EJ_BIND_CONST(DEPTH_ATTACHMENT, GL_DEPTH_ATTACHMENT);
EJ_BIND_CONST(STENCIL_ATTACHMENT, GL_STENCIL_ATTACHMENT);

EJ_BIND_CONST(NONE, GL_NONE);

EJ_BIND_CONST(FRAMEBUFFER_COMPLETE, GL_FRAMEBUFFER_COMPLETE);
EJ_BIND_CONST(FRAMEBUFFER_INCOMPLETE_ATTACHMENT, GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT);
EJ_BIND_CONST(FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT, GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT);
EJ_BIND_CONST(FRAMEBUFFER_INCOMPLETE_DIMENSIONS, GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS);
EJ_BIND_CONST(FRAMEBUFFER_UNSUPPORTED, GL_FRAMEBUFFER_UNSUPPORTED);

EJ_BIND_CONST(FRAMEBUFFER_BINDING, GL_FRAMEBUFFER_BINDING);
EJ_BIND_CONST(RENDERBUFFER_BINDING, GL_RENDERBUFFER_BINDING);
EJ_BIND_CONST(MAX_RENDERBUFFER_SIZE, GL_MAX_RENDERBUFFER_SIZE);

EJ_BIND_CONST(INVALID_FRAMEBUFFER_OPERATION, GL_INVALID_FRAMEBUFFER_OPERATION);

// WebGL-specific enums
EJ_BIND_CONST(UNPACK_FLIP_Y_WEBGL, EJ_UNPACK_FLIP_Y_WEBGL);
EJ_BIND_CONST(UNPACK_PREMULTIPLY_ALPHA_WEBGL, EJ_UNPACK_PREMULTIPLY_ALPHA_WEBGL);
EJ_BIND_CONST(CONTEXT_LOST_WEBGL, EJ_CONTEXT_LOST_WEBGL);
EJ_BIND_CONST(UNPACK_COLORSPACE_CONVERSION_WEBGL, EJ_UNPACK_COLORSPACE_CONVERSION_WEBGL);
EJ_BIND_CONST(BROWSER_DEFAULT_WEBGL, EJ_BROWSER_DEFAULT_WEBGL);

@end
