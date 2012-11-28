#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"

#define EJ_TOUCH_INPUT_MAX_TOUCHES 5

@interface EJBindingTouchInput : EJBindingEventedBase <EJTouchDelegate> {
	JSStringRef jsLengthName;
	JSStringRef jsIdentifierName, jsPageXName, jsPageYName, jsClientXName, jsClientYName;
	JSObjectRef jsAllTouches, jsChangedTouches;
	JSObjectRef jsTouchesPool[EJ_TOUCH_INPUT_MAX_TOUCHES];
}

- (void)triggerEvent:(NSString *)name withChangedTouches:(NSSet *)changed allTouches:(NSSet *)all;

@end
