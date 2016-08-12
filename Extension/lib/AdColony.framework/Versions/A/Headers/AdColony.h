/*
 *  AdColony.h
 *  adc-ios-sdk
 *
 *  Created by Ty Heath on 7/17/12.
 */

#import <Foundation/Foundation.h>

#import "AdColonyAdInfo.h"

#pragma mark - Constants

/**
 * Enum for zone status
 */
typedef NS_ENUM(NSUInteger, ADCOLONY_ZONE_STATUS) {
    ADCOLONY_ZONE_STATUS_NO_ZONE = 0,   /** AdColony has not been configured with that zone ID. */
    ADCOLONY_ZONE_STATUS_OFF,           /** The zone has been turned off on the [Control Panel](http://clients.adcolony.com). */
    ADCOLONY_ZONE_STATUS_LOADING,       /** The zone is preparing ads for display. */
    ADCOLONY_ZONE_STATUS_ACTIVE,        /** The zone has completed preparing ads for display. */
    ADCOLONY_ZONE_STATUS_UNKNOWN        /** AdColony has not yet received the zone's configuration from our server. */
};

#pragma mark - Forward declarations

@class AdColonyNativeAdView;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AdColonyDelegate protocol

/**
 * Use the AdColonyDelegate to receive callbacks when ad availability changes or when a V4VC transaction has completed.
 * This delegate is passed to AdColony during configuration using `[AdColony configureWithAppID:zoneIDs:delegate:logging:]`.
 */
@protocol AdColonyDelegate <NSObject>
@optional

/** @name Video Ad Readiness */

/**
 * Provides your app with real-time updates about ad availability changes.
 * This method is called when a zone's ad availability state changes (when ads become available, or become unavailable).
 * Listening to these callbacks allows your app to update its user interface immediately. 
 * For example, when ads become available in a zone you could immediately show an ad for that zone.
 * @param available Whether ads became available or unavailable.
 * @param zoneID The affected zone.
 */
- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID;


/** @name Virtual Currency Rewards (V4VC) */

/**
 * Notifies your app when a virtual currency transaction has completed as a result of displaying an ad.
 * In your implementation, check for success and implement any app-specific code that should be run when 
 * AdColony has successfully rewarded. Client-side V4VC implementations should increment the user's currency 
 * balance in this method. Server-side V4VC implementations should contact the game server to determine 
 * the current total balance for the virtual currency.
 * @param success Whether the transaction succeeded or failed.
 * @param currencyName The name of currency to reward.
 * @param amount The amount of currency to reward.
 * @param zoneID The affected zone.
 */
- (void)onAdColonyV4VCReward:(BOOL)success currencyName:(NSString *)currencyName currencyAmount:(int)amount inZone:(NSString *)zoneID;
@end

#pragma mark - AdColonyAdDelegate protocol

/**
 * Use the AdColonyAdDelegate to receive callbacks when ads start playing or when an attempt to play an ad has finished (successfully or not).
 * This is most frequently used by apps to pause app sound and music during the display of an ad.
 * This delegate is passed to AdColony when you call a method to play an ad.
 */
@protocol AdColonyAdDelegate <NSObject>
@optional

/**
 * Notifies your app that an ad will actually play in response to the app's request to play an ad.
 * This method is called when AdColony has taken control of the device screen and is about to begin 
 * showing an ad. Apps should implement app-specific code such as pausing a game and turning off app music.
 * @param zoneID The affected zone.
 */
- (void)onAdColonyAdStartedInZone:(NSString *)zoneID;

/**
 * Notifies your app that an ad completed playing (or never played) and control has been returned to the app.
 * This method is called when AdColony has finished trying to show an ad, either successfully or unsuccessfully. 
 * If an ad was shown, apps should implement app-specific code such as unpausing a game and restarting app music.
 * @param shown Whether an ad was actually shown.
 * @param zoneID The affected zone.
 */
- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID;

