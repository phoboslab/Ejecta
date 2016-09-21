// An Audio Source backed by OpenAL. Several instances of AudioSourceOpenAL
// may share the same underlying OpenALBuffer instance.

// OpenAL sources are loaded fully into memory but provide lower latency
// and "rapid fire" playback in contrast to AVAudio sources. 

#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import "EJAudioSource.h"
#import "EJSharedOpenALManager.h"
#import "EJOpenALBuffer.h"

@interface EJAudioSourceOpenAL : NSObject <EJAudioSource> {
	NSString *path;
	unsigned int sourceId;
	EJOpenALBuffer *buffer;
	BOOL looping;
	
	NSTimer *endTimer;
	NSObject<EJAudioSourceDelegate> *delegate;
}

@property (nonatomic) float currentTime;
@property (nonatomic) float duration;
@property (nonatomic, assign) NSObject<EJAudioSourceDelegate> *delegate;

@end
