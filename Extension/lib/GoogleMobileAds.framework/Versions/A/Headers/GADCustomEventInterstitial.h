//
//  GADCustomEventInterstitial.h
//  Google Mobile Ads SDK
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADCustomEventInterstitialDelegate.h>
#import <GoogleMobileAds/GADCustomEventRequest.h>

/// The protocol for a Custom Event of the interstitial type. Your Custom Event handler object for
/// interstitial must implement this protocol. The requestInterstitialAd method will be called when
/// mediation schedules your Custom Event to be executed.
@protocol GADCustomEventInterstitial<NSObject>

/// You should call back to the |delegate| with the results of the execution to ensure mediation
/// behaves correctly. The delegate is assigned, not retained, to prevent memory leak caused by
/// circular retention.
///
/// Define the -delegate and -setDelegate: methods in your class.
///
/// In your class's -dealloc method, remember to nil out the delegate.
@property(nonatomic, weak) id<GADCustomEventInterstitialDelegate> delegate;

/// This method is called by mediation when your Custom Event is scheduled to be executed. Your
/// implementation should begin retrieval of the interstitial ad, usually from a backend server, or
/// from an ad network SDK. Results of the execution should be reported back via the delegate. Note
/// that you should wait until -presentFromRootViewController is called before displaying the
/// interstitial ad. Do not automatically display the ad when you receive the ad. Instead, retain
/// the ad and display it when presentFromRootViewController is called. |serverParameter| and
/// |serverLabel| are the parameter and label configured in the AdMob mediation UI for the Custom
/// Event. |request| contains information about the ad request, some of those are from GADRequest.
- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request;

/// Present the interstitial ad as a modal view using the provided view controller. This is called
/// only after your Custom Event calls back to the delegate with the message
/// -customEvent:didReceiveAd: .
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

@end
