//
//  DFPRequest.h
//  Google Mobile Ads SDK
//
//  Copyright 2014 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>

/// Add this constant to the testDevices property's array to receive test ads on the simulator.
GAD_EXTERN const id kDFPSimulatorID;

/// Specifies optional parameters for ad requests.
@interface DFPRequest : GADRequest

/// Publisher provided user ID.
@property(nonatomic, copy) NSString *publisherProvidedID;

/// Array of strings used to exclude specified categories in ad results.
@property(nonatomic, copy) NSArray *categoryExclusions;

/// Key-value pairs used for custom targeting.
@property(nonatomic, copy) NSDictionary *customTargeting;

/// Update the ad correlator. Ad slots with the same correlation value are grouped for roadblocking.
/// After updating the correlator, load new requests in all DFP ads.
+ (void)updateCorrelator;

@end
