//
//  GADCustomEventBanner.h
//  Google Mobile Ads SDK
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADAdSize.h>
#import <GoogleMobileAds/GADCustomEventBannerDelegate.h>
#import <GoogleMobileAds/GADCustomEventRequest.h>

/// The banner custom event protocol. Your banner custom event handler must implement this protocol.
@protocol GADCustomEventBanner<NSObject>

/// Inform |delegate| with the custom event execution results to ensure mediation behaves correctly.
///
/// In your class, define the -delegate and -setDelegate: methods or use "@synthesize delegate". The
/// Google Mobile Ads SDK sets this property on instances of your class.
@property(nonatomic, weak) id<GADCustomEventBannerDelegate> delegate;

/// Called by mediation when your custom event is scheduled to be executed. Report execution results
/// to the delegate.
/// \param adSize the size of the ad as configured in the mediation UI for the mediation placement.
/// \param serverParameter parameter configured in the mediation UI.
/// \param serverLabel label configured in the mediation UI.
/// \param request contains ad request information.
- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request;

@end
