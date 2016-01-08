//
//  UnityAds.h
//  Copyright (c) 2012 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define UALOG_LOG(levelName, fmt, ...) if ([[UnityAds sharedInstance] isDebugMode]) NSLog((@"%@ [T:0x%x %@] %s:%d " fmt), levelName, (unsigned int)[NSThread currentThread], ([[NSThread currentThread] isMainThread] ? @"M" : @"S"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define UALOG_ERROR(fmt, ...) UALOG_LOG(@"ERROR", fmt, ##__VA_ARGS__)

#define UALOG_DEBUG(fmt, ...) UALOG_LOG(@"DEBUG", fmt, ##__VA_ARGS__)
#define UAAssert(condition) do { if ([[UnityAds sharedInstance] isDebugMode] && !(condition)) { UALOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)
#define UAAssertV(condition, value) do { if ([[UnityAds sharedInstance] isDebugMode] && !(condition)) { UALOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)

extern NSString * const kUnityAdsRewardItemPictureKey;
extern NSString * const kUnityAdsRewardItemNameKey;

extern NSString * const kUnityAdsOptionNoOfferscreenKey;
extern NSString * const kUnityAdsOptionOpenAnimatedKey;
extern NSString * const kUnityAdsOptionGamerSIDKey;
extern NSString * const kUnityAdsOptionMuteVideoSounds;
extern NSString * const kUnityAdsOptionVideoUsesDeviceOrientation;

@class UnityAds;
@class SKStoreProductViewController;

@protocol UnityAdsDelegate <NSObject>

@required
- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped;

@optional
- (void)unityAdsWillShow;
- (void)unityAdsDidShow;
- (void)unityAdsWillHide;
- (void)unityAdsDidHide;
- (void)unityAdsWillLeaveApplication;
- (void)unityAdsVideoStarted;
- (void)unityAdsFetchCompleted;
- (void)unityAdsFetchFailed;
@end

@interface UnityAds : NSObject

@property (nonatomic, weak) id<UnityAdsDelegate> delegate;

+ (UnityAds *)sharedInstance;
+ (BOOL)isSupported;
+ (NSString *)getSDKVersion;

- (void)setTestDeveloperId:(NSString *)developerId;
- (void)setTestOptionsId:(NSString *)optionsId;
- (void)setDebugMode:(BOOL)debugMode;
- (void)setTestMode:(BOOL)testModeEnabled;
- (void)enableUnityDeveloperInternalTestMode;
- (void)setCampaignDataURL:(NSString *)campaignDataUrl;
- (void)setUnityVersion:(NSString *)unityVersion;

- (BOOL)isDebugMode;
- (BOOL)startWithGameId:(NSString *)gameId andViewController:(UIViewController *)viewController;
- (BOOL)startWithGameId:(NSString *)gameId;
- (BOOL)setViewController:(UIViewController *)viewController;
- (BOOL)canShowAds;
- (BOOL)canShow;
- (BOOL)canShowZone:(NSString *)zoneId;
- (BOOL)setZone:(NSString *)zoneId;
- (BOOL)setZone:(NSString *)zoneId withRewardItem:(NSString *)rewardItemKey;
- (NSString *)getZone;
- (BOOL)show:(NSDictionary *)options;
- (BOOL)show;
- (BOOL)hide;
- (void)stopAll;
- (BOOL)hasMultipleRewardItems;
- (NSArray *)getRewardItemKeys;
- (NSString *)getDefaultRewardItemKey;
- (NSString *)getCurrentRewardItemKey;
- (BOOL)setRewardItemKey:(NSString *)rewardItemKey;
- (void)setDefaultRewardItemAsRewardItem;
- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey;
@end
