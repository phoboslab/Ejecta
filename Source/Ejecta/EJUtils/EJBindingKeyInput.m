
#import "EJBindingKeyInput.h"
#import "EJJavaScriptView.h"

@implementation EJKeyInputResponder

- (UIResponder*)nextResponder{
    return [self.delegate nextResponderForKeyInput:self];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)deleteBackward{
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyInputDidDeleteBackwards:)]) {
        [self.delegate keyInputDidDeleteBackwards:self];
    }
}

- (void)insertText:(NSString *)text{
    for (int i = 0; i < [text length]; i++){
        if (self.delegate && [self.delegate respondsToSelector:@selector(keyInput:keyPressed:)]) {
            [self.delegate keyInput:self keyPressed:[text characterAtIndex:i]];
        }
    }
}

- (BOOL)hasText{
    return YES;
}

@end

@interface EJBindingKeyInput ()
@property (nonatomic, strong) EJKeyInputResponder *inputController;
@end

@implementation EJBindingKeyInput

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
    self.inputController = [[EJKeyInputResponder alloc] init];
    self.inputController.delegate = self;
}

- (void)dealloc
{
    [self.inputController release];
    [super dealloc];
}

//TODO: maybe accept a context in which it becomes the first responder,
//in which case when key input occurs, we pass back the context/object so that JS can identify
EJ_BIND_FUNCTION(becomeFirstResponder, ctx, argc, argv){    
    return JSValueMakeBoolean(ctx, [self.inputController becomeFirstResponder]);
}

EJ_BIND_FUNCTION(resignFirstResponder, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputController resignFirstResponder]);
}

EJ_BIND_FUNCTION(isFirstResponder, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputController isFirstResponder]);
}

#pragma mark -
#pragma mark EJKeyInput delegate

- (UIResponder*)nextResponderForKeyInput:(EJKeyInputResponder *)keyInput{
    return scriptView;
}

- (void)keyInput:(EJKeyInputResponder *)keyInput keyPressed:(unichar)keyChar{
    JSValueRef params[] = { JSValueMakeNumber(scriptView.jsGlobalContext, keyChar) };
    [self triggerEvent:@"keyPressed" argc:1 argv:params];
}

- (void)keyInputDidDeleteBackwards:(EJKeyInputResponder *)keyInput{
    [self triggerEvent:@"deleteBackward" argc:0 argv:NULL];
}

@end
