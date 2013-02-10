#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJConvert.h"
#import "EJCanvasContext.h"
#import "EJPresentable.h"
#import "EJGLProgram2D.h"
#import "EJGLProgram2DRadialGradient.h"
#import "EJOpenALManager.h"

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
	
	CADisplayLink * displayLink;

	NSObject<EJLifecycleDelegate> *lifecycleDelegate;
	NSObject<EJTouchDelegate> *touchDelegate;
	EJCanvasContext<EJPresentable> *screenRenderingContext;

	NSOperationQueue *opQueue;
}

+ (EJJavaScriptView*)sharedView;

@property (nonatomic, assign) BOOL pausesAutomaticallyWhenBackgrounded;

@property (nonatomic, assign, getter = isPaused) BOOL isPaused; // Pauses drawing/updating of the JSView
@property (nonatomic, assign) float internalScaling;

@property (nonatomic, assign, readonly) JSGlobalContextRef jsGlobalContext;

@property (nonatomic, retain, readonly) NSMutableDictionary *textureCache;
@property (nonatomic, retain, readonly) EJOpenALManager *openALManager;
@property (nonatomic, retain, readonly) EJGLProgram2D *glProgram2DFlat;
@property (nonatomic, retain, readonly) EJGLProgram2D *glProgram2DTexture;
@property (nonatomic, retain, readonly) EJGLProgram2D *glProgram2DAlphaTexture;
@property (nonatomic, retain, readonly) EJGLProgram2D *glProgram2DPattern;
@property (nonatomic, retain, readonly) EJGLProgram2DRadialGradient *glProgram2DRadialGradient;
@property (nonatomic, assign) EJCanvasContext *currentRenderingContext;
@property (nonatomic, retain, readonly) EAGLContext *glContext2D;
@property (nonatomic, retain, readonly) EAGLSharegroup *glSharegroup;
@property (nonatomic, retain, readonly) EAGLContext *glCurrentContext;

@property (nonatomic, retain) NSObject<EJLifecycleDelegate> *lifecycleDelegate;
@property (nonatomic, retain) NSObject<EJTouchDelegate> *touchDelegate;
@property (nonatomic, assign) EJCanvasContext<EJPresentable> *screenRenderingContext;

@property (nonatomic, retain) NSOperationQueue *opQueue;

- (void)loadDefaultScripts;
- (void)loadScriptAtPath:(NSString *)path;

- (void)clearCaches;

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv;
- (NSString *)pathForResource:(NSString *)resourcePath;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports;
- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;

@end
