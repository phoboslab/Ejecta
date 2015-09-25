//
//  GADMediatedNativeAppInstallAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GADMediatedNativeAd.h>
#import <GoogleMobileAds/GADNativeAdImage.h>

/// Provides methods used for constructing native app install ads. The adapter must return an object
/// conforming to this protocol for native app install ad requests.
@protocol GADMediatedNativeAppInstallAd<GADMediatedNativeAd>

/// App title.
- (NSString *)headline;

/// Array of GADNativeAdImage objects related to the advertised application.
- (NSArray *)images;

/// App description.
- (NSString *)body;

/// Application icon.
- (GADNativeAdImage *)icon;

/// Text that encourages user to take some action with the ad. For example "Install".
- (NSString *)callToAction;

/// App store rating (0 to 5).
- (NSDecimalNumber *)starRating;

/// The app store name. For example, "App Store".
- (NSString *)store;

/// String representation of the app's price.
- (NSString *)price;

@end
