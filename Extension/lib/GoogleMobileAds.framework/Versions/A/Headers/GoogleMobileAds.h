//
//  GoogleMobileAds.h
//  Google Mobile Ads SDK
//
//  Copyright 2014 Google Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
#error The Google Mobile Ads SDK requires a deployment target of iOS 6.0 or later.
#endif

//! Project version string for GoogleMobileAds.
FOUNDATION_EXPORT const unsigned char GoogleMobileAdsVersionString[];

#import <GoogleMobileAds/GADAdNetworkExtras.h>
#import <GoogleMobileAds/GADAdSize.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADBannerViewDelegate.h>
#import <GoogleMobileAds/GADExtras.h>
#import <GoogleMobileAds/GADInAppPurchase.h>
#import <GoogleMobileAds/GADInAppPurchaseDelegate.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADRequestError.h>

#import <GoogleMobileAds/DFPBannerView.h>
#import <GoogleMobileAds/DFPCustomRenderedAd.h>
#import <GoogleMobileAds/DFPCustomRenderedBannerViewDelegate.h>
#import <GoogleMobileAds/DFPCustomRenderedInterstitialDelegate.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import <GoogleMobileAds/DFPRequest.h>
#import <GoogleMobileAds/GADAdSizeDelegate.h>
#import <GoogleMobileAds/GADAppEventDelegate.h>

#import <GoogleMobileAds/Loading/GADAdLoader.h>
#import <GoogleMobileAds/Loading/GADAdLoaderAdTypes.h>
#import <GoogleMobileAds/Loading/GADAdLoaderDelegate.h>

#import <GoogleMobileAds/Loading/Formats/GADNativeAd.h>
#import <GoogleMobileAds/Loading/Formats/GADNativeAdDelegate.h>
#import <GoogleMobileAds/Loading/Formats/GADNativeAdImage.h>
#import <GoogleMobileAds/Loading/Formats/GADNativeAppInstallAd.h>
#import <GoogleMobileAds/Loading/Formats/GADNativeContentAd.h>
#import <GoogleMobileAds/Loading/Formats/GADNativeCustomTemplateAd.h>

#import <GoogleMobileAds/Loading/Options/GADNativeAdImageAdLoaderOptions.h>

#import <GoogleMobileAds/Mediation/GADCustomEventBanner.h>
#import <GoogleMobileAds/Mediation/GADCustomEventBannerDelegate.h>
#import <GoogleMobileAds/Mediation/GADCustomEventExtras.h>
#import <GoogleMobileAds/Mediation/GADCustomEventInterstitial.h>
#import <GoogleMobileAds/Mediation/GADCustomEventInterstitialDelegate.h>
#import <GoogleMobileAds/Mediation/GADCustomEventRequest.h>

#import <GoogleMobileAds/Search/GADSearchBannerView.h>
#import <GoogleMobileAds/Search/GADSearchRequest.h>
