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
	}
	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	isReady = NO;
}

- (void)dealloc {
	interstitial.delegate = nil;
	[interstitial release];
	[super dealloc];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
	isReady = YES;
	[self triggerEvent:@"load"];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
	isReady = NO;
	NSLog(@"error %@", [error localizedDescription]);
	[self triggerEvent:@"error"];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
	[self triggerEvent:@"close"];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
	[self triggerEvent:@"click"];
}

- (GADRequest *)request {
	GADRequest *request = [GADRequest request];
	// Make the request for a test ad. Put in an identifier for the simulator as well as any devices
	// you want to receive test ads.
	request.testDevices = @[
	        // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
	        // the console when the app is launched.
	        GAD_SIMULATOR_ID
	    ];
	return request;
}

EJ_BIND_GET(isReady, ctx)
{
	return JSValueMakeBoolean(ctx, isReady);
}

EJ_BIND_GET(adUnitID, ctx)
{
	return NSStringToJSValue(ctx, adUnitID);
}

EJ_BIND_FUNCTION(load, ctx, argc, argv)
{
	isReady = NO;

	// Create a new GADInterstitial each time.  A GADInterstitial will only show one request in its
	// lifetime. The property will release the old one and set the new one.
	interstitial = [[GADInterstitial alloc] init];
	interstitial.delegate = self;
	interstitial.adUnitID = adUnitID;
	[interstitial loadRequest:[self request]];
	return NULL;
}

EJ_BIND_FUNCTION(show, ctx, argc, argv)
{
	if (isReady) {
		[interstitial presentFromRootViewController:scriptView.window.rootViewController];
	}
	return NULL;
}


EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(close);
EJ_BIND_EVENT(click);

@end
