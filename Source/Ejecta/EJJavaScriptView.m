#import "EJJavaScriptView.h"
#import "EJTimer.h"
#import "EJBindingBase.h"
#import "EJClassLoader.h"
#import <objc/runtime.h>


#pragma mark -
#pragma mark Ejecta view Implementation

@implementation EJJavaScriptView

@synthesize pauseOnEnterBackground;
@synthesize isPaused;
@synthesize hasScreenCanvas;
@synthesize internalScaling;
@synthesize jsGlobalContext;

@synthesize currentRenderingContext;
@synthesize openGLContext;

@synthesize lifecycleDelegate;
@synthesize touchDelegate;
@synthesize deviceMotionDelegate;
@synthesize screenRenderingContext;

@synthesize backgroundQueue;

- (id)initWithFrame:(CGRect)frame {
	if( self = [super initWithFrame:frame] ) {		
		isPaused = false;
		internalScaling = 1;

		// CADisplayLink (and NSNotificationCenter?) retains it's target, but this
		// is causing a retain loop - we can't completely release the scriptView
		// from the outside.
		// So we're using a "weak proxy" that doesn't retain the scriptView; we can
		// then just invalidate the CADisplayLink in our dealloc and be done with it.
		proxy = [[EJNonRetainingProxy proxyWithTarget:self] retain];
		
		self.pauseOnEnterBackground = YES;
		
		// Limit all background operations (image & sound loading) to one thread
		backgroundQueue = [[NSOperationQueue alloc] init];
		backgroundQueue.maxConcurrentOperationCount = 1;
		
		timers = [[EJTimerCollection alloc] initWithScriptView:self];
		
		displayLink = [[CADisplayLink displayLinkWithTarget:proxy selector:@selector(run:)] retain];
		[displayLink setFrameInterval:1];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		// Create the global JS context in its own group, so it can be released properly
		jsGlobalContext = JSGlobalContextCreateInGroup(NULL, NULL);
		jsUndefined = JSValueMakeUndefined(jsGlobalContext);
		JSValueProtect(jsGlobalContext, jsUndefined);
		
		// Attach all native class constructors to 'Ejecta'
		classLoader = [[EJClassLoader alloc] initWithScriptView:self name:@"Ejecta"];
		
		
		// Retain the caches here, so even if they're currently unused in JavaScript,
		// they will persist until the last scriptView is released
		textureCache = [[EJSharedTextureCache instance] retain];
		openALManager = [[EJSharedOpenALManager instance] retain];
		openGLContext = [[EJSharedOpenGLContext instance] retain];
		
		// Create the OpenGL context for Canvas2D
		glCurrentContext = openGLContext.glContext2D;
		[EAGLContext setCurrentContext:glCurrentContext];
		
		[self loadScriptAtPath:EJECTA_BOOT_JS];
	}
	return self;
}

- (void)dealloc {
	// Wait until all background operations are finished. If we would just release the
	// backgroundQueue it would cancel running operations (such as texture loading) and
	// could keep some dependencies dangeling
	[backgroundQueue waitUntilAllOperationsAreFinished];
	[backgroundQueue release];
	
	// Careful, order is important! The JS context has to be released first;
	// it will release the canvas objects which still need the openGLContext
	// to be present, to release textures etc.
	// Set 'jsGlobalContext' to null before releasing it, because it may be
	// referenced by bound objects dealloc method
	JSValueUnprotect(jsGlobalContext, jsUndefined);
	JSGlobalContextRef ctxref = jsGlobalContext;
	jsGlobalContext = NULL;
	JSGlobalContextRelease(ctxref);
	
	// Remove from notification center
	self.pauseOnEnterBackground = false;
	
	// Remove from display link
	[displayLink invalidate];
	[displayLink release];
	
	[textureCache release];
	[openALManager release];
	[classLoader release];
	
	[screenRenderingContext finish];
	[screenRenderingContext release];
	[currentRenderingContext release];
	
	[touchDelegate release];
	[lifecycleDelegate release];
	[deviceMotionDelegate release];
	
	[timers release];
	
	[openGLContext release];
	[super dealloc];
}

