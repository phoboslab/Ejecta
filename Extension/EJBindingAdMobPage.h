/*

   Google AdMob needs some Frameworks:

   AdSupport.framework
   CoreTelephony.framework
   MessageUI.framework
   libz.dylib

 */

#import "EJBindingEventedBase.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

@class GADInterstitial;
@class GADRequest;

@interface EJBindingAdMobPage : EJBindingEventedBase <GADInterstitialDelegate>
{
	GADInterstitial *interstitial;
	NSString *adUnitID;
	BOOL isReady;
}

@end
