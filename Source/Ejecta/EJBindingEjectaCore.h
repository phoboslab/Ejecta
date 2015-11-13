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
}

@property (readwrite, nonatomic) EJCoreAudioSession audioSession;

@end
