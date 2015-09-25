
#import "EJBindingAlertView.h"

@implementation EJBindingAlertView


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		NSString *title = JSValueToNSString(ctx, argv[0]);
		NSString *message = JSValueToNSString(ctx, argv[1]);
		NSString *cancelButtonTitle = JSValueToNSString(ctx, argv[2]);
		alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
		for (int i = 3; i < argc; i++) {
			[alertView addButtonWithTitle:JSValueToNSString(ctx, argv[i])];
		}
	}
	return self;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    JSValueRef params[] = {JSValueMakeNumber(scriptView.jsGlobalContext, buttonIndex)};
    [self triggerEvent:@"click" argc:1 argv:params];
}

-(void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{

}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	JSValueRef params[] = {JSValueMakeNumber(scriptView.jsGlobalContext, buttonIndex)};
	[self triggerEvent:@"dismiss" argc:1 argv:params];
}

- (void) alertViewCancel:(UIAlertView *)alertView {
    [self triggerEvent:@"cancel" argc:0 argv:NULL];
}

- (void)dealloc {
    [alertView release];
    [super dealloc];
}

EJ_BIND_EVENT(click);
EJ_BIND_EVENT(dismiss);
EJ_BIND_EVENT(cancel);

EJ_BIND_FUNCTION(show, ctx, argc, argv)
{
    [alertView show];
    return NULL;
}


@end
