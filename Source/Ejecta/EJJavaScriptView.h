#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJConvert.h"
#import "EJCanvasContext.h"
#import "EJPresentable.h"

#import "EJSharedOpenALManager.h"
#import "EJSharedTextureCache.h"
#import "EJSharedOpenGLContext.h"
#import "EJNonRetainingProxy.h"

#define EJECTA_VERSION @"1.2"
#define EJECTA_APP_FOLDER @"App/"

#define EJECTA_BOOT_JS @"../Ejecta.js"


@protocol EJTouchDelegate
- (void)triggerEvent:(NSString *)name all:(NSSet *)all changed:(NSSet *)changed remaining:(NSSet *)remaining;
@end

@protocol EJDeviceMotionDelegate
- (void)triggerDeviceMotionEvents;
@end

@protocol EJLifecycleDelegate
- (void)resume;
- (void)pause;
@end

@class EJTimerCollection;
@class EJClassLoader;

@interface EJJavaScriptView : UIView {
	NSString *appFolder;
	NSString *bootJS;
	
	BOOL pauseOnEnterBackground;
	BOOL hasScreenCanvas;

	BOOL isPaused;
	float internalScaling;
	
	EJNonRetainingProxy	*proxy;

	JSGlobalContextRef jsGlobalContext;
	EJClassLoader *classLoader;

	EJTimerCollection *timers;
	
	EJSharedOpenGLContext *openGLContext;
	EJSharedTextureCache *textureCache;
	EJSharedOpenALManager *openALManager;
	
	EJCanvasContext *currentRenderingContext;
	EAGLContext *glCurrentContext;
	
	CADisplayLink *displayLink;

	NSObject<EJLifecycleDelegate> *lifecycleDelegate;
	NSObject<EJTouchDelegate> *touchDelegate;
	NSObject<EJDeviceMotionDelegate> *deviceMotionDelegate;
	EJCanvasContext<EJPresentable> *screenRenderingContext;

	NSOperationQueue *backgroundQueue;
	
	// Public for fast access in bound functions
	@public JSValueRef jsUndefined;
}

@property (nonatomic, copy) NSString *appFolder;
@property (nonatomic, copy) NSString *bootJS;

@property (nonatomic, assign) BOOL pauseOnEnterBackground;
@property (nonatomic, assign, getter = isPaused) BOOL isPaused; // Pauses drawing/updating of the JSView
@property (nonatomic, assign) BOOL hasScreenCanvas;

@property (nonatomic, assign) float internalScaling;

@property (nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property (nonatomic, readonly) EJSharedOpenGLContext *openGLContext;

@property (nonatomic, retain) NSObject<EJLifecycleDelegate> *lifecycleDelegate;
@property (nonatomic, retain) NSObject<EJTouchDelegate> *touchDelegate;
@property (nonatomic, retain) NSObject<EJDeviceMotionDelegate> *deviceMotionDelegate;

@property (nonatomic, retain) EJCanvasContext *currentRenderingContext;
@property (nonatomic, retain) EJCanvasContext<EJPresentable> *screenRenderingContext;

@property (nonatomic, retain) NSOperationQueue *backgroundQueue;

- (id)initWithFrame:(CGRect)frame andAppFolder:(NSString *)folder withBootJS:(NSString *)js;

- (void)loadScriptAtPath:(NSString *)path;
- (void)loadScript:(NSString *)script sourceURL:(NSString *)sourceURL;

- (void)clearCaches;

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv;
- (NSString *)pathForResource:(NSString *)resourcePath;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports;
- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;

@end
