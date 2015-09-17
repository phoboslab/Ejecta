//
//  GADNativeAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GADNativeAdDelegate;

/// Native ad base class. All native ad types are subclasses of this class.
@interface GADNativeAd : NSObject

/// Optional delegate to receive state change notifications.
@property(nonatomic, weak) id<GADNativeAdDelegate> delegate;

/// Root view controller for handling ad actions.
@property(nonatomic, weak) UIViewController *rootViewController;

@end
