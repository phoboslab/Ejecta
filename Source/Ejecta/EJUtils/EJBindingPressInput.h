#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"
#import "EJJavaScriptView.h"

#define EJ_PRESS_INPUT_MAX_PRESSES 16

@interface EJBindingPressInput : EJBindingEventedBase <EJPressDelegate> {
    JSStringRef jsLengthName;
    JSStringRef jsPressTypeName;
    JSObjectRef jsPresses;
    JSObjectRef jsPressesPool[EJ_PRESS_INPUT_MAX_PRESSES];
    NSUInteger pressesInPool;
}

- (void)triggerEvent:(NSString *)name presses:(NSSet *)presses;

@end
