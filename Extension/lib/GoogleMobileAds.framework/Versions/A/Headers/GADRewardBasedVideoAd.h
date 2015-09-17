//
//  GADRewardBasedVideoAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GADRequest;

@protocol GADRewardBasedVideoAdDelegate;

@interface GADRewardBasedVideoAd : NSObject

/// Delegate for receiving video notifications.
@property(nonatomic, weak) id<GADRewardBasedVideoAdDelegate> delegate;

/// Indicates if the receiver is ready to be presented full screen.
@property(nonatomic, readonly, assign, getter=isReady) BOOL ready;

/// Singleton instance.
+ (GADRewardBasedVideoAd *)sharedInstance;

/// Initiate the request to fetch the reward based video ad.
- (void)loadRequest:(GADRequest *)request
       withAdUnitID:(NSString *)adUnitID
             userID:(NSString *)userID;

/// Present the reward based video ad with provided view controller.
- (void)presentFromRootViewController:(UIViewController *)viewController;

@end
