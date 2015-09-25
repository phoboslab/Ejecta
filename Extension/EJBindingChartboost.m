#import <Chartboost/Chartboost.h>
#import <Chartboost/CBInPlay.h>
// TODO
//#import <Chartboost/CBNewsfeed.h>
//#import <Chartboost/CBAnalytics.h>
//#import <Chartboost/CBInPlay.h>
//#import <AdSupport/AdSupport.h>

#import "EJBindingChartboost.h"

#define ICON_DEFAULT_JPEG_QUALITY 0.9
#define ICON_DATA_URL_PREFIX_JPEG @"data:image/jpeg;base64,"
#define ICON_DATA_URL_PREFIX_PNG @"data:image/png;base64,"

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


}

- (void)dealloc {
    [super dealloc];
}


EJ_BIND_EVENT(loaded);
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



EJ_BIND_FUNCTION(hasInterstitial, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    bool loaded = [Chartboost hasInterstitial:location];

    return JSValueMakeBoolean(scriptView.jsGlobalContext, loaded);
}

EJ_BIND_FUNCTION(loadInterstitial, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    [Chartboost cacheInterstitial:location];
    return NULL;
}

EJ_BIND_FUNCTION(showInterstitial, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    if ([Chartboost hasInterstitial:location]){
        [Chartboost showInterstitial:location];
        return JSValueMakeBoolean(scriptView.jsGlobalContext, true);
    }
    return NULL;
}


// MoreApps can't use custom location, location always be CBLocationHomeScreen.

EJ_BIND_FUNCTION(hasMoreApps, ctx, argc, argv)
{
    NSString *location = CBLocationHomeScreen;

    bool loaded = [Chartboost hasMoreApps:location];

    return JSValueMakeBoolean(scriptView.jsGlobalContext, loaded);
}

EJ_BIND_FUNCTION(loadMoreApps, ctx, argc, argv)
{
    NSString *location = CBLocationHomeScreen;

    [Chartboost cacheMoreApps:location];
    return NULL;
}

EJ_BIND_FUNCTION(showMoreApps, ctx, argc, argv)
{
    NSString *location = CBLocationHomeScreen;

    if ([Chartboost hasMoreApps:location]){
        [Chartboost showMoreApps:scriptView.window.rootViewController location:location];
        return JSValueMakeBoolean(scriptView.jsGlobalContext, true);
    }
    return NULL;
}



EJ_BIND_FUNCTION(hasRewardedVideo, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    bool loaded = [Chartboost hasRewardedVideo:location];

    return JSValueMakeBoolean(scriptView.jsGlobalContext, loaded);
}

EJ_BIND_FUNCTION(loadRewardedVideo, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    [Chartboost cacheRewardedVideo:location];
    return NULL;
}

EJ_BIND_FUNCTION(showRewardedVideo, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    if ([Chartboost hasRewardedVideo:location]){
        [Chartboost showRewardedVideo:location];
        return JSValueMakeBoolean(scriptView.jsGlobalContext, true);
    }
    return NULL;
}




EJ_BIND_FUNCTION(hasInPlay, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    bool loaded = [Chartboost hasInPlay:location];

    return JSValueMakeBoolean(scriptView.jsGlobalContext, loaded);
}

EJ_BIND_FUNCTION(loadInPlay, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    [Chartboost cacheInPlay:location];
    return NULL;
}

EJ_BIND_FUNCTION(getInPlay, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    if ([Chartboost hasInPlay:location]){
        CBInPlay *inPlay = [Chartboost getInPlay:location];
        if (inPlay) {
            #if DEBUG
                NSLog(@"Success, we have a valid inPlay item");
            #endif
            return [self inPlayToJSInPlay:inPlay];
        }
    }
    return NULL;
}

EJ_BIND_FUNCTION(clearInPlay, ctx, argc, argv)
{
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    if ([Chartboost hasInPlay:location]){
        CBInPlay *inPlay = [Chartboost getInPlay:location];
        [inPlay clearCache];
        return JSValueMakeBoolean(scriptView.jsGlobalContext, true);
    }
    return NULL;
}

