//
//  GADAppEventDelegate.h
//  Google Mobile Ads SDK
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GADBannerView;
@class GADInterstitial;

/// Implement your app event within these methods. The delegate will be notified when the SDK
/// receives an app event message from the ad.
@protocol GADAppEventDelegate<NSObject>

@optional

/// Called when the banner receives an app event.
- (void)adView:(GADBannerView *)banner
    didReceiveAppEvent:(NSString *)name
              withInfo:(NSString *)info;

/// Called when the interstitial receives an app event.
- (void)interstitial:(GADInterstitial *)interstitial
    didReceiveAppEvent:(NSString *)name
              withInfo:(NSString *)info;

@end