/**
 * Alternative for `- onAdColonyAdAttemptFinished:inZone` that passes an AdColonyAdInfo object to the delegate. The AdColonyAdInfo object can be queried
 * for information about the ad session: whether or not the ad was shown, the associated zone ID, whether or not the video was an In-App Purchase Promo (IAPP),
 * the type of engagement that triggered an IAP, etc. If your application is showing IAPP advertisements, you will need to implement this callback
 * instead of `- onAdColonyAdAttemptFinished:inZone` so you can decide what action to take once the ad has completed.
 * @param info An AdColonyAdInfo object containing metadata about the associated ad.
 * @see onAdColonyAdAttemptFinished:inZone
 * @see AdColonyAdInfo
 */
- (void)onAdColonyAdFinishedWithInfo:(AdColonyAdInfo *)info;
@end

#pragma mark - AdColony interface

/**
 * The AdColony class provides methods to start AdColony, display ads, and change global settings
 */
@interface AdColony : NSObject

/** @name Starting AdColony */

/**
 * Configures AdColony specifically for your app; required for usage of the rest of the API.
 * This method returns immediately; any long-running work such as network connections are performed in the background.
 * AdColony does not begin preparing ads for display or performing reporting until after it is configured by your app.
 * @param appID The AdColony app ID for your app. This can be created and retrieved at the [Control Panel](http://clients.adcolony.com).
 * @param zoneIDs An array of at least one AdColony zone ID string. AdColony zone IDs can be created and retrieved at the [Control Panel](http://clients.adcolony.com). If `nil`, app will be unable to play ads and AdColony will only provide limited reporting and install tracking functionality.
 * @param del (*optional*) The delegate to receive V4VC and ad availability events. Can be `nil` for apps that do not need these events.
 * @param log A boolean controlling AdColony verbose logging.
 */
+ (void)configureWithAppID:(NSString *)appID zoneIDs:(NSArray *)zoneIDs delegate:(nullable id<AdColonyDelegate>)del logging:(BOOL)log;

/** @name Playing Video Ads */

/**
 * Plays an AdColony ad.
 * This method returns immediately, before the ad completes. If ads are not
 * available, an ad may not play as a result of this method call. If you need
 * more detailed information about when the ad completes or whether an ad
 * played, pass in a delegate.
 * @param zoneID The zone from which the ad should play.
 * @param del (*optional*) The delegate to receive ad events. Can be `nil` for apps that do not need these events.
 */
+ (void)playVideoAdForZone:(NSString *)zoneID withDelegate:(nullable id<AdColonyAdDelegate>)del;

/**
 * Plays an AdColony ad and allows specifying display of the default V4VC instructional popups.
 * This method returns immediately, before the ad completes. If ads are not
 * available, an ad may not play as a result of this method call. If you need
 * more detailed information about when the ad completes or whether an ad
 * played, pass in a delegate.
 * @param zoneID The zone from which the ad should play.
 * @param del (*optional*) The delegate to receive ad events. Can be `nil` for apps that do not need these events.
 * @param showPrePopup Whether AdColony should display an instructional popup before the ad.
 * @param showPostPopup Whether AdColony should display an instructional popup after the ad.
 */
+ (void)playVideoAdForZone:(NSString *)zoneID withDelegate:(nullable id<AdColonyAdDelegate>)del withV4VCPrePopup:(BOOL)showPrePopup andV4VCPostPopup:(BOOL)showPostPopup;

/**
 * Returns an AdColonyNativeAdView, used to display an ad embedded within a screen of your app.
 * @param zoneID The zone from which the ad should play.
 * @param viewController The UIViewController in which you will display the AdColonyNativeAdView. Must not be `nil`. This is required so that the ad can present additional view controllers if the user interacts with it.
 * @return An AdColonyNativeAdView. May be `nil` if ads are not available.
 * @see AdColonyNativeAdView
 */
+ (nullable AdColonyNativeAdView *)getNativeAdForZone:(NSString *)zoneID presentingViewController:(UIViewController *)viewController;

/**
 * Returns the zone status for the specified zone.
 * @param zoneID The zone in question
 * @return An ADCOLONY_ZONE_STATUS enum value indicating the zone status. Possible values are: `ADCOLONY_ZONE_STATUS_NO_ZONE` indicating AdColony has not been configured with that zone ID; `ADCOLONY_ZONE_STATUS_OFF` indicating the zone has been turned off on the control panel; `ADCOLONY_ZONE_STATUS_LOADING` indicating zone is preparing ads for display; `ADCOLONY_ZONE_STATUS_ACTIVE` indicating the zone is ready to display ads; `ADCOLONY_ZONE_STATUS_UNKNOWN` indicating AdColony has not yet received the zone's configuration from the server.
 */
