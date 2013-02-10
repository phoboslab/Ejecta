#import "EJJavaScriptView.h"
#import "EJTimer.h"
#import "EJBindingBase.h"
#import "EJUtils.h"
#import <objc/runtime.h>

// ---------------------------------------------------------------------------------
// Ejecta Main Class implementation - this creates the JavaScript Context and loads
// the initial JavaScript source files


@implementation EJJavaScriptView

@synthesize pausesAutomaticallyWhenBackgrounded;
@synthesize isPaused;
@synthesize internalScaling;
@synthesize jsGlobalContext;

@synthesize openALManager;
@synthesize glProgram2DFlat;
@synthesize glProgram2DTexture;
@synthesize glProgram2DAlphaTexture;
@synthesize glProgram2DPattern;
@synthesize glProgram2DRadialGradient;
@synthesize currentRenderingContext;
@synthesize glContext2D;
@synthesize glSharegroup;
@synthesize glCurrentContext;

@synthesize lifecycleDelegate;
@synthesize touchDelegate;
@synthesize screenRenderingContext;

@synthesize opQueue;



static EJJavaScriptView *_sharedView = nil;

+ (EJJavaScriptView*)sharedView {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedView = [[EJJavaScriptView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
	});
	return _sharedView;
}

+(id)alloc {
	@synchronized([EJJavaScriptView class]){
		NSAssert(_sharedView == nil, @"Attempt to allocate a second instance of singleton EJJavaScriptView");
		_sharedView = [super alloc];
		return _sharedView;
	}
	return nil;
}

- (id)initWithFrame:(CGRect)frame {
	if( self = [super initWithFrame:frame] ) {		
		isPaused = false;
		internalScaling = 1;
		
		self.pausesAutomaticallyWhenBackgrounded = YES;
		
		// Limit all background operations (image & sound loading) to one thread
		opQueue = [[NSOperationQueue alloc] init];
		opQueue.maxConcurrentOperationCount = 1;
		
		timers = [[EJTimerCollection alloc] init];
		
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(run:)];
		[displayLink setFrameInterval:1];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		// Create the global JS context and attach the 'Ejecta' object
		
		JSClassDefinition constructorClassDef = kJSClassDefinitionEmpty;
		constructorClassDef.callAsConstructor = ej_callAsConstructor;
		ej_constructorClass = JSClassCreate(&constructorClassDef);
		
		JSClassDefinition globalClassDef = kJSClassDefinitionEmpty;
		globalClassDef.getProperty = ej_getNativeClass;
		JSClassRef globalClass = JSClassCreate(&globalClassDef);
		
		
		jsGlobalContext = JSGlobalContextCreate(NULL);
		ej_global_undefined = JSValueMakeUndefined(jsGlobalContext);
		JSValueProtect(jsGlobalContext, ej_global_undefined);
		JSObjectRef globalObject = JSContextGetGlobalObject(jsGlobalContext);
		
		JSObjectRef iosObject = JSObjectMake(jsGlobalContext, globalClass, NULL );
		JSObjectSetProperty(
			jsGlobalContext, globalObject,
			JSStringCreateWithUTF8CString("Ejecta"), iosObject,
			kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly, NULL
		);
		
		// Create the OpenGL context for Canvas2D
		glContext2D = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		glSharegroup = glContext2D.sharegroup;
		glCurrentContext = glContext2D;
		[EAGLContext setCurrentContext:glCurrentContext];
	}
	return self;
}

- (void)setPausesAutomaticallyWhenBackgrounded:(BOOL)pauses {
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
		[self removeObserver:self forKeyPaths:pauseN];
		[self removeObserver:self forKeyPaths:resumeN];
	}
	pausesAutomaticallyWhenBackgrounded = pauses;
}

- (void)removeObserver:(id)observer forKeyPaths:(NSArray*)keyPaths {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	for (NSString *name in keyPaths) {
		[nc removeObserver:observer name:name object:nil];
	}
}

- (void)observeKeyPaths:(NSArray*)keyPaths selector:(SEL)selector {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	for (NSString *name in keyPaths) {
		[nc addObserver:self selector:selector name:name object:nil];
	}
}


#pragma mark -
#pragma mark Script loading and execution

//TODO: should not couple to app folder
- (NSString *)pathForResource:(NSString *)path {
	return [NSString stringWithFormat:@"%@/" EJECTA_APP_FOLDER "%@", [[NSBundle mainBundle] resourcePath], path];
}

- (void)loadDefaultScripts {
	// Load the initial JavaScript source files
	[self loadScriptAtPath:EJECTA_BOOT_JS];
	[self loadScriptAtPath:EJECTA_MAIN_JS];
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

#pragma mark -
#pragma mark Touch handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchDelegate triggerEvent:@"touchstart" all:event.allTouches changed:touches remaining:event.allTouches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSMutableSet *remaining = [event.allTouches mutableCopy];
	[remaining minusSet:touches];
	
	[touchDelegate triggerEvent:@"touchend" all:event.allTouches changed:touches remaining:remaining];
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

#define EJ_GL_PROGRAM_GETTER(TYPE, NAME) \
	- (TYPE *)glProgram2D##NAME { \
		if( !glProgram2D##NAME ) { \
			glProgram2D##NAME = [[TYPE alloc] initWithVertexShader:@"Vertex.vsh" fragmentShader: @ #NAME @".fsh"]; \
		} \
	return glProgram2D##NAME; \
	}

EJ_GL_PROGRAM_GETTER(EJGLProgram2D, Flat);
EJ_GL_PROGRAM_GETTER(EJGLProgram2D, Texture);
EJ_GL_PROGRAM_GETTER(EJGLProgram2D, AlphaTexture);
EJ_GL_PROGRAM_GETTER(EJGLProgram2D, Pattern);
EJ_GL_PROGRAM_GETTER(EJGLProgram2DRadialGradient, RadialGradient);

#undef EJ_GL_PROGRAM_GETTER

- (EJOpenALManager *)openALManager {
	if( !openALManager ) {
		openALManager = [[EJOpenALManager alloc] init];
	}
	return openALManager;
}

- (NSMutableDictionary *)textureCache {
	if( !textureCache ) {
		// Create a non-retaining Dictionary to hold the cached textures
		textureCache = (NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 8, &kCFCopyStringDictionaryKeyCallBacks, NULL);
	}
	return textureCache;
}

- (void)setCurrentRenderingContext:(EJCanvasContext *)renderingContext {
	if( renderingContext != currentRenderingContext ) {
		[currentRenderingContext flushBuffers];
		currentRenderingContext = nil;
		
		// Switch GL Context if different
		if( renderingContext && renderingContext.glContext != glCurrentContext ) {
			glFlush();
			glCurrentContext = renderingContext.glContext;
			[EAGLContext setCurrentContext:glCurrentContext];
		}
		
		[renderingContext prepare];
		currentRenderingContext = renderingContext;
	}
}

@end
