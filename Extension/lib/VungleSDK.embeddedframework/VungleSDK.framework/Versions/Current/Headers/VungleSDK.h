//
//  VungleSDK.h
//  Vungle iOS SDK
//
//  Created by Rolando Abarca on 11/19/13.
//  Copyright (c) 2013 Vungle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol VungleAssetLoader;

extern NSString* VungleSDKVersion;
extern NSString* VunglePlayAdOptionKeyIncentivized;
extern NSString* VunglePlayAdOptionKeyIncentivizedAlertTitleText;
extern NSString* VunglePlayAdOptionKeyIncentivizedAlertBodyText;
extern NSString* VunglePlayAdOptionKeyIncentivizedAlertCloseButtonText;
extern NSString* VunglePlayAdOptionKeyIncentivizedAlertContinueButtonText;
extern NSString * VunglePlayAdOptionKeyShowClose __deprecated_msg("Set this option on the Vungle dashboard instead.");
extern NSString* VunglePlayAdOptionKeyOrientations;
extern NSString* VunglePlayAdOptionKeyUser;
extern NSString* VunglePlayAdOptionKeyPlacement;
extern NSString* VunglePlayAdOptionKeyExtraInfoDictionary;
extern NSString* VunglePlayAdOptionKeyExtra1;
extern NSString* VunglePlayAdOptionKeyExtra2;
extern NSString* VunglePlayAdOptionKeyExtra3;
extern NSString* VunglePlayAdOptionKeyExtra4;
extern NSString* VunglePlayAdOptionKeyExtra5;
extern NSString* VunglePlayAdOptionKeyExtra6;
extern NSString* VunglePlayAdOptionKeyExtra7;
extern NSString* VunglePlayAdOptionKeyExtra8;
extern NSString* VunglePlayAdOptionKeyLargeButtons;

typedef enum {
	VungleSDKErrorInvalidPlayAdOption = 1,
	VungleSDKErrorInvalidPlayAdExtraKey,
	VungleSDKErrorCannotPlayAd
} VungleSDKErrorCode;

@protocol VungleSDKLogger <NSObject>
- (void)vungleSDKLog:(NSString *)message;
@end

@class VungleSDK;

@protocol VungleSDKDelegate <NSObject>
@optional
/**
 * if implemented, this will get called when the SDK is about to show an ad. This point
 * might be a good time to pause your game, and turn off any sound you might be playing.
 */
- (void)vungleSDKwillShowAd;

/**
 * if implemented, this will get called when the SDK closes the ad view, but there might be
 * a product sheet that will be presented. This point might be a good place to resume your game
 * if there's no product sheet being presented. The viewInfo dictionary will contain the
 * following keys:
 * - "completedView": NSNumber representing a BOOL whether or not the video can be considered a
 *               full view.
 * - "playTime": NSNumber representing the time in seconds that the user watched the video.
 * - "didDownlaod": NSNumber representing a BOOL whether or not the user clicked the download
 *                  button.
 */
- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet;

/**
 * if implemented, this will get called when the product sheet is about to be closed.
 */
- (void)vungleSDKwillCloseProductSheet:(id)productSheet;

/**
 * if implemented, this will get called when there is an ad cached and ready to be shown.
 */
- (void)vungleSDKhasCachedAdAvailable __attribute__((deprecated));

/**
 * if implemented, this will get called when the SDK has an ad ready to be displayed. Also it will
 * get called with an argument `NO` when for some reason, there's no ad available, for instance
 * there is a corrupt ad or the OS wiped the cache.
 * Please note that receiving a `NO` here does not mean that you can't play an Ad: if you haven't
 * opted-out of our Exchange, you might be able to get a streaming ad if you call `play`.
 */
- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable;

@end

@interface VungleSDK : NSObject
@property (strong) NSDictionary* userData;
@property (strong) id<VungleSDKDelegate> delegate;
@property (strong) id<VungleAssetLoader> assetLoader;
@property (assign) BOOL muted;
@property (readonly) NSMutableDictionary* globalOptions;

/**
 * Returns the singleton instance.
 */
+ (VungleSDK *)sharedSDK;

/**
 * Setup the SDK with an asset loader. This must be called before any call to shareSDK in order
 * to properly set the asset loader.
 */
+ (VungleSDK *)setupSDKWithAssetLoader:(id<VungleAssetLoader>)loader;

/**
 * Initializes the SDK. You can get your app id on Vungle's dashboard: https://v.vungle.com
 */
- (void)startWithAppId:(NSString *)appId;

/**
 * Will play an ad, presenting the view over the passed viewController as a modal.
 * @deprecated This method is deprecated starting in version 3.0.11
 * @note Please use instead:
 * @code playAd:error:
 */
- (void)playAd:(UIViewController *)viewController __attribute__((deprecated));

/**
 * Will play an ad, presenting the view over the passed viewController as a modal.
 * Pass options to decide what type of ad to show.
 * @deprecated This method is deprecated starting in version 3.0.11
 * @note Please use instead:
 * @code playAd:withOptions:error:
 */
- (void)playAd:(UIViewController *)viewController withOptions:(id)options __attribute__((deprecated));

/**
 * Will play an ad, presenting the view over the passed viewController as a modal.
 * Return an error if there is one.
 */
- (BOOL)playAd:(UIViewController *)viewController error:(NSError **)error;

/**
 * Will play an ad, presenting the view over the passed viewController as a modal.
 * Pass options to decide what type of ad to show. Return an error if there is one.
 */
- (BOOL)playAd:(UIViewController *)viewController withOptions:(id)options error:(NSError **)error;

/**
 * returns YES if there's a valid ad ready to play.
 */
- (BOOL)isCachedAdAvailable __attribute__((deprecated));

/**
 * returns `YES` when there is certainty that an add will be able to play. Returning `NO`, you can
 * still try to play and get a streaming Ad.
 */
- (BOOL)isAdPlayable;

/**
 * Returns debug info.
 */
- (NSDictionary *)debugInfo;

/**
 * by default, logging is off.
 */
- (void)setLoggingEnabled:(BOOL)enable;

/**
 * Log a new message. The message will be sent to all loggers.
 */
- (void)log:(NSString *)message, ...NS_FORMAT_FUNCTION(1,2);

/**
 * Attach a new logger. It will get called on every log generated by Vungle (internally and externally).
 */
- (void)attachLogger:(id<VungleSDKLogger>)logger;

/**
 * Detaches a logger. Make sure to do this, otherwise you might leak memory.
 */
- (void)detachLogger:(id<VungleSDKLogger>)logger;

/**
 * this only works on the simulator
 */
- (void)clearCache;

/**
 * this also only works on the simulator
 */
- (void)clearSleep;

@end
