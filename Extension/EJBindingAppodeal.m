#import "EJBindingAppodeal.h"

@implementation EJBindingAppodeal


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			appKey = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set appID");
            return self;
		}
        
        loading = false;
        hookBeforeShow = nil;
        hookAfterClose = nil;
        hookAfterClick = nil;
        hookAfterFinish = nil;
        
        adStyle =  @{@"interstitial": @(AppodealShowStyleInterstitial),
                     @"video": @(AppodealShowStyleSkippableVideo),
                     @"videoorinterstitial": @(AppodealShowStyleVideoOrInterstitial),
                     @"bannertop": @(AppodealShowStyleBannerTop),
                     @"bannertop": @(AppodealShowStyleBannerCenter),
                     @"bannertop": @(AppodealShowStyleBannerBottom),
                     @"rewardedvideo": @(AppodealShowStyleRewardedVideo)
                    };

        [Appodeal initializeWithApiKey:appKey types: (AppodealAdType)(AppodealAdTypeAll)];

        [Appodeal setInterstitialDelegate:self];
        [Appodeal setBannerDelegate:self];
        [Appodeal setVideoDelegate:self];
        [Appodeal setRewardedVideoDelegate:self];

	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {

    if (hookBeforeShow) {
        JSValueUnprotect(scriptView.jsGlobalContext, hookBeforeShow);
        hookBeforeShow = nil;
    }

    if (hookAfterClose) {
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterClose);
        hookAfterClose = nil;
    }
    
    if (hookAfterClick) {
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterClick);
        hookAfterClick = nil;
    }
    
    if (hookAfterFinish) {
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterFinish);
        hookAfterFinish = nil;
    }

	[super dealloc];
}



-(void)beforeShowAd {
    if (hookBeforeShow) {
        [scriptView invokeCallback: hookBeforeShow thisObject: NULL argc: 0 argv: NULL];
        JSValueUnprotect(scriptView.jsGlobalContext, hookBeforeShow);
        hookBeforeShow = nil;
    }
}

-(void)afterCloseAd {
    if (hookAfterClose) {
        [scriptView invokeCallback: hookAfterClose thisObject: NULL argc: 0 argv: NULL];
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterClose);
        hookAfterClose = nil;
    }
}

-(void)afterClickAd {
    if (hookAfterClick) {
        [scriptView invokeCallback: hookAfterClick thisObject: NULL argc: 0 argv: NULL];
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterClick);
        hookAfterClick = nil;
    }
}

-(void)afterFinishAd{
    if (hookAfterFinish) {
        [scriptView invokeCallback: hookAfterFinish thisObject: NULL argc: 0 argv: NULL];
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterFinish);
        hookAfterFinish = nil;
    }
}

-(void)afterFinishAd:(NSString *)rewardName rewardAmount:(NSUInteger)rewardAmount{
    if (hookAfterFinish) {
        JSValueRef rewardInfo = NSObjectToJSValue(scriptView.jsGlobalContext,
                            @{
                            @"rewardName": rewardName,
                            @"rewardAmount":@(rewardAmount)
                            });
        JSValueRef params[] = { rewardInfo };

        [scriptView invokeCallback: hookAfterFinish thisObject: NULL argc:1 argv:params];
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterFinish);
        hookAfterFinish = nil;
    }

}

//////////////////////////////////

- (void)interstitialDidLoadAd {
    NSLog(@"interstitialDidLoadAd");
}

- (void)interstitialDidFailToLoadAd {
    NSLog(@"interstitialDidFailToLoadAd");
}

- (void)interstitialWillPresent {
    NSLog(@"interstitial beforeShow");
    [self beforeShowAd];
}

- (void)interstitialDidClick {
    NSLog(@"interstitial onClick");
    [self afterClickAd];
}

- (void)interstitialDidDismiss {
    NSLog(@"interstitial onClose");
    [self afterCloseAd];
}


//////////////////////////////////

- (void)bannerDidLoadAd{
    NSLog(@"bannerDidLoadAd");
}


- (void)bannerDidFailToLoadAd{
    NSLog(@"bannerDidFailToLoadAd");
}


- (void)bannerDidClick{
    NSLog(@"banner onClick");
    [self afterClickAd];
}


//////////////////////////////////

- (void)videoDidLoadAd{
    NSLog(@"videoDidLoadAd");
}

- (void)videoDidFailToLoadAd{
    NSLog(@"videoDidFailToLoadAd");
}

- (void)videoDidPresent{
    NSLog(@"video beforeShow");
    [self beforeShowAd];
}

- (void)videoWillDismiss{
    NSLog(@"video onClose");
    [self afterCloseAd];
}

- (void)videoDidFinish{
    NSLog(@"video onFinish");
    [self afterFinishAd];
}

//////////////////////////////////

- (void)rewardedVideoDidLoadAd{
    NSLog(@"rewardedVideoDidLoadAd");
}

- (void)rewardedVideoDidFailToLoadAd{
    NSLog(@"rewardedVideoDidFailToLoadAd");
}

- (void)rewardedVideoDidPresent{
    NSLog(@"rewardVideo beforeShow");
    [self beforeShowAd];
}

- (void)rewardedVideoWillDismiss{
    NSLog(@"rewardVideo onClose");
    [self afterCloseAd];
}

