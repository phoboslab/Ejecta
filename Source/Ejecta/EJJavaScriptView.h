//
//  EJJavaScriptView.h
//  Ejecta
//
//  Created by Salvatore Randazzo on 2/6/13.
//
//

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

@interface EJJavaScriptView : UIView {
    
}

+ (EJJavaScriptView*)sharedView;

/* Indicates whether or the not the JS script pauses execution automatically when app enters/resumes the background state
 
 default = YES;
 */
@property (nonatomic, assign) BOOL pausesAutomaticallyWhenBackgrounded;

/* Pauses drawing/updating of the JSView
 
 
 */
@property (nonatomic, assign, getter = isPaused) BOOL isPaused;

@property (nonatomic, assign) float internalScaling;

@property (nonatomic, assign, readonly) JSGlobalContextRef jsGlobalContext;

@property (nonatomic, assign) EJCanvasContext *currentRenderingContext;

@property (nonatomic, assign) EJCanvasContext<EJPresentable> *screenRenderingContext;

@property (nonatomic, strong,   readonly) EJOpenALManager * openALManager;

@property (nonatomic, strong, readonly) EJGLProgram2D * glProgram2DFlat;
@property (nonatomic, strong, readonly) EJGLProgram2D * glProgram2DTexture;
@property (nonatomic, strong, readonly) EJGLProgram2D * glProgram2DAlphaTexture;
@property (nonatomic, strong, readonly) EJGLProgram2D * glProgram2DPattern;
@property (nonatomic, strong, readonly) EJGLProgram2DRadialGradient * glProgram2DRadialGradient;

@property (nonatomic, strong, readonly) EAGLContext *glContext2D;
@property (nonatomic, strong, readonly) EAGLSharegroup *glSharegroup;
@property (nonatomic, strong, readonly) EAGLContext *glCurrentContext;

@property (nonatomic, assign, readonly) NSMutableDictionary * textureCache;

@property (nonatomic, strong) NSObject<EJLifecycleDelegate> *lifecycleDelegate;

@property (nonatomic, strong) NSObject<EJTouchDelegate> *touchDelegate;

@property (nonatomic, strong) NSOperationQueue * opQueue;

- (void)loadDefaultScripts;
- (void)loadScriptAtPath:(NSString *)path;

- (void)clearCaches;

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv;
- (NSString *)pathForResource:(NSString *)resourcePath;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports;
- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;

@end
