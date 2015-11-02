/*
 * CBAnalytics.h
 * Chartboost
 * 6.0.1
 *
 * Copyright 2011 Chartboost. All rights reserved.
 */

#import <StoreKit/StoreKit.h>

/*!
 @typedef NS_ENUM (NSUInteger, CBLevelType)
 
 @abstract
 Used with trackLevelInfo calls to describe meta information about the level value as it 
 pertains to the game's context.
 */
typedef NS_ENUM(NSUInteger, CBLevelType) {
    /*! Highest level reached */
    HIGHEST_LEVEL_REACHED = 1,
    /*! Current area level reached */
    CURRENT_AREA = 2,
    /*! Current character level reached */
    CHARACTER_LEVEL = 3,
    /*! Other sequential level reached */
    OTHER_SEQUENTIAL = 4,
    /*! Current non sequential level reached */
    OTHER_NONSEQUENTIAL = 5
};

/*!
 @class ChartboostAnalytics
 
 @abstract
 Provide methods to track various events for improved targeting.
 
 @discussion For more information on integrating and using the Chartboost SDK
 please visit our help site documentation at https://help.chartboost.com
 */
@interface CBAnalytics : NSObject

/*!
 @abstract
 Track an In App Purchase Event.

 @param receipt The transaction receipt used to validate the purchase.
 
 @param productTitle The localized title of the product.
 
 @param productDescription The localized description of the product.
 
 @param productPrice The price of the product.
 
 @param productCurrency The localized currency of the product.
 
 @param productIdentifier The IOS identifier for the product.

 @discussion Tracks In App Purchases for later use with user segmentation
 and targeting.
*/
+ (void)trackInAppPurchaseEvent:(NSData *)receipt
                   productTitle:(NSString *)productTitle
             productDescription:(NSString *)productDescription
                   productPrice:(NSDecimalNumber *)productPrice
                productCurrency:(NSString *)productCurrency
              productIdentifier:(NSString *)productIdentifier;

/*!
 @abstract
 Track an In App Purchase Event.

 @param receiptString The base64 encoded receipt string used to validate the purchase.
 
 @param productTitle The localized title of the product.
 
 @param productDescription The localized description of the product.
 
 @param productPrice The price of the product.
 
 @param productCurrency The localized currency of the product.
 
 @param productIdentifier The IOS identifier for the product.

 @discussion Tracks In App Purchases for later use with user segmentation
 and targeting.
*/
+ (void)trackInAppPurchaseEventWithString:(NSString *)receiptString
                   productTitle:(NSString *)productTitle
             productDescription:(NSString *)productDescription
                   productPrice:(NSDecimalNumber *)productPrice
                productCurrency:(NSString *)productCurrency
              productIdentifier:(NSString *)productIdentifier;
/*!
 @abstract
 Track an In App Purchase Event.
 
 @param receipt The transaction receipt used to validate the purchase.
 
 @param product The SKProduct that was purchased.
 
 @discussion Tracks In App Purchases for later use with user segmentation
 and targeting.
 */
+ (void)trackInAppPurchaseEvent:(NSData *)receipt
                        product:(SKProduct *)product;


/*!
 @abstract
 Track level information about your user. Can be sequential levelling, non-sequential levelling, character level, or other. 
 
 @param eventLabel A string that disambiguates the eventField. Use it to provides a human readable string to answer the question - What are we tracking ?
 
 @param eventField any value from the CBLevelType enumeration. Specifies whether this event is tracking a sequential levelling, non-sequential levelling, a character level, or other.
 
 @param mainLevel integer value to be tracked that represents the main level
 
 @param subLevel integer value to be tracked that represents the sub level, 0 if no relevant sub-level
 
 @param description A string that disambiguates the mainLevel & subLevel. Use it to provide a human readable string to answer the question - What does the mainLevel number and subLevel nubmer represent in my game ?
 
 @discussion Tracks In App Purchases for later use with user segmentation
 and targeting.
 */
+ (void)trackLevelInfo:(NSString*)eventLabel
            eventField:(CBLevelType)eventField
             mainLevel:(NSUInteger)mainLevel
              subLevel:(NSUInteger)subLevel
           description:(NSString*)description;

/*!
 @abstract
 Track level information about your user. Can be sequential levelling, non-sequential levelling, character level, or other. 
 
 @param eventLabel A string that disambiguates the eventField. Use it to provides a human readable string to answer the question - What are we tracking ?
 
 @param eventField any value from the CBLevelType enumeration. Specifies whether this event is tracking a sequential levelling, non-sequential levelling, a character level, current area, or other.
 
 @param mainLevel integer value to be tracked that represents the main level
 
 @param description A string that disambiguates the mainLevel. Use it to provide a human readable string to answer the question - What does the mainLevel number represent in my game ?
 
 @discussion Tracks In App Purchases for later use with user segmentation
 and targeting.
 */
+ (void)trackLevelInfo:(NSString*)eventLabel
            eventField:(CBLevelType)eventField
             mainLevel:(NSUInteger)mainLevel
           description:(NSString*)description;

@end