+ (ADCOLONY_ZONE_STATUS)zoneStatusForZone:(NSString *)zoneID;


/** @name Device and User Identifiers */

/**
 * Assigns your own custom identifier to the current app user. 
 * Once you've provided an identifier, AdColony will persist it across app 
 * restarts (stored on disk only) until you update it. If using this method,
 * call it before `[AdColony configureWithAppID:zoneIDs:delegate:logging:]` so that the
 * identifier is used consistently across all server communications. The 
 * identifier will also pass through to server-side V4VC callbacks.
 * @param customID An arbitrary, application-specific identifier string for the current user. Must be less than 128 characters.
 * @see getCustomID
 */
+ (void)setCustomID:(NSString *)customID;

/**
 * Returns the device's current custom identifier.
 * @return The custom identifier string most recently set using `[AdColony setCustomID:]`.
 * @see setCustomID:
 */
+ (NSString *)getCustomID;

/**
 * Returns the device's OpenUDID.
 * OpenUDID is a community-designed replacement for the Apple UDID. You can
 * link your own copy of the OpenUDID library if desired, and it should return
 * the same value for the OpenUDID. For details, please see the
 * [OpenUDID GitHub page](https://github.com/ylechelle/OpenUDID).
 * As of iOS 7, the behavior of this identifier will change. We do not recommend using this
 * identifier for new integrations. This method is provided for backwards compatibility.
 * @return The string representation of the device's OpenUDID.
 */
+ (NSString *)getOpenUDID;

/**
 * Returns an AdColony-defined device identifier.
 * This identifier should remain constant across the lifetime of an iOS device.
 * The identifier is a SHA-1 hash of the lowercase colon-separated MAC address of the device's WiFi interface.
 * As of iOS 7, the behavior of this identifier will change. We do not recommend using this
 * identifier for new integrations. This method is provided for backwards compatibility.
 * @return The string representation of the device's AdColony identifier.
 */
+ (NSString *)getUniqueDeviceID;

/**
 * Returns the device's ODIN-1.
 * ODIN-1 is a community-designed replacement for the Apple UDID. You can
 * link your own copy of the ODIN-1 source if desired, and it should return the same value.
 * For details, please see the [ODIN-1 Google Code page](https://code.google.com/p/odinmobile/wiki/ODIN1).
 * As of iOS 7, the behavior of this identifier will change. We do not recommend using this
 * identifier for new integrations. This method is provided for backwards compatibility.
 * @return The string representation of the device's ODIN-1.
 */
+ (NSString *)getODIN1;

/**
 * Returns the device's advertising identifier.
 * This value can change if the user restores their device or resets ad tracking.
 * @return The string representation of the device's advertising identifier, introduced in iOS 6. Returns an empty string on iOS 5 or below.
 */
+ (NSString *)getAdvertisingIdentifier;

/**
 * Returns the device's vendor identifier.
 * @return As of version 2.3 of our iOS SDK, AdColony no longer collects the vendor identifier and this method will return an empty string. This method is provided for backwards compatibility.
 */
+ (NSString *)getVendorIdentifier;


/** @name V4VC Availability and Currency Info */

/**
 * Returns if it is possible for the user to receive a virtual currency reward for playing an ad in the zone.
 * This method takes into account whether V4VC has been configured properly for the zone on the 
 * [AdColony Control Panel](http://clients.adcolony.com), whether the user's daily reward cap has been reached, 
 * and whether there are ads available.
 * @param zoneID The zone in question.
 * @return A boolean indicating whether a reward is currently available for the user.
 */
+ (BOOL)isVirtualCurrencyRewardAvailableForZone:(NSString *)zoneID;

/**
 * Returns the number of possible virtual currency rewards currently available for the user.
 * This method takes into account daily caps, available ads, and other variables.
 * @param zoneID The zone in question.
 * @return As of version 2.6 of our iOS SDK, AdColony no longer suports this method. It will always return 0. This method is provided for backwards compatibility.
 */
