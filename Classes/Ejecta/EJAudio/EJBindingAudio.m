#import "EJBindingAudio.h"


@implementation EJBindingAudio

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		volume = 1;
		preload = [@"none" retain];
		
		if( argc > 0 ) {
			[self setSourcePath:JSValueToNSString(ctx, argv[0])];
		}
	}
	return self;
}

- (void)dealloc {
	[self releaseSource];
	[preload release];
	[super dealloc];
}

- (void)releaseSource {
	// If the retainCount is 2, only this instance and the .sources dictionary
	// still retain the source - so remove it from the dict and delete it completely
	if( source && [source retainCount] == 2 ) {
		[[EJOpenALManager instance].sources removeObjectForKey:path];
	}
	[source release];
	[path release];
}

- (void)setSourcePath:(NSString *)pathp {
	// Is this source already loaded? Check in the manager's sources dictionary
	NSObject<EJAudioSource> * loadedSource = [[EJOpenALManager instance].sources objectForKey:pathp];
	
	if( loadedSource && loadedSource != source ) {
		[self releaseSource];
		
		path = [pathp retain];
		source = [loadedSource retain];
	}
	else if( !loadedSource ) {
		[self releaseSource];
		
		path = [pathp retain];
	}
}

- (void)load {
	if( source || !path ) { return; }
	
	// Decide whether to load the sound as OpenAL or AVAudioPlayer source
	NSString * fullPath = [[EJApp instance] pathForResource:path];
	unsigned long long size = [[[NSFileManager defaultManager] 
		attributesOfItemAtPath:fullPath error:nil] fileSize];
		
	if( size <= EJ_AUDIO_OPENAL_MAX_SIZE ) {
		NSLog(@"Loading Sound(OpenAL): %@", path);
		source = [[EJAudioSourceOpenAL alloc] initWithPath:fullPath];
	}
	else {
		NSLog(@"Loading Sound(AVAudio): %@", path);
		source = [[EJAudioSourceAVAudio alloc] initWithPath:fullPath];
		((EJAudioSourceAVAudio *)source).delegate = self;
	}
	[source load];
	
	[source setLooping:loop];
	[source setVolume:volume];
	
	[[EJOpenALManager instance].sources setObject:source forKey:path];
	[self triggerEvent:@"canplaythrough" argc:0 argv:NULL];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	ended = true;
	[self triggerEvent:@"ended" argc:0 argv:NULL];
}


EJ_BIND_FUNCTION(play, ctx, argc, argv) {
	[self load];
	[source play];
	ended = false;
	return NULL;
}

EJ_BIND_FUNCTION(pause, ctx, argc, argv) {
	[source pause];
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
	return JSValueMakeNumber( ctx, [source getCurrentTime] );
}

EJ_BIND_SET(currentTime, ctx, value) {
	float time = JSValueToNumberFast(ctx, value);
	[source setCurrentTime:time];
}

EJ_BIND_GET(src, ctx) {
	return path ? NSStringToJSValue(ctx, path) : NULL;
}

EJ_BIND_SET(src, ctx, value) {
	[self setSourcePath:JSValueToNSString(ctx, value)];
}

EJ_BIND_GET(preload, ctx) {
	return NSStringToJSValue(ctx, preload);
}

EJ_BIND_SET(preload, ctx, value) {
	[preload release];
	
	preload = [JSValueToNSString(ctx, value) retain];
	if( [preload isEqualToString:@"auto"] ) {
		[self load];
	}
}

EJ_BIND_GET(ended, ctx) {
	return JSValueMakeBoolean(ctx, ended);
}

EJ_BIND_EVENT(canplaythrough);
EJ_BIND_EVENT(ended);

@end
