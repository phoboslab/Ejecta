//
//  GADMobileAds.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GADMobileAds : NSObject

/// Disables automated in app purchase (IAP) reporting. Must be called before any IAP transaction is
/// initiated. IAP reporting is used to track IAP ad conversions. Do not disable reporting if you
/// use IAP ads.
+ (void)disableAutomatedInAppPurchaseReporting;

/// Disables automated SDK crash reporting. If not called, the SDK records the original exception
/// handler if available and registers a new exception handler. The new exception handler only
/// reports SDK related exceptions and calls the recorded original exception handler.
+ (void)disableSDKCrashReporting;

@end
