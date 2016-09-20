// Provides the Image Element to JavaScript. An Image instance has the `.src`
// path of the image, a `width` and `height` and a loading callback. The actual
// pixel data of the image is provided by EJTexture.

#import "EJBindingEventedBase.h"
#import "EJTexture.h"
#import "EJDrawable.h"

@interface EJBindingImage : EJBindingEventedBase <EJDrawable> {
	EJTexture *texture;
	NSString *path;
	BOOL loading;	
	NSOperation *loadCallback;
}

@property (readonly, nonatomic) EJTexture *texture;

- (void)setTexture:(EJTexture *)texturep path:(NSString *)pathp;

@end