- (void)setPauseOnEnterBackground:(BOOL)pauses {
	NSArray *pauseN = @[UIApplicationWillResignActiveNotification,
		UIApplicationDidEnterBackgroundNotification,
		UIApplicationWillTerminateNotification];
	NSArray *resumeN = @[UIApplicationWillEnterForegroundNotification,
		UIApplicationDidBecomeActiveNotification];
	
	if (pauses) {
		[self observeKeyPaths:pauseN selector:@selector(pause)];
		[self observeKeyPaths:resumeN selector:@selector(resume)];
	} 
	else {
		[self removeObserverForKeyPaths:pauseN];
		[self removeObserverForKeyPaths:resumeN];
	}
	pauseOnEnterBackground = pauses;
}

- (void)removeObserverForKeyPaths:(NSArray*)keyPaths {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	for( NSString *name in keyPaths ) {
		[nc removeObserver:proxy name:name object:nil];
	}
}

- (void)observeKeyPaths:(NSArray*)keyPaths selector:(SEL)selector {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	for( NSString *name in keyPaths ) {
		[nc addObserver:proxy selector:selector name:name object:nil];
	}
}


#pragma mark -
#pragma mark Script loading and execution

//TODO: should not couple to app folder
- (NSString *)pathForResource:(NSString *)path {
	return [NSString stringWithFormat:@"%@/" EJECTA_APP_FOLDER "%@", [[NSBundle mainBundle] resourcePath], path];
}

- (void)loadScriptAtPath:(NSString *)path {
	NSString *script = [NSString stringWithContentsOfFile:[self pathForResource:path] encoding:NSUTF8StringEncoding error:NULL];
	
	if( !script ) {
		NSLog(@"Error: Can't Find Script %@", path );
		return;
	}
	
	NSLog(@"Loading Script: %@", path );
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSStringRef pathJS = JSStringCreateWithCFString((CFStringRef)path);
	
	JSValueRef exception = NULL;
	JSEvaluateScript(jsGlobalContext, scriptJS, NULL, pathJS, 0, &exception );
	[self logException:exception ctx:jsGlobalContext];
	
	JSStringRelease( scriptJS );
	JSStringRelease( pathJS );
}

- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports {
	NSString *path = [moduleId stringByAppendingString:@".js"];
	NSString *script = [NSString stringWithContentsOfFile:[self pathForResource:path] encoding:NSUTF8StringEncoding error:NULL];
	
	if( !script ) {
		NSLog(@"Error: Can't Find Module %@", moduleId );
		return NULL;
	}
	
	NSLog(@"Loading Module: %@", moduleId );
	
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSStringRef pathJS = JSStringCreateWithCFString((CFStringRef)path);
	JSStringRef parameterNames[] = {
		JSStringCreateWithUTF8CString("module"),
		JSStringCreateWithUTF8CString("exports"),
	};
	
	JSValueRef exception = NULL;
	JSObjectRef func = JSObjectMakeFunction(jsGlobalContext, NULL, 2, parameterNames, scriptJS, pathJS, 0, &exception );
	
	JSStringRelease( scriptJS );
	JSStringRelease( pathJS );
	JSStringRelease(parameterNames[0]);
	JSStringRelease(parameterNames[1]);
	
	if( exception ) {
		[self logException:exception ctx:jsGlobalContext];
		return NULL;
	}
	
	JSValueRef params[] = { module, exports };
	return [self invokeCallback:func thisObject:NULL argc:2 argv:params];
}

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( !jsGlobalContext ) { return NULL; } // May already have been released
	
	JSValueRef exception = NULL;
	JSValueRef result = JSObjectCallAsFunction(jsGlobalContext, callback, thisObject, argc, argv, &exception );
	[self logException:exception ctx:jsGlobalContext];
	return result;
}

