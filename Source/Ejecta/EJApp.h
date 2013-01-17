#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJConvert.h"
#import "EJCanvasContext.h"
#import "EJPresentable.h"
#import "EJGLProgram2D.h"

#define EJECTA_VERSION @"1.2"
#define EJECTA_APP_FOLDER @"App/"

#define EJECTA_BOOT_JS @"../Ejecta.js"
#define EJECTA_MAIN_JS @"index.js"

@protocol EJTouchDelegate
- (void)triggerEvent:(NSString *)name all:(NSSet *)all changed:(NSSet *)changed remaining:(NSSet *)remaining;
@end

@protocol EJLifecycleDelegate
- (void)resume;
- (void)pause;
@end

@class EJTimerCollection;

@interface EJApp : UIViewController {
	BOOL paused;
	BOOL landscapeMode;
	JSGlobalContextRef jsGlobalContext;
	UIWindow * window;
	UIImageView * loadingScreen;
	NSObject<EJTouchDelegate> * touchDelegate;
	NSObject<EJLifecycleDelegate> * lifecycleDelegate;
	
	EJTimerCollection * timers;
	NSTimeInterval currentTime;
	
	EAGLContext * glCurrentContext;
	EAGLContext * glContext2D;
	EAGLSharegroup * glSharegroup;
	CADisplayLink * displayLink;
	EJGLProgram2D * glProgram2D;
	
	NSOperationQueue * opQueue;
	EJCanvasContext * currentRenderingContext;
	EJCanvasContext<EJPresentable> * screenRenderingContext;
	
	float internalScaling;
}

- (id)initWithWindow:(UIWindow *)window;

- (void)run:(CADisplayLink *)sender;
- (void)pause;
- (void)resume;
- (void)clearCaches;
- (NSString *)pathForResource:(NSString *)resourcePath;
- (JSValueRef)createTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;

- (void)hideLoadingScreen;
- (void)loadScriptAtPath:(NSString *)path;
- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports;
- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv;
- (void)logException:(JSValueRef)exception ctx:(JSContextRef)ctxp;


+ (EJApp *)instance;


@property (nonatomic, readonly) EJGLProgram2D * glProgram2D;
@property (nonatomic, readonly) BOOL landscapeMode;
@property (nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property (nonatomic, readonly) EAGLContext * glContext2D;
@property (nonatomic, readonly) EAGLSharegroup * glSharegroup;
@property (nonatomic, readonly) UIWindow * window;
@property (nonatomic, retain) NSObject<EJTouchDelegate> * touchDelegate;
@property (nonatomic, retain) NSObject<EJLifecycleDelegate> * lifecycleDelegate;

@property (nonatomic, readonly) NSOperationQueue * opQueue;
@property (nonatomic, assign) EJCanvasContext * currentRenderingContext;
@property (nonatomic, assign) EJCanvasContext<EJPresentable> * screenRenderingContext;
@property (nonatomic) float internalScaling;

@end
