#import "EJSharedTextureCache.h"

@implementation EJSharedTextureCache
@synthesize textures;

static EJSharedTextureCache *sharedTextureCache;

+ (EJSharedTextureCache *)instance {
	if( !sharedTextureCache ) {
		sharedTextureCache = [[[EJSharedTextureCache alloc] init] autorelease];
	}
    return sharedTextureCache;
}

- (id)init {
	if( self = [super init] ) {
		// Create a non-retaining Dictionary to hold the cached textures
		textures = (NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 8, &kCFCopyStringDictionaryKeyCallBacks, NULL);
	}
	return self;
}

- (void)dealloc {
	sharedTextureCache = nil;
	[textures release];
	[super dealloc];
}

@end
