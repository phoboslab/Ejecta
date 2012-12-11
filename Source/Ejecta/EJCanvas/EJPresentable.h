#import <Foundation/Foundation.h>

typedef enum {
	kEJScalingModeNone,
	kEJScalingModeFitWidth,
	kEJScalingModeFitHeight
} EJScalingMode;

@protocol EJPresentable

- (void)present;
- (void)finish;

@property (nonatomic) EJScalingMode scalingMode;

@end
