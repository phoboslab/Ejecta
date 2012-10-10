#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import "EJAudioSource.h"
#import "EJOpenALManager.h"
#import "EJOpenALBuffer.h"

@interface EJAudioSourceOpenAL : NSObject <EJAudioSource> {
	NSString * path;
	unsigned int sourceId;
	EJOpenALBuffer * buffer;
}

@end
