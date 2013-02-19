
#import "EJBindingEventedBase.h"

#pragma mark - EJKeyInputDelegate

@class EJKeyInputResponder;
@protocol EJKeyInputDelegate <NSObject>
- (UIResponder*)nextResponderForKeyInput:(EJKeyInputResponder*)keyInput;
@optional
- (void)keyInput:(EJKeyInputResponder*)keyInput keyPressed:(unichar)keyChar;
- (void)keyInputDidDeleteBackwards:(EJKeyInputResponder*)keyInput;
@end

@interface EJKeyInputResponder : UIResponder <UIKeyInput>
@property (nonatomic, unsafe_unretained) NSObject <EJKeyInputDelegate>*delegate;
@end

#pragma mark -
#pragma mark EJBindingKeyInput

@interface EJBindingKeyInput : EJBindingEventedBase <EJKeyInputDelegate> 

@end