+ (int)getVirtualCurrencyRewardsAvailableTodayForZone:(NSString *)zoneID;

/**
 * Returns the name of the virtual currency rewarded by the zone.
 * You must first configure AdColony using `[AdColony configureWithAppID:zoneIDs:delegate:logging:]`
 * and ensure the zone's status is not `ADCOLONY_ZONE_STATUS_UNKNOWN` before this function will return an accurate result.
 * @param zoneID The zone in question
 * @return A string name of the virtual currency rewarded by the zone, as configured on the [AdColony Control Panel](http://clients.adcolony.com).
 */
+ (NSString *)getVirtualCurrencyNameForZone:(NSString *)zoneID;

/**
 * Returns the amount of virtual currency rewarded by the zone.
 * You must first configure AdColony using `[AdColony configureWithAppID:zoneIDs:delegate:logging:]`
 * and ensure the zone's status is not `ADCOLONY_ZONE_STATUS_UNKNOWN` before this function will return an accurate result.
 * @param zoneID The zone in question
 * @return An integer indicating the amount of virtual currency rewarded by the zone, as configured on the [AdColony Control Panel](http://clients.adcolony.com).
 */
+ (int)getVirtualCurrencyRewardAmountForZone:(NSString *)zoneID;


/** @name V4VC Multiple Videos per Reward Info */

/**
 * Returns the number of ads that the user must play to earn the designated reward.
 * You must first configure AdColony using `[AdColony configureWithAppID:zoneIDs:delegate:logging:]`
 * and ensure the zone's status is not `ADCOLONY_ZONE_STATUS_UNKNOWN` before this function will return an accurate result.
 * @param currencyName The name of the currency to query
 * @return An integer number of ads that the user must play per currency reward, as configured on the [AdColony Control Panel](http://clients.adcolony.com).
 */
+ (int)getVideosPerReward:(NSString *)currencyName;

/**
 * Returns the number of ads that the user has seen towards their next reward.
 * You must first configure AdColony using `[AdColony configureWithAppID:zoneIDs:delegate:logging:]`
 * and ensure the zone's status is not `ADCOLONY_ZONE_STATUS_UNKNOWN` before this function will return an accurate result.
 * @param currencyName The name of the currency to query.
 * @return An integer number of ads that the user has seen towards their next reward.
 */
+ (int)getVideoCreditBalance:(NSString *)currencyName;


/** @name Options and Other Functionality */

/**
 * Cancels any full-screen ad that is currently playing and returns control to the app.
 * No earnings or V4VC rewards will occur if an ad is canceled programmatically by the app. 
 * This should only be used by apps that must immediately respond to non-standard incoming events, 
 * like a VoIP phone call. This should not be used for standard app interruptions such as 
 * multitasking or regular phone calls.
 */
+ (void)cancelAd;

/**
 * Whether a full-screen AdColony ad is currently being played.
 * @return A boolean indicating if AdColony is currently playing an ad.
 */
+ (BOOL)videoAdCurrentlyRunning;

/**
 * This method permanently turns off all AdColony ads for this app on the current device.
 * After this method is called, no ads will be played unless the app is deleted and reinstalled. 
 * This method could be used in the implementation of an In-App Purchase to disable ads;
 * make sure to allow In-App Purchases to be restored by the user in the case of deleting and reinstalling the app. 
 */
+ (void)turnAllAdsOff;


/** @name Optional User Metadata */

/**
 * Provide AdColony with per-user non personally-identifiable information for ad targeting purposes.
 * Providing non personally-identifiable information using this API will improve targeting and unlock
 * improved earnings for your app. [This support article](http://support.adcolony.com/customer/portal/articles/700183-sdk-user-metadata-pass-through) contains usage guidelines.
 * @param metadataType One of the predefined user metadata keys.
 * @param value Either a predefined user metadata value, or arbitrary value.
 */
+ (void)setUserMetadata:(NSString *)metadataType withValue:(NSString *)value;

