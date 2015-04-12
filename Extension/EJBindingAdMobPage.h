/*

   Google AdMob needs some Frameworks:

   AdSupport.framework
   CoreTelephony.framework
   MessageUI.framework
   libz.dylib

 */
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>

#import "EJBindingEventedBase.h"


@class GADInterstitial;
@class GADRequest;

@interface EJBindingAdMobPage : EJBindingEventedBase <GADInterstitialDelegate>
{
	GADInterstitial *interstitial;
	NSString *adUnitID;
	BOOL isReady;
}

@end
