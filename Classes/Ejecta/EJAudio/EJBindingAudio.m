#import "EJBindingAudio.h"


@implementation EJBindingAudio

@synthesize loop, ended, volume;
@synthesize path;
@synthesize preload;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		volume = 1;
		preload = kEJAudioPreloadNone;
		
		if( argc > 0 ) {
			[self setSourcePath:JSValueToNSString(ctx, argv[0])];
		}
	}
	return self;
}

- (void)dealloc {
	[source release];
	[path release];
	[super dealloc];
}

- (void)setSourcePath:(NSString *)pathp {
	if( !path || ![path isEqualToString:pathp] ) {
		[path release];
		[source release];
		source = NULL;
		
		path = [pathp retain];
		if( preload == kEJAudioPreloadAuto ) {
			[self load];
		}
	}
}

- (void)load {
	if( source || !path || loading ) { return; }
	
	// This will begin loading the sound in a background thread
	loading = YES;
	
	NSString * fullPath = [[EJApp instance] pathForResource:path];
	NSInvocationOperation* loadOp = [[NSInvocationOperation alloc] initWithTarget:self
				selector:@selector(loadOperation:) object:fullPath];
	[loadOp setThreadPriority:0.0];
	[[EJApp instance].opQueue addOperation:loadOp];
	[loadOp release];
}

- (void)loadOperation:(NSString *)fullPath {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	// Decide whether to load the sound as OpenAL or AVAudioPlayer source
	unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil] fileSize];
	
	NSObject<EJAudioSource> * src;
	if( size <= EJ_AUDIO_OPENAL_MAX_SIZE ) {
		NSLog(@"Loading Sound(OpenAL): %@", path);
		src = [[EJAudioSourceOpenAL alloc] initWithPath:fullPath];
	}
	else {
		NSLog(@"Loading Sound(AVAudio): %@", path);
		src = [[EJAudioSourceAVAudio alloc] initWithPath:fullPath];
		((EJAudioSourceAVAudio *)src).delegate = self;
	}
	[src autorelease];
	
	[self performSelectorOnMainThread:@selector(endLoad:) withObject:src waitUntilDone:NO];
	[autoreleasepool release];
}

- (void)endLoad:(NSObject<EJAudioSource> *)src {
	source = [src retain];
	[source setLooping:loop];
	[source setVolume:volume];
	
	if( playAfterLoad ) {
		[source play];
	}
	loading = NO;
	
	[self triggerEvent:@"canplaythrough" argc:0 argv:NULL];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	ended = true;
	[self triggerEvent:@"ended" argc:0 argv:NULL];
}

- (void)setPreload:(EJAudioPreload)preloadp {
	preload = preloadp;
	if( preload == kEJAudioPreloadAuto ) {
		[self load];
	}
}


EJ_BIND_FUNCTION(play, ctx, argc, argv) {
	if( !source ) {
		playAfterLoad = YES;
		[self load];
	}
	else {
		[source play];
		ended = false;
	}
	return NULL;
}

EJ_BIND_FUNCTION(pause, ctx, argc, argv) {
	if( !source ) {
		playAfterLoad = NO;
	}
	else {
		[source pause];
	}
	return NULL;
}

EJ_BIND_FUNCTION(load, ctx, argc, argv) {
	[self load];
	return NULL;
}

EJ_BIND_FUNCTION(canPlayType, ctx, argc, argv) {
	if( argc != 1 ) return NULL;
	
	NSString * mime = JSValueToNSString(ctx, argv[0]);
	if( 
		[mime hasPrefix:@"audio/x-caf"] ||
		[mime hasPrefix:@"audio/mpeg"] ||
		[mime hasPrefix:@"audio/mp4"]
	) {
		return NSStringToJSValue(ctx, @"probably");
	}
	return NULL;
}

EJ_BIND_FUNCTION(cloneNode, ctx, argc, argv) {
	// Create new JS object
	JSClassRef audioClass = [[EJApp instance] getJSClassForClass:[EJBindingAudio class]];
	JSObjectRef obj = JSObjectMake( ctx, audioClass, NULL );
	
	// Create the native instance
	EJBindingAudio * audio = [[EJBindingAudio alloc] initWithContext:ctx object:obj argc:0 argv:NULL];
	
	audio.loop = loop;
	audio.volume = volume;
	audio.preload = preload;
	audio.path = path;
	
	if( source ) {
		// If the source for this audio element was loaded,
		// load it for the cloned one as well.
		[audio load];
	}
	
	// Attach the native instance to the js object
	JSObjectSetPrivate( obj, (void *)audio );
	return obj;
}

EJ_BIND_GET(loop, ctx) {
	return JSValueMakeBoolean( ctx, loop );
}

EJ_BIND_SET(loop, ctx, value) {
	loop = JSValueToBoolean(ctx, value);
	[source setLooping:loop];
}

EJ_BIND_GET(volume, ctx) {
	return JSValueMakeNumber( ctx, volume );
}

EJ_BIND_SET(volume, ctx, value) {
	volume = MIN(1,MAX(JSValueToNumberFast(ctx, value),0));
	[source setVolume:volume];
}

EJ_BIND_GET(currentTime, ctx) {
	return JSValueMakeNumber( ctx, source ? [source getCurrentTime] : 0 );
}

EJ_BIND_SET(currentTime, ctx, value) {
	[self load];
	[source setCurrentTime:JSValueToNumberFast(ctx, value)];
}

EJ_BIND_GET(src, ctx) {
	return path ? NSStringToJSValue(ctx, path) : NULL;
}

EJ_BIND_SET(src, ctx, value) {
	[self setSourcePath:JSValueToNSString(ctx, value)];
	if( preload == kEJAudioPreloadAuto ) {
		[self load];
	}
}

EJ_BIND_GET(ended, ctx) {
	return JSValueMakeBoolean(ctx, ended);
}

EJ_BIND_ENUM(preload, EJAudioPreloadNames, self.preload);

EJ_BIND_EVENT(canplaythrough);
EJ_BIND_EVENT(ended);

@end
