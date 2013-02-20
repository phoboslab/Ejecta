#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"

#import "EJAudioSourceOpenAL.h"
#import "EJAudioSourceAVAudio.h"

// Max file size of audio effects using OpenAL; beyond that, the AVAudioPlayer is used
#define EJ_AUDIO_OPENAL_MAX_SIZE 512 * 1024 // 512kb


typedef enum {
	kEJAudioPreloadNone,
	kEJAudioPreloadMetadata,
	kEJAudioPreloadAuto
} EJAudioPreload;

@interface EJBindingAudio : EJBindingEventedBase <EJAudioSourceDelegate> {
	NSString *path;
	EJAudioPreload preload;
	NSObject<EJAudioSource> *source;
	
	BOOL loop, ended, paused;
	BOOL loading, playAfterLoad;
	float volume;
	NSOperation *loadCallback;
}

- (void)load;
- (void)setSourcePath:(NSString *)pathp;

@property (nonatomic) BOOL loop;
@property (nonatomic) BOOL ended;
@property (nonatomic) float volume;
@property (nonatomic, retain) NSString *path;
@property (nonatomic) EJAudioPreload preload;

@end
