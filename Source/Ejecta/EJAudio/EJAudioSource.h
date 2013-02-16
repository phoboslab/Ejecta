#import <UIKit/UIKit.h>

@protocol EJAudioSourceDelegate;
@protocol EJAudioSource

- (id)initWithPath:(NSString *)path;
- (void)play;
- (void)pause;
- (void)setLooping:(BOOL)loop;
- (void)setVolume:(float)volume;

@property (nonatomic) float duration;
@property (nonatomic) float currentTime;
@property (nonatomic, assign) NSObject<EJAudioSourceDelegate> *delegate;

@end

@protocol EJAudioSourceDelegate
- (void)sourceDidFinishPlaying:(NSObject<EJAudioSource> *)source;
@end
