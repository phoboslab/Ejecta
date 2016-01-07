#import "EJBindingAdMob.h"

@implementation EJBindingAdMob


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			adUnitID = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set adUnitID");
		}
        
        interstitialLoading = false;
		bannerLoading = false;
		isBannerReady = false;
		bannerX = 0;
		bannerY = 0;
	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	if(interstitial){
		interstitial.delegate = nil;
		[interstitial release];
	}
	if(banner){
		banner.rootViewController = nil;
		banner.delegate = nil;
		[banner release];
	}
	[super dealloc];
}




- (void)initBannerWithView:(EJJavaScriptView *)view {
	
	banner = [[GADBannerView alloc] initWithFrame:CGRectZero];
	banner.adUnitID = adUnitID;
	banner.delegate = self;
	banner.hidden = YES;
	banner.rootViewController = scriptView.window.rootViewController;
	
	[scriptView addSubview:banner];
}

- (CGSize)getBannerSize {
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
	
	CGSize size = [self getBannerSize];
	[banner setFrame:CGRectMake(bannerX, bannerX, size.width, size.height)];
}

- (void)requestBanner {
	
	bannerLoading = true;
	isBannerReady = false;
	
	GADRequest *request = [GADRequest request];
	
	// Make the request for a test ad. Put in an identifier for the simulator as well as any devices
	// you want to receive test ads.
	request.testDevices = @[
							kGADSimulatorID,
							@"7ab1b64b7d167bd4b5ef38c58f925092",
							@"270a3ec13074818800317013ce006923",
							@"7eafba728afe41b98d10310ffa9e6e66"
							];
	
	[banner loadRequest:request];
}

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
	bannerLoading = false;
	isBannerReady = true;
	NSLog(@"Received banner AD successfully");
	[self triggerEvent:@"banner_onLoad"];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
	bannerLoading = false;
	isBannerReady = false;
	NSLog(@"Failed to receive banner AD with error: %@", [error localizedFailureReason]);
	[self triggerEvent:@"banner_onFail"];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
	isBannerReady = NO;
	[self triggerEvent:@"banner_onClose"];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
	[self triggerEvent:@"banner_onClick"];
}

///////////////////////////////////////


- (void)initAndLoadInterstitial {
	interstitialLoading = true;
	
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
							@"270a3ec13074818800317013ce006923",
							@"7eafba728afe41b98d10310ffa9e6e66"
							];
	[interstitial loadRequest:request];
}

/////////////////////////////////////


- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    interstitialLoading = false;
	NSLog(@"Received interstitial AD successfully");
	[self triggerEvent:@"interstitial_onLoad"];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    interstitialLoading = false;
	NSLog(@"Failed to receive interstitial AD with error: %@", [error localizedFailureReason]);
    [self triggerEvent:@"interstitial_onFail"];
}


- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
	[self triggerEvent:@"interstitial_onDisplay"];
}


- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {

}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
	[self triggerEvent:@"interstitial_onClose"];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
	[self triggerEvent:@"interstitial_onClick"];
}


///////////////////////////



EJ_BIND_GET(adUnitID, ctx)
{
	return NSStringToJSValue(ctx, adUnitID);
}

EJ_BIND_GET(bannerX, ctx)
{
	return JSValueMakeNumber(ctx, bannerX);
}
EJ_BIND_SET(bannerX, ctx, value)
{
	double newValue = JSValueToNumberFast(ctx, value);
	if (newValue != bannerX) {
		bannerX = newValue;
		if (banner){
			[self doLayout];
		}
	}
}
EJ_BIND_GET(bannerY, ctx)
{
	return JSValueMakeNumber(ctx, bannerY);
}
EJ_BIND_SET(bannerY, ctx, value)
{
	double newValue = JSValueToNumberFast(ctx, value);
	if (newValue != bannerY) {
		bannerY = newValue;
		if (banner){
			[self doLayout];
		}
	}
}

EJ_BIND_FUNCTION(setBannerPos, ctx, argc, argv)
{
	if (argc < 2){
		return NULL;
	}
	
	double x = JSValueToNumberFast(ctx, argv[0]);
	double y = JSValueToNumberFast(ctx, argv[0]);
	
	bannerX = x;
	bannerY = y;

	if (banner){
		[self doLayout];
	}
	return NULL;
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



///////////////////////////



-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	if ([type isEqualToString:@"banner"]){
		if (bannerLoading){
			return false;
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.21),
			   dispatch_get_main_queue(), ^{
				   [self doLayout];
				   [self requestBanner];
			   });
	}else{
		if (interstitialLoading){
			return false;
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.25),
			   dispatch_get_main_queue(), ^{
				   [self initAndLoadInterstitial];
			   });
	}

	return true;
}


-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	if ([type isEqualToString:@"banner"]){
		[scriptView bringSubviewToFront:banner];
		banner.hidden = NO;
		return true;
	}else{
		if (interstitial.isReady) {
			[interstitial presentFromRootViewController:scriptView.window.rootViewController];
			return true;
		}
	}

	return false;
	
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	if ([type isEqualToString:@"banner"]){
		return isBannerReady;
	}
	return interstitial.isReady;
	
}

-(void)callHide:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	banner.hidden = YES;
}


@end
