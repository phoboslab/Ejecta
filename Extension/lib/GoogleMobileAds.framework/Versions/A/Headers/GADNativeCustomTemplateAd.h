//
//  GADNativeCustomTemplateAd.h
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

// For use with GADAdLoader's creation methods. If you request this ad type, your delegate must
// conform to the GADNativeCustomTemplateAdLoaderDelegate protocol.
GAD_EXTERN NSString *const kGADAdLoaderAdTypeNativeCustomTemplate;

/// Native custom template ad.
@interface GADNativeCustomTemplateAd : GADNativeAd

/// The ad's custom template ID.
@property(nonatomic, readonly) NSString *templateID;

/// Array of available asset keys.
@property(nonatomic, readonly) NSArray *availableAssetKeys;

/// Returns the native ad image corresponding to the specified key or nil if the image is not
/// available.
- (GADNativeAdImage *)imageForKey:(NSString *)key;

/// Returns the string corresponding to the specified key or nil if the string is not available.
- (NSString *)stringForKey:(NSString *)key;

/// Call when the user clicks on the ad. Provide the asset key that best matches the asset the user
/// interacted with. Provide |customClickHandler| only if this template is configured with a custom
/// click action, otherwise pass in nil. If a block is provided, the ad's built-in click actions are
/// ignored and |customClickHandler| is executed after recording the click.
- (void)performClickOnAssetWithKey:(NSString *)assetKey
                customClickHandler:(dispatch_block_t)customClickHandler;

/// Call when the ad is displayed on screen to the user. Can be called multiple times. Only the
/// first impression is recorded.
- (void)recordImpression;

@end

#pragma mark - Loading Protocol

/// The delegate of a GADAdLoader object implements this protocol to receive
/// GADNativeCustomTemplateAd ads.
@protocol GADNativeCustomTemplateAdLoaderDelegate<GADAdLoaderDelegate>

/// Called when requesting an ad. Asks the delgate for an array of custom template ID strings.
- (NSArray *)nativeCustomTemplateIDsForAdLoader:(GADAdLoader *)adLoader;

/// Tells the delegate that a native custom template ad was received.
- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd;

@end