- (void)logException:(JSValueRef)exception ctx:(JSContextRef)ctxp {
	if( !exception ) return;
	
	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
	JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
	
	JSObjectRef exObject = JSValueToObject( ctxp, exception, NULL );
	JSValueRef line = JSObjectGetProperty( ctxp, exObject, jsLinePropertyName, NULL );
	JSValueRef file = JSObjectGetProperty( ctxp, exObject, jsFilePropertyName, NULL );
	
	NSLog(
		@"%@ at line %@ in %@",
		JSValueToNSString( ctxp, exception ),
		JSValueToNSString( ctxp, line ),
		JSValueToNSString( ctxp, file )
	);
	
	JSStringRelease( jsLinePropertyName );
	JSStringRelease( jsFilePropertyName );
}


#pragma mark -
#pragma mark Run loop

- (void)run:(CADisplayLink *)sender {
	if(isPaused) { return; }
	
	// We rather poll for device motion updates at the beginning of each frame
	// instead of spamming out updates that will never be seen.
	[deviceMotionDelegate triggerDeviceMotionEvents];
	
	// Check all timers
	[timers update];
	
	// Redraw the canvas
	self.currentRenderingContext = screenRenderingContext;
	[screenRenderingContext present];
}


- (void)pause {
	if( isPaused ) { return; }
	
	[lifecycleDelegate pause];
	[displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[screenRenderingContext finish];
	isPaused = true;
}

- (void)resume {
	if( !isPaused ) { return; }
	
	[lifecycleDelegate resume];
	[EAGLContext setCurrentContext:glCurrentContext];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	isPaused = false;
}

- (void)clearCaches {
	JSGarbageCollect(jsGlobalContext);
}

- (void)setCurrentRenderingContext:(EJCanvasContext *)renderingContext {
	if( renderingContext != currentRenderingContext ) {
		[currentRenderingContext flushBuffers];
		[currentRenderingContext release];
		
		// Switch GL Context if different
		if( renderingContext && renderingContext.glContext != glCurrentContext ) {
			glFlush();
			glCurrentContext = renderingContext.glContext;
			[EAGLContext setCurrentContext:glCurrentContext];
		}
		
		[renderingContext prepare];
		currentRenderingContext = [renderingContext retain];
	}
}


#pragma mark -
#pragma mark Touch handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchDelegate triggerEvent:@"touchstart" all:event.allTouches changed:touches remaining:event.allTouches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSMutableSet *remaining = [event.allTouches mutableCopy];
	[remaining minusSet:touches];
	
	[touchDelegate triggerEvent:@"touchend" all:event.allTouches changed:touches remaining:remaining];
	[remaining release];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchDelegate triggerEvent:@"touchmove" all:event.allTouches changed:touches remaining:event.allTouches];
}


//TODO: Does this belong in this class?
#pragma mark
#pragma mark Timers

- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat {
	if( argc != 2 || !JSValueIsObject(ctxp, argv[0]) || !JSValueIsNumber(jsGlobalContext, argv[1]) ) {
		return NULL;
	}
	
	JSObjectRef func = JSValueToObject(ctxp, argv[0], NULL);
	float interval = JSValueToNumberFast(ctxp, argv[1])/1000;
	
	// Make sure short intervals (< 18ms) run each frame
	if( interval < 0.018 ) {
		interval = 0;
	}
	
	int timerId = [timers scheduleCallback:func interval:interval repeat:repeat];
	return JSValueMakeNumber( ctxp, timerId );
}

- (JSValueRef)deleteTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( argc != 1 || !JSValueIsNumber(ctxp, argv[0]) ) return NULL;
	
	[timers cancelId:JSValueToNumberFast(ctxp, argv[0])];
	return NULL;
}

@end
