// The OpenALManager keeps track of the global OpenAL context and holds a
// dictionary of all active buffers.

#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface EJSharedOpenALManager : NSObject {
	ALCcontext *context;
	ALCdevice *device;
	NSMutableDictionary *buffers;
}

+ (EJSharedOpenALManager *)instance;
- (void)beginInterruption;
- (void)endInterruption;

@property (readonly, nonatomic) NSMutableDictionary *buffers;

@end
