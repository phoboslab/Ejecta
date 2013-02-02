#import "EJOpenALManager.h"

@implementation EJOpenALManager
@synthesize buffers;

-(id)init {
	if( self = [super init] ) {
		// Create a non-retaining Dictionary to hold the cached buffers
		buffers = (NSMutableDictionary*)CFDictionaryCreateMutable(NULL, 8, &kCFCopyStringDictionaryKeyCallBacks, NULL);
		
		device = alcOpenDevice(NULL);
		if( device ) {
			context = alcCreateContext( device, NULL );
			alcMakeContextCurrent( context );
		}
	}
	return self;
}

- (void)dealloc {
	[buffers release];
	
	alcDestroyContext( context );
	alcCloseDevice( device );
	[super dealloc];
}

@end
