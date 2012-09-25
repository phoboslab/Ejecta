#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"

#import "EJOpenALManager.h"
#import "EJAudioSourceOpenAL.h"
#import "EJAudioSourceAVAudio.h"

// Max file size of audio effects using OpenAL; beyond that, the AVAudioPlayer is used
#define EJ_AUDIO_OPENAL_MAX_SIZE 512 * 1024 // 512kb

@interface EJBindingAudio : EJBindingEventedBase <AVAudioPlayerDelegate> {
	NSString * path;
	NSString * preload;
	NSObject<EJAudioSource> * source;
	
	BOOL loop, ended;
	float volume;
}

- (void)load;
- (void)releaseSource;
- (void)setSourcePath:(NSString *)pathp;

@end
