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


EJ_BIND_EVENT(cache);
EJ_BIND_EVENT(display);
EJ_BIND_EVENT(click);
EJ_BIND_EVENT(rewarded);
EJ_BIND_EVENT(close);
EJ_BIND_EVENT(error);


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




EJ_BIND_GET(autoCache, ctx)
{
    return JSValueMakeBoolean(ctx, [Chartboost getAutoCacheAds]);
}

EJ_BIND_SET(autoCache, ctx, value)
{
    BOOL autoCache = JSValueToBoolean(ctx, value);
    [Chartboost setAutoCacheAds:autoCache];
}

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

- (NSString *)getErrorMessage:(CBLoadError)error {
    NSString *message = nil;
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            message = @"No Internet connection !";
        } break;
        case CBLoadErrorInternal: {
            message = @"Internal error !";
        } break;
        case CBLoadErrorNetworkFailure: {
            message = @"Network error !";
        } break;
        case CBLoadErrorWrongOrientation: {
            message = @"Wrong orientation !";
        } break;
        case CBLoadErrorTooManyConnections: {
            message = @"Too many connections !";
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            message = @"First session !";
        } break;
        case CBLoadErrorNoAdFound : {
            message = @"No ad found !";
        } break;
        case CBLoadErrorSessionNotStarted : {
            message = @"Session not started !";
        } break;
        case CBLoadErrorNoLocationFound : {
            message = @"Missing location parameter !";
        } break;
        default: {
            message = @"Unknown error !";
        }
    }
    return message;
}


//////////////    Interstitial    ////////////////
- (void)didCacheInterstitial:(NSString *)location {
    #if DEBUG
        NSLog(@"cache Interstitial at location %@", location);
    #endif
    [self triggerEvent:@"cache" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseInterstitial:(NSString *)location {
    #if DEBUG
        NSLog(@"close Interstitial at location %@", location);
    #endif
    [self triggerEvent:@"close" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickInterstitial:(NSString *)location {
    #if DEBUG
        NSLog(@"click Interstitial at location %@", location);
    #endif
    [self triggerEvent:@"click" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didDisplayInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Did display Interstitial");
    #endif
    if ([Chartboost isAnyViewVisible]) {
        [self triggerEvent:@"display" properties:(JSEventProperty[]){
            {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
            {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
            {NULL, NULL}
        }];
    }
}
- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load Interstitial: %@",message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];

}



//////////////    MoreApps    ////////////////
- (void)didCacheMoreApps:(NSString *)location {
    #if DEBUG
        NSLog(@"cache MoreApps at location %@", location);
    #endif
    [self triggerEvent:@"cache" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseMoreApps:(NSString *)location {
    #if DEBUG
        NSLog(@"close MoreApps at location %@", location);
    #endif
    [self triggerEvent:@"close" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickMoreApps:(NSString *)location {
    #if DEBUG
        NSLog(@"click MoreApps at location %@", location);
    #endif
    [self triggerEvent:@"click" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didFailToLoadMoreApps:(CBLoadError)error {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load MoreApps: %@",message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];
}


//////////////    RewardedVideo    ////////////////
- (void)didCacheRewardedVideo:(NSString *)location {
    #if DEBUG
        NSLog(@"cache RewardedVideo at location %@", location);
    #endif
    [self triggerEvent:@"cache" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseRewardedVideo:(NSString *)location {
    #if DEBUG
        NSLog(@"close RewardedVideo at location %@", location);
    #endif
    [self triggerEvent:@"close" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickRewardedVideo:(NSString *)location {
    #if DEBUG
        NSLog(@"click RewardedVideo at location %@", location);
    #endif
    [self triggerEvent:@"click" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    #if DEBUG
        NSLog(@"completed RewardedVideo view at location %@ with reward amount %d", location, reward);
    #endif
    [self triggerEvent:@"rewarded" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {"reward", JSValueMakeNumber(scriptView.jsGlobalContext, reward)},
        {NULL, NULL}
    }];
}
- (void)didFailToLoadRewardedVideo:(NSString *)location withError:(CBLoadError)error {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load RewardedVideo: %@",message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];
}


@end
