// This class provides the `touchstart`, `touchend` and `touchmove` events to
// JavaScript.

// On instantination, this class installs itself as the TouchDelegate on the
// owning EJScriptView. The EJScriptView (a UIView subclass) gets the Touch
// Events from the OS and just hands them down to this class.

// For performance reasons, this class maintains a pool of `Touch` objects
// and only changes coordinates and time values whenever a touch happens. This
// is slightly faster than constructing new objects for each touch event.

#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"
#import "EJJavaScriptView.h"

#define EJ_TOUCH_INPUT_MAX_TOUCHES 16

@interface EJBindingTouchInput : EJBindingEventedBase <EJTouchDelegate> {
	JSStringRef jsLengthName;
	JSStringRef jsTargetName, jsIdentifierName, jsPageXName, jsPageYName, jsClientXName, jsClientYName;
	JSObjectRef jsRemainingTouches, jsChangedTouches;
	JSObjectRef jsTouchesPool[EJ_TOUCH_INPUT_MAX_TOUCHES];
	JSValueRef jsTouchTarget;
	NSUInteger touchesInPool;
}

- (void)triggerEvent:(NSString *)name timestamp:(NSTimeInterval)timestamp
	all:(NSSet *)all changed:(NSSet *)changed remaining:(NSSet *)remaining;

@end
