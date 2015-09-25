//
//  GADCorrelator.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Represents a correlation between multiple ads. Set an instance of this object on multiple ads to
/// indicate they are being used in a common context.
@interface GADCorrelator : NSObject

/// Resets the correlator to force a new set of correlated ads.
- (void)reset;

@end
