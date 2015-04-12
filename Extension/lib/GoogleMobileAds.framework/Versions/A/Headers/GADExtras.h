//
//  GADExtras.h
//  Google Mobile Ads SDK
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMobileAds/GADAdNetworkExtras.h>

@interface GADExtras : NSObject<GADAdNetworkExtras>

/// Additional parameters to be sent to Google networks.
@property(nonatomic, copy) NSDictionary *additionalParameters;

@end
