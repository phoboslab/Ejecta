/*
 *  AdColonyAdInfo.h
 *  adc-ios-sdk
 *
 *  Created by Owain Moss on 11/25/14.
 */

#pragma mark - Constants

/**
 * Enum for in-app purchase (IAP) engagement types
 */
typedef NS_ENUM(NSUInteger, ADCOLONY_IAP_ENGAGEMENT) {
    ADCOLONY_IAP_ENGAGEMENT_NONE = 0,    /** IAPP was not enabled for the associated ad object. */
    ADCOLONY_IAP_ENGAGEMENT_AUTOMATIC,   /** IAPP was enabled for the ad; however, there was no user engagement. */
    ADCOLONY_IAP_ENGAGEMENT_END_CARD,    /** IAPP was enabled for the ad, and the user engaged via a dynamic end card (DEC). */
    ADCOLONY_IAP_ENGAGEMENT_OVERLAY      /** IAPP was enabled for the ad, and the user engaged via an in-vdeo engagement (Overlay). */
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AdColonyAdInfo interface

/**
 * AdColonyAdInfo objects are passed to the `[AdColonyAdDelegate onAdColonyAdFinishedWithInfo:]` callback of AdColonyAdDelegates.
 * These objects can be queried for useful information about the ad such as the associated zone ID, whether or 
 * not the ad was shown, or any relevant In-App Purchase Promo (IAPP)-related information.
 */
@interface AdColonyAdInfo : NSObject

/** @name Properties */

/**
 * Whether or not the associated ad was shown.
 * @param shown A BOOL indicating whether or not the ad was actually shown.
 */
@property (nonatomic, readonly) BOOL shown;

/**
 * The associated ad's unique zone identifier.
 * @param zoneID An NSString representing the ad's zone ID.
 */
@property (nonatomic, readonly) NSString *zoneID;

/**
 * Whether or not the associated ad was an IAPP.
 * @param iapEnabled A BOOL indicating whether or not the ad is an IAPP.
 */
@property (nonatomic, readonly) BOOL iapEnabled;

/**
 * The product identifier for the associated ad's IAP as it is defined in iTunesConnect.
 * @param iapProductID An NSString representing the product ID.
 */
@property (nonatomic, readonly) NSString *iapProductID;

/**
 * The number of items to be purchased.
 * @param iapQuantity An int denoting the number of items the user wishes to purchase.
 */
@property (nonatomic, readonly) int iapQuantity;

/**
 * If an IAP was triggered in the associated ad, this property will contain the engagement type.
 * @param iapEngagementType An `ADCOLONY_IAP_ENGAGEMENT` indicating the engagement mechanism.
 */
@property (nonatomic, readonly) ADCOLONY_IAP_ENGAGEMENT iapEngagementType;
@end

NS_ASSUME_NONNULL_END
