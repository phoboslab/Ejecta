// The binding for the ImageData.

// Accessing the .data property in JavaScript will lazily unpremultiply the the
// pixel data and fill a Uint8Array.

// Accesing the .imageData property in native code will lazily load the pixel
// data from the Uint8Array and premultiply it again. 

#import "EJBindingBase.h"
#import "EJImageData.h"
#import "EJDrawable.h"

@interface EJBindingImageData : EJBindingBase <EJDrawable> {
	EJImageData *imageData;
	JSObjectRef dataArray;
}

- (id)initWithImageData:(EJImageData *)data;

@property (readonly, nonatomic) EJImageData *imageData;
@property (readonly, nonatomic) EJTexture *texture;

@end
