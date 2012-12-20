#import "EJConvertGLArray.h"
#import "EJConvert.h"
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
