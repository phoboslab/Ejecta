#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJConvert.h"
#import "EJCanvasContext.h"
#import "EJPresentable.h"
#import "EJGLProgram2D.h"
#import "EJGLProgram2DRadialGradient.h"
#import "EJOpenALManager.h"


#define EJECTA_VERSION @"1.2"
#define EJECTA_APP_FOLDER @"App/"

#define EJECTA_BOOT_JS @"../Ejecta.js"


JSValueRef _EJGlobalUndefined;
JSClassRef _EJGlobalConstructorClass;
JSValueRef EJGetNativeClass(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception);
JSObjectRef EJCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception);


@protocol EJTouchDelegate
- (void)triggerEvent:(NSString *)name all:(NSSet *)all changed:(NSSet *)changed remaining:(NSSet *)remaining;
@end

@protocol EJLifecycleDelegate
- (void)resume;
- (void)pause;
@end

@class EJTimerCollection;

@interface EJJavaScriptView : UIView {
	BOOL pausesAutomaticallyWhenBackgrounded;

	BOOL isPaused;
	float internalScaling;

	JSGlobalContextRef jsGlobalContext;

	EJTimerCollection *timers;
	NSMutableDictionary *textureCache;
	EJOpenALManager *openALManager;
	EJGLProgram2D *glProgram2DFlat;
	EJGLProgram2D *glProgram2DTexture;
	EJGLProgram2D *glProgram2DAlphaTexture;
	EJGLProgram2D *glProgram2DPattern;
	EJGLProgram2DRadialGradient *glProgram2DRadialGradient;
	EJCanvasContext *currentRenderingContext;
	
	EAGLContext *glContext2D;
	EAGLSharegroup *glSharegroup;
	EAGLContext *glCurrentContext;
	
	CADisplayLink *displayLink;

	NSObject<EJLifecycleDelegate> *lifecycleDelegate;
	NSObject<EJTouchDelegate> *touchDelegate;
	EJCanvasContext<EJPresentable> *screenRenderingContext;

	NSOperationQueue *opQueue;
}

+ (EJJavaScriptView*)sharedView;

@property (nonatomic, assign) BOOL pausesAutomaticallyWhenBackgrounded;

@property (nonatomic, assign, getter = isPaused) BOOL isPaused; // Pauses drawing/updating of the JSView
@property (nonatomic, assign) float internalScaling;

@property (nonatomic, readonly) JSGlobalContextRef jsGlobalContext;

@property (nonatomic, readonly) NSMutableDictionary *textureCache;
@property (nonatomic, readonly) EJOpenALManager *openALManager;

@property (nonatomic, readonly) EJGLProgram2D *glProgram2DFlat;
@property (nonatomic, readonly) EJGLProgram2D *glProgram2DTexture;
@property (nonatomic, readonly) EJGLProgram2D *glProgram2DAlphaTexture;
@property (nonatomic, readonly) EJGLProgram2D *glProgram2DPattern;
@property (nonatomic, readonly) EJGLProgram2DRadialGradient *glProgram2DRadialGradient;
@property (nonatomic, readonly) EAGLContext *glContext2D;
@property (nonatomic, readonly) EAGLSharegroup *glSharegroup;
@property (nonatomic, readonly) EAGLContext *glCurrentContext;

@property (nonatomic, retain) NSObject<EJLifecycleDelegate> *lifecycleDelegate;
@property (nonatomic, retain) NSObject<EJTouchDelegate> *touchDelegate;

@property (nonatomic, retain) EJCanvasContext *currentRenderingContext;
@property (nonatomic, retain) EJCanvasContext<EJPresentable> *screenRenderingContext;

@property (nonatomic, retain) NSOperationQueue *opQueue;

- (void)loadScriptAtPath:(NSString *)path;

- (void)clearCaches;

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv;
- (NSString *)pathForResource:(NSString *)resourcePath;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports;
- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;

@end
