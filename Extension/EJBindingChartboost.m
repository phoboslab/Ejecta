#import <Chartboost/Chartboost.h>
// TODO
//#import <Chartboost/CBNewsfeed.h>
//#import <Chartboost/CBAnalytics.h>
//#import <Chartboost/CBInPlay.h>
//#import <AdSupport/AdSupport.h>

#import "EJBindingChartboost.h"

@implementation EJBindingChartboost


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
    if (self = [super initWithContext:ctx argc:argc argv:argv]) {
        if (argc > 1) {
            appId = [JSValueToNSString(ctx, argv[0]) retain];
            appSignature = [JSValueToNSString(ctx, argv[1]) retain];
        }
        else {
            NSLog(@"Error: Must set appId & appSignature");
        }
    }
    return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
    [super createWithJSObject:obj scriptView:view];

    [Chartboost startWithAppId:appId appSignature:appSignature delegate:self];
//    [Chartboost cacheInterstitial:CBLocationHomeScreen];
//    [Chartboost cacheRewardedVideo:CBLocationMainMenu];
//    [Chartboost cacheMoreApps:CBLocationHomeScreen];

}

- (void)dealloc {
    [super dealloc];
}


EJ_BIND_EVENT(interstitialCache);
EJ_BIND_EVENT(interstitialClose);
EJ_BIND_EVENT(interstitialClick);
EJ_BIND_EVENT(interstitialDisplay);
EJ_BIND_EVENT(interstitialError);

EJ_BIND_EVENT(moreAppCache);
EJ_BIND_EVENT(moreAppClose);
EJ_BIND_EVENT(moreAppClick);
EJ_BIND_EVENT(moreAppError);

EJ_BIND_EVENT(videoCache);
EJ_BIND_EVENT(videoClose);
EJ_BIND_EVENT(videoClick);
EJ_BIND_EVENT(videoRewarded);
EJ_BIND_EVENT(videoError);

EJ_BIND_GET(appId, ctx)
{
    return NSStringToJSValue(ctx, appId);
}

EJ_BIND_GET(appSignature, ctx)
{
    return NSStringToJSValue(ctx, appSignature);
}


/*
 * Chartboost API
 */

EJ_BIND_FUNCTION(cacheInterstitial, ctx, argc, argv)
{
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
    return NULL;
}
EJ_BIND_FUNCTION(showInterstitial, ctx, argc, argv)
{
     NSLog(@"show Interstitial");
    [Chartboost showInterstitial:CBLocationHomeScreen];
    return NULL;
}


EJ_BIND_FUNCTION(cacheMoreApps, ctx, argc, argv)
{
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
    return NULL;
}
EJ_BIND_FUNCTION(showMoreApps, ctx, argc, argv)
{
    [Chartboost showMoreApps:scriptView.window.rootViewController location:CBLocationHomeScreen];
    return NULL;
}


EJ_BIND_FUNCTION(cacheVideo, ctx, argc, argv)
{
    [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
    return NULL;
}
EJ_BIND_FUNCTION(showVideo, ctx, argc, argv)
{
    [Chartboost showRewardedVideo:CBLocationMainMenu];
    return NULL;
}


/*
 * Chartboost Delegate Methods
 *
 */


//////////////    Interstitial    ////////////////
- (void)didCacheInterstitial:(NSString *)location {
    NSLog(@"cache Interstitial at location %@", location);
    [self triggerEvent:@"interstitialCache"];
}
- (void)didCloseInterstitial:(NSString *)location {
    NSLog(@"close Interstitial at location %@", location);
    [self triggerEvent:@"interstitialClose"];
}
- (void)didClickInterstitial:(NSString *)location {
    NSLog(@"click Interstitial at location %@", location);
    [self triggerEvent:@"interstitialClick"];
}
- (void)didDisplayInterstitial:(CBLocation)location {
    NSLog(@"Did display Interstitial");
    if ([Chartboost isAnyViewVisible]) {
        [self triggerEvent:@"interstitialDisplay"];
    }
}
- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Interstitial, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Interstitial, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Interstitial, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Interstitial, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Interstitial, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Interstitial, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Interstitial, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Interstitial, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Interstitial, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Interstitial, unknown error !");
        }
    }

    [self triggerEvent:@"interstitialError"];
}



//////////////    MoreApps    ////////////////
- (void)didCacheMoreApps:(NSString *)location {
    NSLog(@"cache MoreApps at location %@", location);
    [self triggerEvent:@"moreAppsCache"];
}
- (void)didCloseMoreApps:(NSString *)location {
    NSLog(@"close MoreApps at location %@", location);
    [self triggerEvent:@"moreAppsClose"];
}
- (void)didClickMoreApps:(NSString *)location {
    NSLog(@"click MoreApps at location %@", location);
    [self triggerEvent:@"moreAppsClick"];
}
- (void)didFailToLoadMoreApps:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load More Apps, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load More Apps, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load More Apps, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load More Apps, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load More Apps, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load More Apps, first session !");
        } break;
        case CBLoadErrorNoAdFound: {
            NSLog(@"Failed to load More Apps, Apps not found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load More Apps, session not started !");
        } break;
        default: {
            NSLog(@"Failed to load More Apps, unknown error !");
        }
    }
    [self triggerEvent:@"moreAppsError"];
}


//////////////    RewardedVideo    ////////////////
- (void)didCacheRewardedVideo:(NSString *)location {
    NSLog(@"cache RewardedVideo at location %@", location);
    [self triggerEvent:@"videoCache"];
}
- (void)didCloseRewardedVideo:(NSString *)location {
    NSLog(@"close RewardedVideo at location %@", location);
    [self triggerEvent:@"videoClose"];
}
- (void)didClickRewardedVideo:(NSString *)location {
    NSLog(@"click RewardedVideo at location %@", location);
    [self triggerEvent:@"videoClick"];
}
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    NSLog(@"completed RewardedVideo view at location %@ with reward amount %d", location, reward);
    [self triggerEvent:@"videoRewarded"];
}
- (void)didFailToLoadRewardedVideo:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Rewarded Video, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Rewarded Video, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Rewarded Video, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Rewarded Video, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Rewarded Video, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Rewarded Video, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Rewarded Video, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Rewarded Video, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Rewarded Video, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Rewarded Video, unknown error !");
        }
    }

    [self triggerEvent:@"videoError"];
}


@end
