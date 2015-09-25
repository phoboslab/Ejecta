//
//  GADNativeAdImageAdLoaderOptions.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <GoogleMobileAds/GADAdLoader.h>

/// Native ad image orientation preference.
typedef NS_ENUM(NSInteger, GADNativeAdImageAdLoaderOptionsOrientation) {
  GADNativeAdImageAdLoaderOptionsOrientationAny,       ///< No orientation preference.
  GADNativeAdImageAdLoaderOptionsOrientationPortrait,  ///< Prefer portrait images.
  GADNativeAdImageAdLoaderOptionsOrientationLandscape  ///< Prefer landscape images.
};

@interface GADNativeAdImageAdLoaderOptions : GADAdLoaderOptions

/// Indicates if image asset content should be loaded by the SDK. If set to YES, the SDK will not
/// load image asset content and native ad image URLs can be used to fetch content. Defaults to NO,
/// image assets are loaded by the SDK.
@property(nonatomic, assign) BOOL disableImageLoading;

/// Indicates if multiple images should be loaded for each asset. Defaults to NO.
@property(nonatomic, assign) BOOL shouldRequestMultipleImages;

/// Indicates preferred image orientation. Defaults to
/// GADNativeAdImageAdLoaderOptionsOrientationAny.
@property(nonatomic, assign) GADNativeAdImageAdLoaderOptionsOrientation preferredImageOrientation;

@end
