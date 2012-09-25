#import "EJBindingBase.h"
#import "EJImageData.h"

@interface EJBindingImageData : EJBindingBase {
	EJImageData * imageData;
	JSObjectRef dataArray;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj imageData:(EJImageData *)imageDatap;

@property (readonly, nonatomic) EJImageData * imageData;

@end
