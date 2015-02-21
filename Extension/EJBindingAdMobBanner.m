#import "EJBindingAdMobBanner.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@implementation EJBindingAdMobBanner



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

	wantsToShow = NO;
	isReady = NO;
	x = 0;
	y = 0;

	banner = [[GADBannerView alloc] initWithFrame:CGRectZero];
	banner.adUnitID = adUnitID;
	banner.delegate = self;
	banner.hidden = YES;
	banner.rootViewController = scriptView.window.rootViewController;
//	[self doLayout];
	[scriptView addSubview:banner];
}

- (void)dealloc {
	isReady = NO;
	banner.delegate = nil;
	[banner release];
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
	CGSize size = [self getSize];
	width = size.width;
	height = size.height;
	[banner setFrame:CGRectMake(x, y, width, height)];
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

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
	NSLog(@"Received ad successfully");
	isReady = YES;
	[self triggerEvent:@"load"];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
	isReady = NO;
	[self triggerEvent:@"error"];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
	isReady = NO;
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
	isReady = NO;
	[self doLayout];
	[banner loadRequest:[self request]];
	return NULL;
}

EJ_BIND_FUNCTION(hide, ctx, argc, argv)
{
	wantsToShow = NO;
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

EJ_BIND_FUNCTION(show, ctx, argc, argv)
{
	wantsToShow = YES;
	if (isReady) {
		[scriptView bringSubviewToFront:banner];
		banner.hidden = NO;
//		[UIView animateWithDuration:1.0 animations: ^{
//		    // Final frame of ad should be docked to bottom of screen
//		    banner.frame = CGRectMake(x,
//		                              y,
//		                              width,
//		                              height);
//		} completion: ^(BOOL finished) {
//			
//		}];
	}
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
