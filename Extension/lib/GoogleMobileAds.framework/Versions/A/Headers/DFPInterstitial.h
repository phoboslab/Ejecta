//
//  DFPInterstitial.h
//  Google Mobile Ads SDK
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <GoogleMobileAds/GADCorrelator.h>
#import <GoogleMobileAds/GADInterstitial.h>

@protocol DFPCustomRenderedInterstitialDelegate;
@protocol GADAppEventDelegate;

@interface DFPInterstitial : GADInterstitial

/// Required value created on the DFP website. Create a new ad unit for every unique placement of an
/// ad in your application. Set this to the ID assigned for this placement. Ad units are important
/// for targeting and stats.
///
/// Example DFP ad unit ID: @"/6499/example/interstitial"
@property(nonatomic, readonly, copy) NSString *adUnitID;

/// Correlator object for correlating this object to other ad objects.
@property(nonatomic, strong) GADCorrelator *correlator;

/// Optional delegate that is notified when creatives send app events.
@property(nonatomic, weak) id<GADAppEventDelegate> appEventDelegate;

/// Optional delegate object for custom rendered ads.
@property(nonatomic, weak)
    id<DFPCustomRenderedInterstitialDelegate> customRenderedInterstitialDelegate;

@end
