// An Audio Source backed by the iOS native AVAudioPlayer. An instance of this
// class can be used as the source of a EJBindingAudio element.

// AVAudioPlayer supports streaming from a file, so that this type of source
// does not need much memory. However, starting playback can have a bit of lag.

// Typically, you want this type of Audio Source for music or background ambient
// sounds, but not for sound effects that need tight timing.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "EJAudioSource.h"

@interface EJAudioSourceAVAudio : NSObject <EJAudioSource, AVAudioPlayerDelegate> {
	NSString *path;
	AVAudioPlayer *player;
	NSObject<EJAudioSourceDelegate> *delegate;
}

@property (nonatomic) float currentTime;
@property (nonatomic) float duration;
@property (nonatomic, assign) NSObject<EJAudioSourceDelegate> *delegate;

@end
