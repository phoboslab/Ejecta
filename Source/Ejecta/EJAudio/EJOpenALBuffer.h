// An OpenAL audio buffer that may be used by several OpenAL Audio sources.
// This class takes care of loading an audio file from disk and decoding it
// into a memory buffer.

#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface EJOpenALBuffer : NSObject {
	unsigned int bufferId;
	ALenum format;
	ALsizei size;
	ALsizei sampleRate;
	
	NSString *path;
	float duration;
}

+ (id)cachedBufferWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)pathp;
- (void*)getAudioDataWithURL:(NSURL *)url;

@property (readonly) unsigned int bufferId;
@property (readonly) float duration;

@end
