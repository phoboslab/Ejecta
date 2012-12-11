#import <Foundation/Foundation.h>

typedef enum {
	kEJScalingModeNone,
	kEJScalingModeFitWidth,
	kEJScalingModeFitHeight
} EJScalingMode;

@protocol EJCanvasContextScreen

- (void)present;
- (void)finish;

@property (nonatomic) EJScalingMode scalingMode;

@end