- (void)rewardedVideoDidFinish:(NSUInteger)rewardAmount name:(NSString *)rewardName{
    NSLog(@"rewardVideo onFinish");
    [self afterFinishAd:rewardName rewardAmount:rewardAmount];
}

//////////////////////////////////


EJ_BIND_GET(appKey, ctx)
{
	return NSStringToJSValue(ctx, appKey);
}

EJ_BIND_GET(autocache, ctx)
{
    BOOL autocache = [Appodeal isAutocacheEnabled:(AppodealAdType)(AppodealAdTypeAll)];
    return JSValueMakeBoolean(ctx, autocache);
}

EJ_BIND_SET(autocache, ctx, value)
{
    BOOL autocache = JSValueToBoolean(ctx, value);
    [Appodeal setAutocache:autocache types:(AppodealAdType)(AppodealAdTypeAll)];
}

EJ_BIND_FUNCTION(cacheAd, ctx, argc, argv)
{
    [Appodeal cacheAd:(AppodealAdType)(AppodealAdTypeAll)];
    return NULL;
}


EJ_BIND_FUNCTION(hideBanner, ctx, argc, argv)
{
    [Appodeal hideBanner];
    return NULL;
}

EJ_BIND_FUNCTION(setDebugEnabled, ctx, argc, argv)
{
    BOOL debug = JSValueToBoolean(ctx, argv[0]);
    [Appodeal setDebugEnabled:debug];
    return NULL;
}


EJ_BIND_FUNCTION(isReady, ctx, argc, argv)
{
    
    NSString * style=[JSValueToNSString(ctx, argv[0]) lowercaseString];
    if (!style){
        style = @"interstitial";
    }
    
    NSInteger showStyle = [adStyle objectForKey:style];
    if (!showStyle){
        showStyle = AppodealShowStyleInterstitial;
    }

    BOOL ready = [Appodeal isReadyForShowWithStyle:showStyle];
    return JSValueMakeBoolean(ctx, ready);
}


EJ_BIND_FUNCTION(show, ctx, argc, argv)
{

    if (hookBeforeShow) {
        JSValueUnprotect(scriptView.jsGlobalContext, hookBeforeShow);
        hookBeforeShow = nil;
    }
    
    if (hookAfterClose) {
        JSValueUnprotect(scriptView.jsGlobalContext, hookAfterClose);
        hookAfterClose = nil;
    }

    NSString * style=[JSValueToNSString(ctx, argv[0]) lowercaseString];
    if (!style){
        style = @"interstitial";
    }
    
    NSInteger showStyle = [adStyle objectForKey:style];
    if (!showStyle){
        showStyle = AppodealShowStyleInterstitial;
    }
    
    
    NSMutableDictionary* options = nil;
    
    JSObjectRef jsOptions;
    if (argc > 1){
        jsOptions = JSValueToObject(ctx, argv[1], NULL);
        NSDictionary *inOptions = (NSDictionary *)JSValueToNSObject(ctx, jsOptions);
        NSEnumerator *keys = [inOptions keyEnumerator];
        options = [NSMutableDictionary new];
        id keyId;
        while ((keyId = [keys nextObject])) {
            NSString *key = (NSString *)keyId;
            NSString *value = (NSString *)[inOptions objectForKey:keyId];
            NSLog(@"key : %@, value: %@", key, value);
            
            if ([key isEqualToString:@"beforeShow"]){
                JSStringRef funcName = JSStringCreateWithUTF8CString("beforeShow");
                JSValueRef jsFunc = JSObjectGetProperty(ctx, jsOptions, funcName, NULL);
                JSStringRelease(funcName);
                
                hookBeforeShow = JSValueToObject(ctx, jsFunc, NULL);
                JSValueProtect(ctx, hookBeforeShow);

            }else if ([key isEqualToString:@"afterClose"]){
                JSStringRef funcName = JSStringCreateWithUTF8CString("afterClose");
                JSValueRef jsFunc = JSObjectGetProperty(ctx, jsOptions, funcName, NULL);
                JSStringRelease(funcName);
                
                hookAfterClose = JSValueToObject(ctx, jsFunc, NULL);
                JSValueProtect(ctx, hookAfterClose);

            }else if ([key isEqualToString:@"afterClick"]){
                JSStringRef funcName = JSStringCreateWithUTF8CString("afterClick");
                JSValueRef jsFunc = JSObjectGetProperty(ctx, jsOptions, funcName, NULL);
                JSStringRelease(funcName);
                
                hookAfterClick = JSValueToObject(ctx, jsFunc, NULL);
                JSValueProtect(ctx, hookAfterClick);

            }else if ([key isEqualToString:@"afterFinish"]){
                JSStringRef funcName = JSStringCreateWithUTF8CString("afterFinish");
                JSValueRef jsFunc = JSObjectGetProperty(ctx, jsOptions, funcName, NULL);
                JSStringRelease(funcName);
                
                hookAfterFinish = JSValueToObject(ctx, jsFunc, NULL);
                JSValueProtect(ctx, hookAfterFinish);
                
            }
        }
    }

//    [self beforeShowAd];

    if (options){
        [Appodeal showAd:showStyle rootViewController:scriptView.window.rootViewController];
        [options release];
    }else{
        [Appodeal showAd:showStyle rootViewController:scriptView.window.rootViewController];
    }


    return scriptView->jsTrue;

}



@end