EJ_BIND_FUNCTION(inPlayDisplayed, ctx, argc, argv){
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    if ([Chartboost hasInPlay:location]){
        CBInPlay *inPlay = [Chartboost getInPlay:location];
        if (inPlay) {
            [inPlay show];
            return JSValueMakeBoolean(scriptView.jsGlobalContext, true);
        }
    }
    return NULL;
}

EJ_BIND_FUNCTION(inPlayClicked, ctx, argc, argv){
    NSString *location = CBLocationDefault;
    if (argc > 0) {
        location = [JSValueToNSString(ctx, argv[0]) retain];
    }
    if ([Chartboost hasInPlay:location]){
        CBInPlay *inPlay = [Chartboost getInPlay:location];
        if (inPlay) {
            [inPlay click];
            return JSValueMakeBoolean(scriptView.jsGlobalContext, true);
        }
    }
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


-(JSValueRef)inPlayToJSInPlay:(CBInPlay *)inPlay{
    UIImage *appIconImage = [UIImage imageWithData:inPlay.appIcon];
    NSData *raw = UIImagePNGRepresentation(appIconImage);
    NSString *encoded = [ICON_DATA_URL_PREFIX_PNG stringByAppendingString:[raw base64EncodedStringWithOptions:0]];
    JSValueRef jsInPlay = NSObjectToJSValue(scriptView.jsGlobalContext, @{
           @"appName": inPlay.appName,
           @"appIconDataURL": encoded,
           @"location": inPlay.location
       });
    return jsInPlay;
}

//////////////    Interstitial    ////////////////
- (void)didCacheInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Cache Interstitial at location %@", location);
    #endif
    [self triggerEvent:@"loaded" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Close Interstitial at location %@", location);
    #endif
    [self triggerEvent:@"close" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Click Interstitial at location %@", location);
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
- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load Interstitial: %@", message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];

}



//////////////    MoreApps    ////////////////
- (void)didCacheMoreApps:(CBLocation)location {
    #if DEBUG
        NSLog(@"Cache MoreApps at location %@", location);
    #endif
    [self triggerEvent:@"loaded" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseMoreApps:(CBLocation)location {
    #if DEBUG
        NSLog(@"Close MoreApps at location %@", location);
    #endif
    [self triggerEvent:@"close" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickMoreApps:(CBLocation)location {
    #if DEBUG
        NSLog(@"Click MoreApps at location %@", location);
    #endif
    [self triggerEvent:@"click" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didFailToLoadMoreApps:(CBLoadError)error forLocation:(CBLocation)location {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load MoreApps: %@", message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];
}


//////////////    RewardedVideo    ////////////////
- (void)didCacheRewardedVideo:(CBLocation)location {
    #if DEBUG
        NSLog(@"Cache RewardedVideo at location %@", location);
    #endif
    [self triggerEvent:@"loaded" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseRewardedVideo:(CBLocation)location {
    #if DEBUG
        NSLog(@"Close RewardedVideo at location %@", location);
    #endif
    [self triggerEvent:@"close" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickRewardedVideo:(CBLocation)location {
    #if DEBUG
        NSLog(@"Click RewardedVideo at location %@", location);
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
- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load RewardedVideo: %@", message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];
}

//////////////    InPlay    ////////////////
- (void)didCacheInPlay:(CBLocation)location {
    #if DEBUG
        NSLog(@"Successfully cached InPlay");
    #endif
//    JSValueRef jsInPlay = NULL;
//    CBInPlay *inPlay = [Chartboost getInPlay:location];
//    if (inPlay) {
//        NSLog(@"InPlay appName: %@", inPlay.appName);
//        jsInPlay = [self inPlayToJSInPlay:inPlay];
//    }

    [self triggerEvent:@"loaded" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"InPlay")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
//        {"data", jsInPlay},
        {NULL, NULL}
    }];
}

- (void)didFailToLoadInPlay:(CBLocation)location withError:(CBLoadError)error {
    NSString *message = [self getErrorMessage:error];
    #if DEBUG
        NSLog(@"Faild to load InPlay: %@", message);
    #endif
    [self triggerEvent:@"error" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"InPlay")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];
}


@end
