#import "EJBindingAdMobPage.h"

@implementation EJBindingAdMobPage


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			adUnitID = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set adUnitID");
		}
        
        loading = false;
        loadCallback = nil;
	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	interstitial.delegate = nil;
	[interstitial release];
    loadCallback = nil;
	[super dealloc];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    loading = false;
	NSLog(@"Received interstitial AD successfully");
	[self triggerEvent:@"load"];
    
    if (loadCallback){
        JSValueRef params[] = {scriptView->jsTrue};
        [scriptView invokeCallback:loadCallback thisObject:NULL argc:1 argv:params];
        JSValueUnprotect(scriptView.jsGlobalContext, loadCallback);
        loadCallback = nil;
    }

}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    loading = false;
	NSLog(@"Failed to receive interstitial AD with error: %@", [error localizedFailureReason]);
    [self triggerEvent:@"error"];

    if (loadCallback){
        JSValueRef params[] = {scriptView->jsFalse};
        [scriptView invokeCallback:loadCallback thisObject:NULL argc:1 argv:params];
        JSValueUnprotect(scriptView.jsGlobalContext, loadCallback);
        loadCallback = nil;
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
	[self triggerEvent:@"close"];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
	[self triggerEvent:@"click"];
}

- (void)createAndLoadInterstitial {
    loading = true;
    
    // Create a new GADInterstitial each time.  A GADInterstitial will only show one request in its
    // lifetime. The property will release the old one and set the new one.
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitID];
    interstitial.delegate = self;
    

	GADRequest *request = [GADRequest request];
	// Make the request for a test ad. Put in an identifier for the simulator as well as any devices
	// you want to receive test ads.
	request.testDevices = @[
	        // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
	        // the console when the app is launched.
	        kGADSimulatorID,
            @"7ab1b64b7d167bd4b5ef38c58f925092",
            @"270a3ec13074818800317013ce006923"
	    ];
    [interstitial loadRequest:request];
}

EJ_BIND_GET(isReady, ctx){
    return interstitial ? JSValueMakeBoolean(ctx, interstitial.isReady) : scriptView->jsFalse;
}

EJ_BIND_GET(adUnitID, ctx)
{
	return NSStringToJSValue(ctx, adUnitID);
}

EJ_BIND_FUNCTION(load, ctx, argc, argv)
{

    if (loadCallback){
        JSValueUnprotect(ctx, loadCallback);
    }
    loadCallback = nil;
    if (argc > 0){
        loadCallback = JSValueToObject(ctx, argv[0], NULL);
        if (loadCallback) {
            JSValueProtect(ctx, loadCallback);
        }
    }

    if (loading){
        return NULL;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.25),
        dispatch_get_main_queue(), ^{
            [self createAndLoadInterstitial];
        });

	return NULL;
}

EJ_BIND_FUNCTION(show, ctx, argc, argv)
{

	if (interstitial.isReady) {
		[interstitial presentFromRootViewController:scriptView.window.rootViewController];
        return scriptView->jsTrue;
    }
    return scriptView->jsFalse;

}



EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(close);
EJ_BIND_EVENT(click);

@end
