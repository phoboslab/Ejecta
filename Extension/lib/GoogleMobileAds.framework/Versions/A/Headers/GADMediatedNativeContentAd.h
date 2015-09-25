//
//  GADMediatedNativeContentAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GADMediatedNativeAd.h>
#import <GoogleMobileAds/GADNativeAdImage.h>

/// Provides methods used for constructing native content ads.
@protocol GADMediatedNativeContentAd<GADMediatedNativeAd>

/// Primary text headline.
- (NSString *)headline;

/// Secondary text.
- (NSString *)body;

/// List of large images. Each object is an instance of GADNativeAdImage.
- (NSArray *)images;

/// Small logo image.
- (GADNativeAdImage *)logo;

/// Text that encourages user to take some action with the ad.
- (NSString *)callToAction;

/// Identifies the advertiser. For example, the advertiser’s name or visible URL.
- (NSString *)advertiser;

@end
