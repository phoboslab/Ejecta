#import "EJAudioSourceAVAudio.h"


@implementation EJAudioSourceAVAudio

@synthesize delegate;

- (id)initWithPath:(NSString *)pathp {
	if( self = [super init] ) {
		path = [pathp retain];
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
	}
	return self;
}

- (void)dealloc {
	[path release];
	[player release];
	
	[super dealloc];
}

- (void)setDelegate:(NSObject<AVAudioPlayerDelegate> *)delegatep {
	player.delegate = delegatep;
}

- (NSObject<AVAudioPlayerDelegate> *)delegate {
	return player.delegate;
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

- (float)getCurrentTime {
	return player.currentTime;
}

- (void)setCurrentTime:(float)time {
	player.currentTime = time;
}

@end
