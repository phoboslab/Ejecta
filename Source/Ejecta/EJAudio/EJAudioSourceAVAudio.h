#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "EJAudioSource.h"

#import "EJInterceptorManager.h"

@interface EJAudioSourceAVAudio : NSObject <EJAudioSource, AVAudioPlayerDelegate> {
	NSString *path;
	AVAudioPlayer *player;
	NSObject<EJAudioSourceDelegate> *delegate;
    
    EJInterceptorManager *interceptorManager;
}

@property (nonatomic) float currentTime;
@property (nonatomic) float duration;
@property (nonatomic, assign) NSObject<EJAudioSourceDelegate> *delegate;

@end
