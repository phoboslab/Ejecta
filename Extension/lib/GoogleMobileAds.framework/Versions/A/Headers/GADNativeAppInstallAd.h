//
//  GADNativeAppInstallAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADAdLoaderDelegate.h>
#import <GoogleMobileAds/GADMediaView.h>
#import <GoogleMobileAds/GADNativeAd.h>
#import <GoogleMobileAds/GADNativeAdImage.h>
#import <GoogleMobileAds/GADVideoController.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>

/// Native app install ad. To request this ad type, you need to pass
/// kGADAdLoaderAdTypeNativeAppInstall (see GADAdLoaderAdTypes.h) to the |adTypes| parameter in
/// GADAdLoader's initializer method. If you request this ad type, your delegate must conform to the
/// GADNativeAppInstallAdRequestDelegate protocol.
@interface GADNativeAppInstallAd : GADNativeAd

#pragma mark - Must be displayed

/// App title.
@property(nonatomic, readonly, copy) NSString *headline;
/// Text that encourages user to take some action with the ad. For example "Install".
@property(nonatomic, readonly, copy) NSString *callToAction;
/// Application icon.
@property(nonatomic, readonly, strong) GADNativeAdImage *icon;

#pragma mark - Recommended to display

/// App description.
@property(nonatomic, readonly, copy) NSString *body;
/// The app store name. For example, "App Store".
@property(nonatomic, readonly, copy) NSString *store;
/// String representation of the app's price.
@property(nonatomic, readonly, copy) NSString *price;
/// Array of GADNativeAdImage objects related to the advertised application.
@property(nonatomic, readonly, strong) NSArray *images;
/// App store rating (0 to 5).
@property(nonatomic, readonly, copy) NSDecimalNumber *starRating;
/// Video controller for controlling video playback in GADNativeAppInstallAdView's mediaView.
/// Returns nil if the ad doesn't contain a video asset.
@property(nonatomic, strong, readonly) GADVideoController *videoController;
@end

#pragma mark - Protocol and constants

/// The delegate of a GADAdLoader object implements this protocol to receive GADNativeAppInstallAd
/// ads.
@protocol GADNativeAppInstallAdLoaderDelegate<GADAdLoaderDelegate>
/// Called when a native app install ad is received.
- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd;
@end

#pragma mark - Native App Install Ad View

/// Base class for app install ad views. Your app install ad view must be a subclass of this class
/// and must call superclass methods for all overriden methods.
@interface GADNativeAppInstallAdView : UIView

/// This property must point to the native app install ad object rendered by this ad view.
@property(nonatomic, strong) GADNativeAppInstallAd *nativeAppInstallAd;

// Weak references to your ad view's asset views.
@property(nonatomic, weak) IBOutlet UIView *headlineView;
@property(nonatomic, weak) IBOutlet UIView *callToActionView;
@property(nonatomic, weak) IBOutlet UIView *iconView;
@property(nonatomic, weak) IBOutlet UIView *bodyView;
@property(nonatomic, weak) IBOutlet UIView *storeView;
@property(nonatomic, weak) IBOutlet UIView *priceView;
@property(nonatomic, weak) IBOutlet UIView *imageView;
@property(nonatomic, weak) IBOutlet UIView *starRatingView;
@property(nonatomic, weak) IBOutlet GADMediaView *mediaView;

@end
