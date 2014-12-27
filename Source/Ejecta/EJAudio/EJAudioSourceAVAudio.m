#import "EJAudioSourceAVAudio.h"


@implementation EJAudioSourceAVAudio

@synthesize delegate;

- (id)initWithPath:(NSString *)pathp {
	if( self = [super init] ) {
		path = [pathp retain];

		interceptorManager = [[EJInterceptorManager instance] retain];

		NSMutableData *data = [NSMutableData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
		if( !data ) {
			NSLog(@"Error Loading audio %@ - not found.", path);
			return NULL;
		}
		[interceptorManager interceptData:AFTER_LOAD_AUDIO data:data];
		player = [[AVAudioPlayer alloc] initWithData:data error:nil];
		player.delegate = self;
	}
	return self;
}

- (void)dealloc {
	[path release];
	[player release];
	[interceptorManager release];
	[super dealloc];
}

- (void)play {
	[player play];
}

- (void)pause {
	[player pause];
}

- (void)setLooping:(BOOL)loop {
	player.numberOfLoops = loop ? -1 : 0;
}

- (void)setVolume:(float)volume {
	player.volume = volume;
}

- (void)setPlaybackRate:(float)playbackRate {
	player.enableRate = YES;
	player.rate = playbackRate;
}

- (float)currentTime {
	return player.currentTime;
}

- (void)setCurrentTime:(float)time {
	player.currentTime = time;
}

- (float)duration {
	return player.duration;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[delegate sourceDidFinishPlaying:self];
}

@end
