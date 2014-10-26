#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"
#import "EJFont.h"

enum {
	kEJCoreAlertViewOpenURL = 1,
	kEJCoreAlertViewGetText
};

typedef enum {
	kEJCoreAudioSessionAmbient,
	kEJCoreAudioSessionSoloAmbient,
	kEJCoreAudioSessionPlayback
} EJCoreAudioSession;

@interface EJBindingEjectaCore : EJBindingBase {
	NSString *urlToOpen;
	JSObjectRef getTextCallback;
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
