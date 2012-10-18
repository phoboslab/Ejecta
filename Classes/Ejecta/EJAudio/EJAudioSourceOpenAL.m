#import "EJAudioSourceOpenAL.h"
#import "EJOpenALManager.h"

@implementation EJAudioSourceOpenAL


- (id)initWithPath:(NSString *)pathp {
	if( self = [super init] ) {
		path = [pathp retain];
		
		buffer = [[EJOpenALManager instance].buffers objectForKey:path];
		if( buffer ) {
			[buffer retain];
		}
		else {
			buffer = [[EJOpenALBuffer alloc] initWithPath:path];
			[[EJOpenALManager instance].buffers setObject:buffer forKey:path];
		}
		
		alGenSources(1, &sourceId); 
		alSourcei(sourceId, AL_BUFFER, buffer.bufferId);
		alSourcef(sourceId, AL_PITCH, 1.0f);
		alSourcef(sourceId, AL_GAIN, 1.0f);
	}
	return self;
}

- (void)dealloc {
	// If the retainCount is 2, only this instance and the .buffers dictionary
	// still retain the source - so remove it from the dict and delete it completely
	if( [buffer retainCount] == 2 ) {
		[[EJOpenALManager instance].buffers removeObjectForKey:path];
	}
	[buffer release];
	[path release];
	
	if( sourceId ) {
		alDeleteSources(1, &sourceId);
	}
	
	[super dealloc];
}

- (void)play {
	alSourcePlay( sourceId );
}

- (void)pause {
	alSourceStop( sourceId );
}

- (void)setLooping:(BOOL)loop {
	alSourcei( sourceId, AL_LOOPING, loop ? AL_TRUE : AL_FALSE );
}

- (void)setVolume:(float)volume {
	alSourcef( sourceId, AL_GAIN, volume );
}

- (float)getCurrentTime {
	float time;
	alGetSourcef( sourceId, AL_SEC_OFFSET,  &time );
	return time;
}

- (void)setCurrentTime:(float)time {
	alSourcef( sourceId, AL_SEC_OFFSET,  time );
}

@end
