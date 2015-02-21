
#import "EJBindingAlertView.h"

@implementation EJBindingAlertView

EJ_BIND_EVENT(didDismiss);

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		NSString *title = JSValueToNSString(ctx, argv[0]);
		NSString *message = JSValueToNSString(ctx, argv[1]);
		NSString *cancelButtonTitle = JSValueToNSString(ctx, argv[2]);
		alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
		for (int i = 3; i < argc; i++) {
			[alertView addButtonWithTitle:JSValueToNSString(ctx, argv[i])];
		}
		[alertView show];
	}
	return self;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	JSValueRef params[] = {JSValueMakeNumber(scriptView.jsGlobalContext, buttonIndex)};
	[self triggerEvent:@"didDismiss" argc:1 argv:params];
}

@end
