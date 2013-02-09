#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface EJOpenALManager : NSObject {
	ALCcontext *context;
	ALCdevice *device;
	NSMutableDictionary *buffers;
}

@property (readonly, nonatomic) NSMutableDictionary *buffers;

@end
