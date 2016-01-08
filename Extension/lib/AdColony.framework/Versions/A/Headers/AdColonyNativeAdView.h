/*
 *  AdColonyNativeAdView.h
 *  adc-ios-sdk
 *
 *  Created by John Fernandes-Salling on 11/21/13.
 */

#import <UIKit/UIKit.h>

#pragma mark - Forward Declarations

@protocol AdColonyNativeAdDelegate;
@class AdColonyAdInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AdColonyNativeAdView

/**
 * The AdColonyNativeAdView is used to display non-fullscreen AdColony ads in a fashion that matches the look-and-feel of your application;
 * it contains the video and enegagement components of the native ad and manages the display and playback of the video.
 * The native ad has an accompanying delegate if you need information about the video starting, finishing, or any user interactions with the ad.
 * The object also exposes additional information about the advertisement that is intended to be displayed alongside the video.
 * The native ad may include a engagement button which it displays beneath the video; the appearance of this button is customizable.
 * Instances of this class should not be initialized directly; instead, use `[AdColony getNativeAdForZone:presentingViewController:]`.
 */
@interface AdColonyNativeAdView : UIView

/** @name Delegate */

/**
 * The delegate for the AdColonyNativeAd, which will receive callbacks about the video starting, finishing, and user interactions with the ad.
 * Setting this property is optional; in many cases the callbacks provided by the delegate are not required to create a good user experience.
 * @param delegate The AdColonyNativeAdDelegate.
 */
@property (nonatomic, weak, nullable) id<AdColonyNativeAdDelegate> delegate;

/** @name Creative Content and User Interface */

/**
 * The name of the advertiser for this ad. Approximately 25 characters.
 * AdColony requires this to be displayed alongside the AdColonyNativeAdView.
 * @param advertiserName The name of this ad's advertiser.
 */
@property (nonatomic, readonly) NSString* advertiserName;

/**
 * The advertiser's icon for this ad (may be `nil`). Typically 200x200 pixels for Retina display at up to 100x100 screen points.
 * Display of this image is optional.
 * @param advertiserIrcon The icon of this ad's advertiser.
 */
@property (nonatomic, readonly, nullable) UIImage* advertiserIcon;

/**
 * A short title for this ad. Approximately 25 characters.
 * Display of this string is optional.
 * @param adTitle The title of this ad.
 */
@property (nonatomic, readonly) NSString* adTitle;

/**
 * A mid-length description of this ad. Up to approximately 90 characters.
 * Display of this string is optional.
 * @param adDescription The description of this ad.
 */
@property (nonatomic, readonly) NSString* adDescription;

/**
 * The engagement button for this ad (may be `nil`). This is automatically displayed beneath the video component.
 * Use this property to access the UIButton and customize anything about it except its title text and tap action.
 * @param engagementButton The engagement button that is already embedded within this ad.
 */
@property (nonatomic, nullable) UIButton* engagementButton;

/**
 * Returns the recommended height for the AdColonyNativeAdView if it will be displayed at the specified width.
 * When calculating a frame for the AdColonyNativeAdView, use the recommended height for your chosen width in order to minimize padding space around the video.
 * @param width The display width for which this method will return the best display height.
 * @return The best display height for the desired width.
 */
-(CGFloat)recommendedHeightForWidth:(CGFloat)width;

/** @name Audio */

/**
 * The volume level of the video component of the ad. Defaults to 0.05f.
 * @param volume Volume
 */
@property (nonatomic) float volume;

/**
 * Whether or not the video component of the ad is muted. Defaults to NO.
 * @param muted Muted
 */
@property (nonatomic) BOOL muted;

/** @name Playback */

/**
 * Pauses the video component of the native ad if it is currently playing.
 * This should be used when the native ad goes off-screen temporarily: for
 * example, when it is contained in a UITableViewCell that has been scrolled
 * off-screen; or when the ad is contained in a UIViewController and that view
 * controller has called the method `viewWillDisappear`.
 * Any use of this method must be paired with a corresponding call to `resume`.
 */
-(void)pause;

/**
 * Resumes the video component of the native ad if it has been paused.
 * This should be used when a native ad that was off-screen temporarily has
 * come back on-screen: for example, when the ad is contained in a UIViewController
 * and that view controller has called the method `viewWillAppear`.
 * This method must be used to undo a previous corresponding call to `pause`.
 */
-(void)resume;
@end

#pragma mark - AdColonyNativeAdDelegate

/**
 * The AdColonyNativeAdDelegate protocol provides callbacks about AdColony's native ad display and user interaction.
 */
@protocol AdColonyNativeAdDelegate <NSObject>
@optional

/**
 * Notifies your app that a native ad has begun displaying its video content in response to being displayed on screen.
 * @param ad The affected native ad view.
 */
-(void)onAdColonyNativeAdStarted:(AdColonyNativeAdView*)ad;

/**
 * Notifies your app that a native ad has been interacted with by a user and is expanding to full-screen playback.
 * Within the callback, apps should implement app-specific code such as turning off app music.
 * @param ad The affected native ad view.
 */
-(void)onAdColonyNativeAdExpanded:(AdColonyNativeAdView*)ad;

/**
 * Notifies your app that a native ad finished displaying its video content.
 * If the native ad was expanded to full-screen, this indicates that the full-screen mode has been exited.
 * Within the callback, apps should implement app-specific code such as resuming app music if it was turned off.
 * @param ad The affected native ad view.
 * @param expanded Whether or not the native ad had been expanded to full-screen by the user.
 */
-(void)onAdColonyNativeAdFinished:(AdColonyNativeAdView*)ad expanded:(BOOL)expanded;

/**
 * Alternative for `[AdColonyNativeAdDelegate onAdColonyNativeAdFinished:expanded]` that passes an AdColonyAdInfo object to the delegate. The AdColonyAdInfo object can be queried
 * for information about the ad session: whether or not the ad was shown, the associated zone ID, whether or not the video was an In-App Purchase Promo (IAPP),
 * the type of engagement that triggered an IAP, etc. If your application is showing IAPP advertisements, you will need to implement this callback
 * instead of `[AdColonyNativeAdDelegate onAdColonyNativeAdFinished:expanded]` so you can decide what action to take once the ad has completed.
 * @param ad The affected native ad view.
 * @param info An AdColonyAdInfo object containing information about the associated ad.
 * @see AdColonyAdInfo
 */
-(void)onAdColonyNativeAd:(AdColonyNativeAdView*)ad finishedWithInfo:(AdColonyAdInfo*)info expanded:(BOOL)expanded;

/**
 * Notifies your app that a native ad was muted or unmuted by a user.
 * @param ad The affected native ad view.
 * @param muted Whether the ad was muted or unmuted.
 */
-(void)onAdColonyNativeAd:(AdColonyNativeAdView*)ad muted:(BOOL)muted;

/**
 * Notifies your app that a user has engaged with the native ad via an in-video engagement mechanism.
 * @param ad The affected native ad view.
 */
-(void)onAdColonyNativeAdEngagementPressed:(AdColonyNativeAdView*)ad expanded:(BOOL)expanded;
@end

NS_ASSUME_NONNULL_END
