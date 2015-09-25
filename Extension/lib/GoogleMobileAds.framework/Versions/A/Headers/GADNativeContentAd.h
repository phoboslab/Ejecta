//
//  GADNativeContentAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADAdLoaderDelegate.h>
#import <GoogleMobileAds/GADNativeAd.h>
#import <GoogleMobileAds/GADNativeAdImage.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>

#pragma mark - Native Content Ad Assets

/// For use with GADAdLoader's creation methods. If you request this ad type, your delegate must
/// conform to the GADNativeContentAdRequestDelegate protocol.
///
/// See GADNativeAdImageAdLoaderOptions.h for ad loader image options.
GAD_EXTERN NSString *const kGADAdLoaderAdTypeNativeContent;

/// Native content ad.
@interface GADNativeContentAd : GADNativeAd

#pragma mark - Must be displayed

/// Primary text headline.
@property(nonatomic, readonly, copy) NSString *headline;
/// Secondary text.
@property(nonatomic, readonly, copy) NSString *body;

#pragma mark - Recommended to display

/// Large images.
@property(nonatomic, readonly, copy) NSArray *images;
/// Small logo image.
@property(nonatomic, readonly, strong) GADNativeAdImage *logo;
/// Text that encourages user to take some action with the ad.
@property(nonatomic, readonly, copy) NSString *callToAction;
/// Identifies the advertiser. For example, the advertiser’s name or visible URL.
@property(nonatomic, readonly, copy) NSString *advertiser;
@end

#pragma mark - Protocol and constants

/// The delegate of a GADAdLoader object implements this protocol to receive GADNativeContentAd ads.
@protocol GADNativeContentAdLoaderDelegate<GADAdLoaderDelegate>
/// Called when native content is received.
- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd;
@end

#pragma mark - Native Content Ad View

/// Base class for content ad views. Your content ad view must be a subclass of this class and must
/// call superclass methods for all overriden methods.
@interface GADNativeContentAdView : UIView

/// This property must point to the native content ad object rendered by this ad view.
@property(nonatomic, strong) GADNativeContentAd *nativeContentAd;

// Weak references to your ad view's asset views.
@property(nonatomic, weak) IBOutlet UIView *headlineView;
@property(nonatomic, weak) IBOutlet UIView *bodyView;
@property(nonatomic, weak) IBOutlet UIView *imageView;
@property(nonatomic, weak) IBOutlet UIView *logoView;
@property(nonatomic, weak) IBOutlet UIView *callToActionView;
@property(nonatomic, weak) IBOutlet UIView *advertiserView;

@end
