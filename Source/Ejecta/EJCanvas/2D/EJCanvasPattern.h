#import <Foundation/Foundation.h>
#import "EJTexture.h"
#import "EJCanvasContext2D.h"

typedef enum {
	kEJCanvasPatternNoRepeat = 0,
	kEJCanvasPatternRepeatX = 1,
	kEJCanvasPatternRepeatY = 2,
	kEJCanvasPatternRepeat = 1 | 2
} EJCanvasPatternRepeat;

@interface EJCanvasPattern : NSObject <EJFillable> {
	EJTexture *__weak texture;
	EJCanvasPatternRepeat repeat;
}

- (id)initWithTexture:(EJTexture *)texturep repeat:(EJCanvasPatternRepeat)repeatp;

@property (weak, readonly, nonatomic) EJTexture *texture;
@property (readonly, nonatomic) EJCanvasPatternRepeat repeat;

@end
