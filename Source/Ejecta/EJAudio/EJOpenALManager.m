#import "EJOpenALManager.h"

@implementation EJOpenALManager
@synthesize buffers;

-(id)init {
	if( self = [super init] ) {
		// Create a non-retaining Dictionary to hold the cached buffers
		buffers = (NSMutableDictionary*)CFBridgingRelease(CFDictionaryCreateMutable(NULL, 8, &kCFCopyStringDictionaryKeyCallBacks, NULL));
		
		device = alcOpenDevice(NULL);
		if( device ) {
			context = alcCreateContext( device, NULL );
			alcMakeContextCurrent( context );
		}
	}
	return self;
}

- (void)dealloc {
	
	alcDestroyContext( context );
	alcCloseDevice( device );
}

@end
