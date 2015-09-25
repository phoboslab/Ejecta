//
//  GADCustomEventRequest.h
//  Google Mobile Ads SDK
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADRequest.h>

@class GADCustomEventExtras;

@interface GADCustomEventRequest : NSObject

/// The end user's gender set in GADRequest. If not specified, returns kGADGenderUnknown.
@property(nonatomic, readonly, assign) GADGender userGender;

/// The end user's birthday set in GADRequest. If not specified, returns nil.
@property(nonatomic, readonly, copy) NSDate *userBirthday;

/// The end user's latitude, longitude, and accuracy, set in GADRequest. If not specified,
/// userHasLocation returns NO, and userLatitude, userLongitude and userLocationAccuracyInMeters
/// will all return 0.
@property(nonatomic, readonly, assign) BOOL userHasLocation;
@property(nonatomic, readonly, assign) CGFloat userLatitude;
@property(nonatomic, readonly, assign) CGFloat userLongitude;
@property(nonatomic, readonly, assign) CGFloat userLocationAccuracyInMeters;

/// Description of the user's location, in free form text, set in GADRequest. If not available,
/// returns nil. This may be set even if userHasLocation is NO.
@property(nonatomic, readonly, copy) NSString *userLocationDescription;

/// Keywords set in GADRequest. Returns nil if no keywords are set.
@property(nonatomic, readonly, copy) NSArray *userKeywords;

/// The additional parameters set by the application. This property allows you to pass additional
/// information from your application to your Custom Event object. To do so, create an instance of
/// GADCustomEventExtras to pass to GADRequest -registerAdNetworkExtras:. The instance should have
/// an NSDictionary set for a particular custom event label. That NSDictionary becomes the
/// additionalParameters here.
@property(nonatomic, readonly, copy) NSDictionary *additionalParameters;

/// Indicates if the testing property has been set in GADRequest.
@property(nonatomic, readonly, assign) BOOL isTesting;

@end
