#import <Chartboost/Chartboost.h>
#import <Chartboost/CBInPlay.h>
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
	[Chartboost setAutoCacheAds:autoLoad];

}

- (void)dealloc {
    [super dealloc];
}



/*
 * Chartboost Delegate Methods
 *
 */

//shouldDisplayInterstitial
//didDisplayInterstitial
//didDismissInterstitial
//didCloseInterstitial
//didClickInterstitial
//
//shouldDisplayRewardedVideo
//didDisplayRewardedVideo
//didDismissRewardedVideo
//didCloseRewardedVideo
//didClickRewardedVideo
//didCompleteRewardedVideo
//willDisplayVideo
//
//shouldDisplayMoreApps
//didDisplayMoreApps
//didDismissMoreApps
//didCloseMoreApps
//didClickMoreApps

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
- (void)didCacheInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Cache Interstitial at location %@", location);
    #endif
    [self triggerEventOnce:@"interstitial_onLoad" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Close Interstitial at location %@", location);
    #endif
    [self triggerEventOnce:@"interstitial_onClose" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"Interstitial")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickInterstitial:(CBLocation)location {
    #if DEBUG
        NSLog(@"Click Interstitial at location %@", location);
    #endif
    [self triggerEventOnce:@"interstitial_onClick" properties:(JSEventProperty[]){
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
        [self triggerEventOnce:@"interstitial_onDisplay" properties:(JSEventProperty[]){
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
    [self triggerEventOnce:@"interstitial_onFail" properties:(JSEventProperty[]){
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
    [self triggerEventOnce:@"moreApps_onLoad" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseMoreApps:(CBLocation)location {
    #if DEBUG
        NSLog(@"Close MoreApps at location %@", location);
    #endif
    [self triggerEventOnce:@"moreApps_onClose" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"MoreApps")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickMoreApps:(CBLocation)location {
    #if DEBUG
        NSLog(@"Click MoreApps at location %@", location);
    #endif
    [self triggerEventOnce:@"moreApps_onClick" properties:(JSEventProperty[]){
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
    [self triggerEventOnce:@"moreApps_onFail" properties:(JSEventProperty[]){
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
    [self triggerEventOnce:@"rewardedVideo_onLoad" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCloseRewardedVideo:(CBLocation)location {
    #if DEBUG
        NSLog(@"Close RewardedVideo at location %@", location);
    #endif
    [self triggerEventOnce:@"rewardedVideo_onClose" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
//        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didClickRewardedVideo:(CBLocation)location {
    #if DEBUG
        NSLog(@"Click RewardedVideo at location %@", location);
    #endif
    [self triggerEventOnce:@"rewardedVideo_onClick" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}

- (void)didDisplayRewardedVideo:(CBLocation)location {
#if DEBUG
    NSLog(@"Did display RewardedVideo");
#endif
//    if ([Chartboost isAnyViewVisible]) {
//        [self triggerEventOnce:@"rewardedVideo_onDisplay" properties:(JSEventProperty[]){
//            {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
//            {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
//            {NULL, NULL}
//        }];
//    }
}

- (void)willDisplayVideo:(CBLocation)location {
#if DEBUG
    NSLog(@"Will Display RewardedVideo");
#endif
    [self triggerEventOnce:@"rewardedVideo_onDisplay" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {NULL, NULL}
    }];
}
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    #if DEBUG
        NSLog(@"completed RewardedVideo view at location %@ with reward amount %d", location, reward);
    #endif
    [self triggerEventOnce:@"rewardedVideo_onFinish" properties:(JSEventProperty[]){
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
    [self triggerEventOnce:@"rewardedVideo_onFail" properties:(JSEventProperty[]){
        {"adType", NSStringToJSValue(scriptView.jsGlobalContext, @"RewardedVideo")},
        {"location", NSStringToJSValue(scriptView.jsGlobalContext, location)},
        {"message",NSStringToJSValue(scriptView.jsGlobalContext, message)},
        {NULL, NULL}
    }];
}


//////////////////////////////////////////
//////////////////////////////////////////


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



EJ_BIND_GET(autoLoad, ctx)
{
	return JSValueMakeBoolean(ctx, [Chartboost getAutoCacheAds]);
}

EJ_BIND_SET(autoLoad, ctx, value)
{
	autoLoad = JSValueToBoolean(ctx, value);
	[Chartboost setAutoCacheAds:autoLoad];
}



-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	NSString *location = CBLocationDefault;
	
	if ([options objectForKey:@"location"]) {
		location = [options objectForKey:@"location"];
	}
	
	if ([type isEqualToString:@"interstitial"]){
		if ([Chartboost hasInterstitial:location]){
			[Chartboost showInterstitial:location];
			return true;
		}
	}else if ([type isEqualToString:@"moreApps"]){
		if ([Chartboost hasMoreApps:location]){
			[Chartboost showMoreApps:scriptView.window.rootViewController location:location];
			return true;
		}
	}else if ([type isEqualToString:@"rewardedVideo"]){
		if ([Chartboost hasRewardedVideo:location]){
			[Chartboost showRewardedVideo:location];
			return true;
		}
	}
	
	return false;
	
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	NSString *location = CBLocationDefault;
	
	if ([options objectForKey:@"location"]) {
		location = [options objectForKey:@"location"];
	}
	
	if ([type isEqualToString:@"interstitial"]){
		return [Chartboost hasInterstitial:location];
	}else if ([type isEqualToString:@"moreApps"]){
		return [Chartboost hasMoreApps:location];
	}else if ([type isEqualToString:@"rewardedVideo"]){
		return [Chartboost hasRewardedVideo:location];
	}
	
	return false;
	
}

-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	NSString *location = CBLocationDefault;
	
	if ([options objectForKey:@"location"]) {
		location = [options objectForKey:@"location"];
	}
	
	if ([type isEqualToString:@"interstitial"]){
		[Chartboost cacheInterstitial:location];
	}else if ([type isEqualToString:@"moreApps"]){
		[Chartboost cacheMoreApps:location];
	}else if ([type isEqualToString:@"rewardedVideo"]){
		[Chartboost cacheRewardedVideo:location];
	}else{
		return false;
	}
	
	return true;
}

@end
