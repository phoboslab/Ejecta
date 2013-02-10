#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "EJAudioSource.h"

@interface EJAudioSourceAVAudio : NSObject <EJAudioSource, AVAudioPlayerDelegate> {
	NSString *path;
	AVAudioPlayer *player;
	NSObject<EJAudioSourceDelegate> *__weak delegate;
}

@property (nonatomic) float currentTime;
@property (nonatomic) float duration;
@property (nonatomic, weak) NSObject<EJAudioSourceDelegate> *delegate;

@end
