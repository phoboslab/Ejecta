//
//  GADAdLoaderDelegate.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GADAdLoader;
@class GADRequestError;

@protocol GADAdLoaderDelegate<NSObject>

/// Called when adLoader fails to load an ad.
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error;

@end
