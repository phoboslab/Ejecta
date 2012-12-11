#import "EJBindingBase.h"
#import "EJImageData.h"

@interface EJBindingImageData : EJBindingBase {
	EJImageData * imageData;
	JSObjectRef dataArray;
}

- (id)initWithImageData:(EJImageData *)data;

@property (readonly, nonatomic) EJImageData * imageData;

@end
