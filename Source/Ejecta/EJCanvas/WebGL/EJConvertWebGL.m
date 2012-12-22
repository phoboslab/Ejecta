#import "EJConvertWebGL.h"
#import "EJConvert.h"
#import <JavaScriptCore/JSTypedArray.h>


void EJFlipPixelsY(GLuint bytesPerRow, GLuint rows, GLubyte * pixels) {
	if( !pixels ) { return; }
	
	GLuint middle = rows/2;
	GLuint intsPerRow = bytesPerRow / sizeof(GLuint);
	GLuint remainingBytes = bytesPerRow - intsPerRow * sizeof(GLuint);
	
	for( GLuint rowTop = 0, rowBottom = rows-1; rowTop < middle; rowTop++, rowBottom-- ) {
		
		// Swap bytes in packs of sizeof(GLuint) bytes
		GLuint * iTop = (GLuint *)(pixels + rowTop * bytesPerRow);
		GLuint * iBottom = (GLuint *)(pixels + rowBottom * bytesPerRow);
		
		GLuint itmp;
		GLint n = intsPerRow;
		do {
			itmp = *iTop;
			*iTop++ = *iBottom;
			*iBottom++ = itmp;
		} while(--n > 0);
		
		// Swap the remaining bytes
		GLubyte * bTop = (GLubyte *)iTop;
		GLubyte * bBottom = (GLubyte *)iBottom;
		
		GLubyte btmp;
		switch( remainingBytes ) {
			case 3: btmp = *bTop; *bTop++ = *bBottom; *bBottom++ = btmp;
			case 2: btmp = *bTop; *bTop++ = *bBottom; *bBottom++ = btmp;
			case 1: btmp = *bTop; *bTop = *bBottom; *bBottom = btmp;
		}
	}
}

void EJPremultiplyAlpha(GLuint width, GLuint height, GLenum format, GLubyte * pixels) {
	if( !pixels ) { return;	}
		
	if( format == GL_RGBA ) {
		GLuint length = width * height * 4;
		for( int i = 0; i < length; i += 4 ) {
			float f = (float)pixels[i+3]/255.0f;
			pixels[i+0] = (float)pixels[i+0] * f;
			pixels[i+1] = (float)pixels[i+1] * f;
			pixels[i+2] = (float)pixels[i+2] * f;
		}
	}
	else if ( format == GL_LUMINANCE_ALPHA ) {
		GLuint length = width * height * 2;
		for( int i = 0; i < length; i += 4 ) {
			float f = (float)pixels[i+1]/255.0f;
			pixels[i+0] = (float)pixels[i+0] * f;
		}
	}
}

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
