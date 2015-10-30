#import "EJBindingVungle.h"

@implementation EJBindingVungle


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			appID = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set appID");
            return self;
		}
        
        loading = false;
        loadCallback = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            sdk = [VungleSDK sharedSDK];
            [sdk setDelegate:self];
            [sdk startWithAppId:appID];
        }];

	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	sdk.delegate = nil;
	[sdk release];
    loadCallback = nil;
	[super dealloc];
}

-(void)vungleSDKwillShowAd {
    NSLog(@"vungleSDKwillShowAd");
    [self triggerEvent:@"beforeShow"];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    NSLog(@"vungleSDKwillCloseAdWithViewInfo");
    
    [viewInfo setValue:willPresentProductSheet forKey:@"willPresentProductSheet"];
    JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext, viewInfo);
    JSValueRef params[] = { jsViewInfo };
    [self triggerEvent:@"close" argc:1 argv:params];
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    NSLog(@"vungleSDKwillCloseProductSheet");
    [self triggerEvent:@"closeProductSheet"];
}


EJ_BIND_GET(appID, ctx)
{
	return NSStringToJSValue(ctx, appID);
}


EJ_BIND_GET(muted, ctx)
{
    return NSStringToJSValue(ctx, sdk.muted);
}

EJ_BIND_SET(muted, ctx, value)
{
    sdk.muted = JSValueToBoolean(ctx, value);
}


EJ_BIND_GET(isReady, ctx)
{
    return JSValueMakeBoolean(ctx, sdk.isAdPlayable);
}


EJ_BIND_FUNCTION(show, ctx, argc, argv)
{

    NSDictionary* options = @{VunglePlayAdOptionKeyIncentivized: @YES};
                              
    NSError *error;
    [sdk playAd:scriptView.window.rootViewController withOptions:options error:&error];

    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
        [self triggerEvent:@"error"];
    }
    
    return scriptView->jsTrue;

}



EJ_BIND_EVENT(beforeShow);
EJ_BIND_EVENT(close);
EJ_BIND_EVENT(closeProductSheet);
EJ_BIND_EVENT(error);


@end
