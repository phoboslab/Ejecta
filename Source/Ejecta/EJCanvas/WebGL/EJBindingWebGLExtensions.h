#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJBindingWebGLObjects.h"


// Macros for the extension implementation that automatically add the extension name to a registry
// of available extensions. Keeps the changes required to add an extension mostly in one place
#define EJ_GL_EXTENSION_NAMED_IMPLEMENTATION(WEBGL_NAME, OPENGL_NAME) \
interface EJBinding##WEBGL_NAME : EJBindingWebGLExtension \
@end \
@implementation EJBinding##WEBGL_NAME \
\
+ (void)load { \
  addOpenGLToWebGL(@#OPENGL_NAME, @#WEBGL_NAME); \
  addWebGLToOpenGL(@#WEBGL_NAME, @#OPENGL_NAME); \
}\
- (NSString *) openGLName { \
    return @#OPENGL_NAME; \
}

#define EJ_GL_EXTENSION_END end

#define EJ_GL_EXTENSION_IMPLEMENTATION(WEBGL_NAME) \
    EJ_GL_EXTENSION_NAMED_IMPLEMENTATION(WEBGL_NAME, GL_##WEBGL_NAME)

NSString *getWebGLExtensionNameFromOpenGL(NSString *openGLName);

NSString *getOpenGLExtensionNameFromWebGL(NSString *webGLName);

const NSArray *getWebGLExtensions();

@interface EJBindingWebGLExtension : EJBindingBase {
     EJBindingCanvasContextWebGL *webglContext;
}

- (id)initWithWebGLContext:(EJBindingCanvasContextWebGL *)webglContext;

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
    scriptView:(EJJavaScriptView *)view
    webglContext:(EJBindingCanvasContextWebGL *)webglContext;

@property (readonly, nonatomic) NSString *openGLName;

@end

