#import <Foundation/Foundation.h>

typedef enum {
	kEJScalingModeNone,
	kEJScalingModeFit,
	kEJScalingModeZoom,
	// TODO: implement a scaling mode that doesn't preserve aspect ratio
	// and just stretches; needs support for touch input as well
} EJScalingMode;

@protocol EJPresentable

- (void)present;
- (void)finish;

@property (nonatomic) EJScalingMode scalingMode;

@end
