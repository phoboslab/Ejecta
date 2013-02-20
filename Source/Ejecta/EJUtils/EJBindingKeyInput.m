
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
    if ([self.delegate respondsToSelector:@selector(keyInput:insertText:)]) {
        [self.delegate keyInput:self insertText:text];
    }
}

- (BOOL)hasText{
    return YES;
}

@end

@interface EJBindingKeyInput ()
@property (nonatomic, strong) EJKeyInputResponder *inputController;
@property (nonatomic, assign) BOOL sendChunkedInput;
@end

@implementation EJBindingKeyInput

static NSString *keyInputEvent = @"keyInput";

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
    self.inputController = [[EJKeyInputResponder alloc] init];
    self.inputController.delegate = self;
    self.sendChunkedInput = YES;
}

- (void)dealloc
{
    [self.inputController release];
    [super dealloc];
}

//TODO: maybe accept a context in which it becomes the first responder,
//in which case when key input occurs, we pass back the context/object so that JS can identify
EJ_BIND_FUNCTION(open, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputController becomeFirstResponder]);
}

EJ_BIND_FUNCTION(close, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputController resignFirstResponder]);
}

EJ_BIND_FUNCTION(isOpen, ctx, argc, argv){
    return JSValueMakeBoolean(ctx, [self.inputController isFirstResponder]);
}

//If set to YES
EJ_BIND_SET(sendChunkedInput, ctx, value){
    self.sendChunkedInput = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(sendChunkedInput, ctx){
    return JSValueMakeBoolean(ctx, self.sendChunkedInput);
}

//When keyboard opens or closes, send message 'keyboardToggled'
//true if open false is closed

#pragma mark -
#pragma mark EJKeyInput delegate

- (UIResponder*)nextResponderForKeyInput:(EJKeyInputResponder *)keyInput{
    return scriptView;
}

- (void)keyInput:(EJKeyInputResponder *)keyInput insertText:(NSString *)text
{
    if (self.sendChunkedInput) {
        JSValueRef params[] = { NSStringToJSValue(scriptView.jsGlobalContext, text) };
        [self triggerEvent:keyInputEvent argc:1 argv:params];
    } else {
        for (int i = 0; i < [text length]; i++){
            JSValueRef params[] = { NSStringToJSValue(scriptView.jsGlobalContext, [NSString stringWithCharacters:[text characterAtIndex:i] length:1]) };
            [self triggerEvent:keyInputEvent argc:1 argv:params];
        }
    }
}

- (void)keyInputDidDeleteBackwards:(EJKeyInputResponder *)keyInput{
    [self triggerEvent:@"delete" argc:0 argv:NULL];
}

@end
