// EJBindingGlobalUtils hosts various functions and properties that are exposed
// to JavaScript. An instance of this class is created by the Ejecta.js at
// window.ejecta.

// Some of the native functions in this class serve only as the "raw"
// implementation and should not be called directly in JavaScript. E.g. the
// log() function only accepts one argument and assumes it's a string. A small
// shim in the Ejecta.js provides the usual console.log() semantics and calls
// the native log() function internally.

// Functionality includes: timers, intervals, userAgent properties, screen
// properties (width, height, pixelRatio), orientation and onLine properties.
// This class also provides the ejecta.include() function to load further
// .js files.

#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"
#import "EJFont.h"
#import "EJTimer.h"

typedef enum {
	kEJCoreAudioSessionAmbient,
	kEJCoreAudioSessionSoloAmbient,
	kEJCoreAudioSessionPlayback
} EJCoreAudioSession;


@interface EJBindingGlobalUtils : EJBindingBase {
	NSString *deviceName;
	EJCoreAudioSession audioSession;
}

@property (readwrite, nonatomic) EJCoreAudioSession audioSession;

@end
