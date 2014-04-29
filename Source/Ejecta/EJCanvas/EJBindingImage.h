#import "EJBindingEventedBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"

@interface EJBindingImage : EJBindingEventedBase <EJDrawable> {
	EJTexture *texture;
	NSString *path;
	BOOL loading;
	
	BOOL lazyLoad;					// create texture from path blocking main thread on first use
	
	BOOL sizeKnown;					// cache the size of the image so the width/height accessors
									// don't need to have the texture loaded even if it was transferred
	short knownWidth;
	short knownHeight;
	
	NSOperation *loadCallback;
}

@property (readonly, nonatomic) EJTexture *texture;

- (void)setTexture:(EJTexture *)texturep path:(NSString *)pathp;

@end
