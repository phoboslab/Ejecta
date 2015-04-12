//
//  DFPCustomRenderedBannerViewDelegate.h
//  Google Mobile Ads SDK
//
//  Copyright 2014 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFPBannerView;
@class DFPCustomRenderedAd;

@protocol DFPCustomRenderedBannerViewDelegate<NSObject>

/// Called after ad data has been received. You must construct a banner from |customRenderedAd| and
/// call the |customRenderedAd| object's finishedRenderingAdView: when the ad is rendered.
- (void)bannerView:(DFPBannerView *)bannerView
    didReceiveCustomRenderedAd:(DFPCustomRenderedAd *)customRenderedAd;

@end
