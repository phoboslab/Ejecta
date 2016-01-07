/*

   Google AdMob needs some Frameworks:

   AdSupport.framework
   CoreTelephony.framework
   MessageUI.framework
   libz.dylib

 */
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADBannerViewDelegate.h>

#import "EJBindingAdBase.h"



typedef enum {
	banner,             // 320x50
	mediumrectangle,    // 300x250
	fullbanner,         // 468x60
	leaderboard,        // 728x90
	skyscraper,         // 120x600
	portrait,           // portraitx32/50/90
	landscape,          // landscapex32/50/90
	invalid             //
} BannerType;


@interface EJBindingAdMob : EJBindingAdBase <GADInterstitialDelegate, GADBannerViewDelegate>
{
	GADInterstitial *interstitial;
	GADBannerView *banner;
	NSString *adUnitID;

	double bannerX;
	double bannerY;
	BOOL isBannerReady;
    BOOL bannerLoading;
	BOOL interstitialLoading;
}

@property (readwrite, nonatomic) BannerType bannerType;

@end
