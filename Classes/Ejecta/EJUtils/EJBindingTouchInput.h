#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"

#define EJ_TOUCH_MAX_CALLBACK_PARAMS 24 // Max 8 touches, 3 args per touch
@interface EJBindingTouchInput : EJBindingEventedBase <TouchDelegate>

- (void)triggerEvent:(NSString *)name withTouches:(NSSet *)touches;

@end