/**
 * Provide AdColony with real-time feedback about what a user is interested in.
 * Providing non personally-identifiable information using this API will improve targeting and unlock
 * improved earnings for your app. [This support article](http://support.adcolony.com/customer/portal/articles/700183-sdk-user-metadata-pass-through) contains usage guidelines.
 * You can call this as often as you want with various topics that the user has engaged in 
 * within your app or as the user engages in them. For example, if the user has started browsing 
 * the finance section of a news app, a developer should call: `[AdColony userInterestedIn:@"finance"]`.
 * @param topic An arbitrary topic string.  
 */
+ (void)userInterestedIn:(NSString *)topic;


/** @name In-app purchase (IAP) Tracking */

/**
 * Call this method to report IAPs within your application. Note that this API can be leveraged to report standard IAPs
 * as well as those triggered by AdColony’s IAP Promo (IAPP) advertisements and will improve overall ad targeting.
 * @param transactionID An NSString representing the unique SKPaymentTransaction identifier for the IAP. Must be 128 chars or less.
 * @param productID An NSString identifying the purchased product. Must be 128 chars or less.
 * @param quantity An int indicating the number of items.
 * @param price (*optional*) An NSNumber indicating the total price of the items purchased.
 * @param currencyCode (*optional*) An NSString indicating the real-world, three-letter ISO 4217 (e.g. USD) currency code of the transaction.
 * @see onAdColonyIAPRequest:quantity
 */
+ (void)notifyIAPComplete:(NSString *)transactionID productID:(NSString *)productID quantity:(int)quantity price:(nullable NSNumber *)price currencyCode:(nullable NSString *)currencyCode;


/** @name Options */

/** Use this method to set AdColony options.
 * @param option An NSString representing the option.
 * @param value A BOOL indicating whether or not to enable/disable the option.
 */
+ (void)setOption:(NSString *)option value:(BOOL)value;
@end

#pragma mark - User Metadata Constants

/**
 * User metadata keys
 */
extern NSString *const  ADC_SET_USER_AGE;                       /** Set the user's age */
extern NSString *const  ADC_SET_USER_INTERESTS;                 /** Set the user's interests */
extern NSString *const  ADC_SET_USER_GENDER;                    /** Set the user's gender */
extern NSString *const  ADC_SET_USER_LATITUDE;                  /** Set the user's current latitude */
extern NSString *const  ADC_SET_USER_LONGITUDE;                 /** Set the user's current longitude */
extern NSString *const  ADC_SET_USER_ANNUAL_HOUSEHOLD_INCOME;   /** Set the user's annual house hold income in United States Dollars */
extern NSString *const  ADC_SET_USER_MARITAL_STATUS;            /** Set the user's marital status */
extern NSString *const  ADC_SET_USER_EDUCATION;                 /** Set the user's education level */
extern NSString *const  ADC_SET_USER_ZIPCODE;                   /** Set the user's known zip code */

/**
 * User metadata values (for pre-defined values)
 */
extern NSString *const  ADC_USER_MALE;                          /** User is male */
extern NSString *const  ADC_USER_FEMALE;                        /** User is female */

extern NSString *const  ADC_USER_SINGLE;                        /** User is single */
extern NSString *const  ADC_USER_MARRIED;                       /** User is married */

extern NSString *const  ADC_USER_EDUCATION_GRADE_SCHOOL;        /** User has a basic grade school education and has not attended high school */
extern NSString *const  ADC_USER_EDUCATION_SOME_HIGH_SCHOOL;    /** User has completed at least some high school but has not received a diploma */
extern NSString *const  ADC_USER_EDUCATION_HIGH_SCHOOL_DIPLOMA; /** User has received a high school diploma but has not completed any college */
extern NSString *const  ADC_USER_EDUCATION_SOME_COLLEGE;        /** User has completed at least some college but doesn't have a college degree */
extern NSString *const  ADC_USER_EDUCATION_ASSOCIATES_DEGREE;   /** User has been awarded at least 1 associates degree, but doesn't have any higher level degrees */
extern NSString *const  ADC_USER_EDUCATION_BACHELORS_DEGREE;    /** User has been awarded at least 1 bachelors degree, but does not have a graduate level degree */
extern NSString *const  ADC_USER_EDUCATION_GRADUATE_DEGREE;     /** User has been awarded at least 1 masters or doctorate level degree */

NS_ASSUME_NONNULL_END
