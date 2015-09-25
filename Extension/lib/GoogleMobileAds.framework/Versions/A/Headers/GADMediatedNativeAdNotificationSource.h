//
//  GADMediatedNativeAdNotificationSource.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GADMediatedNativeAd.h>

/// Notifies the Google Mobile Ads SDK about the events performed by adapters. Adapters may perform
/// some action (e.g. opening an in app browser or open the iTunes store) when handling callbacks
/// from GADMediatedNativeAdDelegate. Adapters in such case should notify the Google Mobile Ads SDK
/// by calling the relevant methods from this class.
@interface GADMediatedNativeAdNotificationSource : NSObject

/// Must be called by the adapter just before mediatedNativeAd has opened an in app modal screen.
+ (void)mediatedNativeAdWillPresentScreen:(id<GADMediatedNativeAd>)mediatedNativeAd;

/// Must be called by the adapter just before the in app modal screen opened by mediatedNativeAd is
/// dismissed.
+ (void)mediatedNativeAdWillDismissScreen:(id<GADMediatedNativeAd>)mediatedNativeAd;

/// Must be called by the adapter after the in app modal screen opened by mediatedNativeAd is
/// dismissed.
+ (void)mediatedNativeAdDidDismissScreen:(id<GADMediatedNativeAd>)mediatedNativeAd;

/// Must be called by the adapter just before mediatedNativeAd has left the application.
+ (void)mediatedNativeAdWillLeaveApplication:(id<GADMediatedNativeAd>)mediatedNativeAd;

@end
