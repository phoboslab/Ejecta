#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"
#import "EJFont.h"

typedef enum {
	kEJCoreAudioSessionAmbient,
	kEJCoreAudioSessionSoloAmbient,
	kEJCoreAudioSessionPlayback
} EJCoreAudioSession;

@interface EJBindingEjectaCore : EJBindingBase {
	NSString *deviceName;
	EJCoreAudioSession audioSession;
	NSTimeInterval baseTime;
    
    CADisplayLink *displayLink;
    NSPointerArray *animationCallbacks[2];
    NSUInteger animationCallbackBuffer;
    BOOL runningDisplayLinkUpdate;
}

@property (readwrite, nonatomic) EJCoreAudioSession audioSession;

@end
