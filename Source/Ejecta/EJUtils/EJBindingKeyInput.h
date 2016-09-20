// EJBindingKeyInput allows you to bring up and control the on-screen keyboard
// and prompt the user for text.

// The implementation somewhat mimics an invisible <input/> field in the browser
// - you can .focus() and .blur() it and read the .value. The Ejecta.js also
// sets this up so that you can instantiate this class via
// document.createElement('input');

#import "EJBindingEventedBase.h"

#pragma mark - EJKeyInputDelegate

@class EJKeyInputResponder;
@protocol EJKeyInputDelegate <NSObject>
- (UIResponder*)nextResponderForKeyInput:(EJKeyInputResponder*)keyInput;
@optional
- (void)keyInput:(EJKeyInputResponder*)keyInput insertText:(NSString*)text;
- (void)keyInputDidDeleteBackwards:(EJKeyInputResponder*)keyInput;
- (void)keyInputDidResignFirstResponderStatus:(EJKeyInputResponder*)keyInput;
- (void)keyInputDidBecomeFirstResponder:(EJKeyInputResponder*)keyInput;
- (BOOL)hasText;
@end

@interface EJKeyInputResponder : UIResponder <UIKeyInput>
@property (nonatomic, unsafe_unretained) NSObject <EJKeyInputDelegate>*delegate;
@end

#pragma mark -
#pragma mark EJBindingKeyInput

@interface EJBindingKeyInput : EJBindingEventedBase <EJKeyInputDelegate> 

@end
