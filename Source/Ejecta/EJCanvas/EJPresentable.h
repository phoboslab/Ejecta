// The Presentable protocol is implemented Canvas Contexts that are directly
// rendered to the screen, instead of to an offscreen texture.

#import <Foundation/Foundation.h>

@protocol EJPresentable

- (void)present;
- (void)finish;

@property (nonatomic) CGRect style;
@property (nonatomic, readonly) UIView *view;

@end
