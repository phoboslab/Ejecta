//
//  GADMediatedNativeAdDelegate.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GADMediatedNativeAd;

/// GADMediatedNativeAdDelegate objects handle mediated native ad events.
@protocol GADMediatedNativeAdDelegate<NSObject>

@optional

/// Tells the delegate that the mediated native ad has rendered in |view|.
- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd didRenderInView:(UIView *)view;

/// Tells the delegate that the mediated native ad has recorded an impression. This method is called
/// only once per mediated native ad.
- (void)mediatedNativeAdDidRecordImpression:(id<GADMediatedNativeAd>)mediatedNativeAd;

/// Tells the delegate that the mediated native ad has recorded a user click on the asset named
/// |assetName|. Full screen actions should be presented from |viewController|.
- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd
    didRecordClickOnAssetWithName:(NSString *)assetName
                             view:(UIView *)view
                   viewController:(UIViewController *)viewController;

@end
