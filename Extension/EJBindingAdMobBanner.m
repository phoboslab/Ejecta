
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADRequest.h>

#import "EJBindingAdMobBanner.h"


@implementation EJBindingAdMobBanner



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
    
	wantToShow = NO;
	isReady = NO;
	x = 0;
	y = 0;
    banner = nil;

}

- (void)initBannerWithView:(EJJavaScriptView *)view {

    banner = [[GADBannerView alloc] initWithFrame:CGRectZero];
    banner.adUnitID = adUnitID;
    banner.delegate = self;
    banner.hidden = YES;
    banner.rootViewController = scriptView.window.rootViewController;

    [scriptView addSubview:banner];
}


- (void)dealloc {
	isReady = NO;
	banner.rootViewController = nil;
    banner.delegate = nil;
    [banner release];
    loadCallback = nil;
	[super dealloc];
}

- (CGSize)getSize {
	GADAdSize adSize;
	switch (self.bannerType) {
		case 0:
			adSize = kGADAdSizeBanner;
			break;

		case 1:
			adSize = kGADAdSizeMediumRectangle;
			break;

		case 2:
			adSize = kGADAdSizeFullBanner;
			break;

		case 3:
			adSize = kGADAdSizeLeaderboard;
			break;

		case 4:
			adSize = kGADAdSizeSkyscraper;
			break;

		case 5:
			adSize = kGADAdSizeSmartBannerPortrait;
			break;

		case 6:
			adSize = kGADAdSizeSmartBannerLandscape;
			break;

		default:
			adSize = kGADAdSizeInvalid;
			break;
	}

	return CGSizeFromGADAdSize(adSize);
}

- (void)doLayout {

    if (!banner){
        [self initBannerWithView:scriptView];
    }

	CGSize size = [self getSize];
	width = size.width;
	height = size.height;
	[banner setFrame:CGRectMake(x, y, width, height)];
}

- (void)requestBanner {

    loading = true;
    isReady = NO;

	GADRequest *request = [GADRequest request];

	// Make the request for a test ad. Put in an identifier for the simulator as well as any devices
	// you want to receive test ads.
	request.testDevices = @[
	        kGADSimulatorID,
            @"7ab1b64b7d167bd4b5ef38c58f925092"
	    ];

    [banner loadRequest:request];
}

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    loading = false;
    isReady = YES;
	NSLog(@"Received banner AD successfully");
	[self triggerEvent:@"load"];
    
    if (loadCallback){
        JSValueRef params[] = {scriptView->jsTrue};
        [scriptView invokeCallback:loadCallback thisObject:NULL argc:1 argv:params];
        JSValueUnprotect(scriptView.jsGlobalContext, loadCallback);
        loadCallback = nil;
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    loading = false;
	isReady = NO;
	NSLog(@"Failed to receive banner AD with error: %@", [error localizedFailureReason]);
	[self triggerEvent:@"error"];
    
    if (loadCallback){
        JSValueRef params[] = {scriptView->jsFalse};
        [scriptView invokeCallback:loadCallback thisObject:NULL argc:1 argv:params];
        JSValueUnprotect(scriptView.jsGlobalContext, loadCallback);
        loadCallback = nil;
    }
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
//	isReady = NO;
	[self triggerEvent:@"close"];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
	[self triggerEvent:@"click"];
}

EJ_BIND_GET(isReady, ctx)
{
	return JSValueMakeBoolean(ctx, isReady);
}

EJ_BIND_FUNCTION(load, ctx, argc, argv)
{
    if (loading){
        return scriptView->jsFalse;
    }
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

	isReady = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2),
       dispatch_get_main_queue(), ^{
           [self doLayout];
           [self requestBanner];
       });
    
	return scriptView->jsTrue;
}

EJ_BIND_FUNCTION(show, ctx, argc, argv)
{
	wantToShow = YES;
	if (!isReady) {
        return scriptView->jsFalse;
    }
    [scriptView bringSubviewToFront:banner];
    banner.hidden = NO;

    //	[UIView animateWithDuration:1.0 animations: ^{
    //	    // Final frame of ad should be docked to bottom of screen
    //	    banner.frame = CGRectMake(x,
    //	                              y,
    //	                              width,
    //	                              height);
    //	} completion: ^(BOOL finished) {
    //			
    //	}];

    return scriptView->jsTrue;

}

EJ_BIND_FUNCTION(hide, ctx, argc, argv)
{
    wantToShow = NO;
    banner.hidden = YES;
    
    //	[UIView animateWithDuration:1.0 animations: ^{
    //	    banner.frame = CGRectMake(x,
    //	                              -height,
    //	                              width,
    //	                              height);
    //	} completion: ^(BOOL finished) {
    //	    banner.hidden = YES;
    //	}];
    
    return NULL;
}

EJ_BIND_GET(x, ctx)
{
	return JSValueMakeNumber(ctx, x);
}

EJ_BIND_SET(x, ctx, value)
{
	short newX = JSValueToNumberFast(ctx, value);
	if (newX != x) {
		x = newX;
		[banner setFrame:CGRectMake(x, y, width, height)];
	}
}

EJ_BIND_GET(y, ctx)
{
	return JSValueMakeNumber(ctx, y);
}

EJ_BIND_SET(y, ctx, value)
{
	short newY = JSValueToNumberFast(ctx, value);
	if (newY != y) {
		y = newY;
		[banner setFrame:CGRectMake(x, y, width, height)];
	}
}

EJ_BIND_GET(width, ctx)
{
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_GET(height, ctx)
{
	return JSValueMakeNumber(ctx, height);
}

EJ_BIND_ENUM(type, self.bannerType,
             "banner",
             "mediumrectangle",
             "fullbanner",
             "leaderboard",
             "skyscraper",
             "portrait",
             "landscape",
             "invalid"
             );

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(close);
EJ_BIND_EVENT(click);

@end
