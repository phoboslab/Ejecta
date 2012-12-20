#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#ifdef __cplusplus
extern "C" {
#endif

GLfloat * JSValueToGLfloatArray(JSContextRef ctx, JSValueRef value, size_t expectedSize);
GLint * JSValueToGLintArray(JSContextRef ctx, JSValueRef value, size_t expectedSize);

#ifdef __cplusplus
}
#endif