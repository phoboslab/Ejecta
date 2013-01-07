#import <Foundation/Foundation.h>
#import "EJTexture.h"

typedef enum {
	kEJCanvasPatternNoRepeat = 0,
	kEJCanvasPatternRepeatX = 1,
	kEJCanvasPatternRepeatY = 2,
	kEJCanvasPatternRepeat = 1 | 2
} EJCanvasPatternRepeat;

@interface EJCanvasPattern : NSObject {
	EJTexture * texture;
	EJCanvasPatternRepeat repeat;
}

- (id)initWithTexture:(EJTexture *)texturep repeat:(EJCanvasPatternRepeat)repeatp;

@property (readonly, nonatomic) EJTexture * texture;
@property (readonly, nonatomic) EJCanvasPatternRepeat repeat;

@end
