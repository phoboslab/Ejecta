//
//  GADAdLoaderDelegate.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GADRequestError.h"

@class GADAdLoader;

/// Base ad loader delegate protocol. Ad types provide extended protocols that declare methods to
/// handle successful ad loads.
@protocol GADAdLoaderDelegate<NSObject>

/// Called when adLoader fails to load an ad.
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error;

@end
