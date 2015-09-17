//
//  GADAdLoaderAdTypes.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMobileAds/GoogleMobileAdsDefines.h>

// For use with GADAdLoader's creation methods. See the constants' respective headers for each ad
// type's delegate requirements.

/// Native app install ad type. \see GADNativeAppInstallAd.h.
GAD_EXTERN NSString *const kGADAdLoaderAdTypeNativeAppInstall;

/// Native content ad type. \see GADNativeContentAd.h.
GAD_EXTERN NSString *const kGADAdLoaderAdTypeNativeContent;

/// Native custom template ad type. \see GADNativeCustomTemplateAd.h.
GAD_EXTERN NSString *const kGADAdLoaderAdTypeNativeCustomTemplate;
