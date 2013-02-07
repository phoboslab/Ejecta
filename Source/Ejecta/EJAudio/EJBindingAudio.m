#import "EJBindingAudio.h"
#import "EJJavaScriptView.h"

@implementation EJBindingAudio

@synthesize loop, ended, volume;
@synthesize path;
@synthesize preload;

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		volume = 1;
		paused = true;
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
		if( preload != kEJAudioPreloadNone ) {
			[self load];
		}
	}
}

- (void)load {
	if( source || !path || loading ) { return; }
	
	// This will begin loading the sound in a background thread
	loading = YES;
	
	// Protect this Audio object from garbage collection, as its callback function
	// may be the only thing holding on to it
	JSValueProtect([EJJavaScriptView sharedView].jsGlobalContext, jsObject);
	
	NSString * fullPath = [[EJJavaScriptView sharedView] pathForResource:path];
	NSInvocationOperation * loadOp = [[NSInvocationOperation alloc] initWithTarget:self
				selector:@selector(loadOperation:) object:fullPath];
	loadOp.threadPriority = 0.2;
	[[EJJavaScriptView sharedView].opQueue addOperation:loadOp];
	[loadOp release];
}

- (void)loadOperation:(NSString *)fullPath {
	@autoreleasepool {	
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
		}
		src.delegate = self;
		[src autorelease];
		
		[self performSelectorOnMainThread:@selector(endLoad:) withObject:src waitUntilDone:NO];
	}
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
	[self triggerEvent:@"loadedmetadata" argc:0 argv:NULL];
	
	JSValueUnprotect([EJJavaScriptView sharedView].jsGlobalContext, jsObject);
}

- (void)sourceDidFinishPlaying:(NSObject<EJAudioSource> *)source {
	ended = true;
	[self triggerEvent:@"ended" argc:0 argv:NULL];
}

- (void)setPreload:(EJAudioPreload)preloadp {
	preload = preloadp;
	if( preload != kEJAudioPreloadNone ) {
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
		paused = false;
		ended = false;
	}
	return NULL;
}

EJ_BIND_FUNCTION(pause, ctx, argc, argv) {
	if( !source ) {
		playAfterLoad = NO;
	}
	else {
		paused = true;
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
	EJBindingAudio * audio = [[EJBindingAudio alloc] initWithContext:ctx argc:0 argv:NULL];
	JSObjectRef clone = [EJBindingAudio createJSObjectWithContext:ctx instance:audio];
	
	audio.loop = loop;
	audio.volume = volume;
	audio.preload = preload;
	audio.path = path;
	
	if( source ) {
		// If the source for this audio element was loaded,
		// load it for the cloned one as well.
		[audio load];
	}
	
	return clone;
}

EJ_BIND_GET(duration, ctx) {
	return JSValueMakeNumber(ctx, source.duration);
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
	return JSValueMakeNumber( ctx, source ? source.currentTime : 0 );
}

EJ_BIND_SET(currentTime, ctx, value) {
	[self load];
	source.currentTime = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(src, ctx) {
	return path ? NSStringToJSValue(ctx, path) : NULL;
}

EJ_BIND_SET(src, ctx, value) {
	[self setSourcePath:JSValueToNSString(ctx, value)];
	if( preload != kEJAudioPreloadNone ) {
		[self load];
	}
}

EJ_BIND_GET(ended, ctx) {
	return JSValueMakeBoolean(ctx, ended);
}

EJ_BIND_GET(paused, ctx) {
	return JSValueMakeBoolean(ctx, paused);
}

EJ_BIND_ENUM(preload, self.preload,
	"none",		// kEJAudioPreloadNone
	"metadata", // kEJAudioPreloadMetadata
	"auto"		// kEJAudioPreloadAuto
);

EJ_BIND_EVENT(loadedmetadata);
EJ_BIND_EVENT(canplaythrough);
EJ_BIND_EVENT(ended);

@end
