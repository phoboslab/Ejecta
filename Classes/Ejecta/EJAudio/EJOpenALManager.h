#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface EJOpenALManager : NSObject {
	ALCcontext * context;
	ALCdevice * device;
	NSMutableDictionary *sources;
}

+ (EJOpenALManager *)instance;

@property (readonly, nonatomic) NSMutableDictionary * sources;

@end
