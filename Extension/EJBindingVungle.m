#import "EJBindingVungle.h"

@implementation EJBindingVungle


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			appID = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set appID");
            return self;
		}
        
        sdk = [VungleSDK sharedSDK];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [sdk setDelegate:self];
            [sdk startWithAppId:appID];
        }];

	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	[sdk setDelegate:nil];
	[sdk release];
	
	[super dealloc];
}

-(void)vungleSDKwillShowAd {
    NSLog(@"vungleSDKwillShowAd");

    [self triggerEvent:@"video_onDisplay"];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    NSLog(@"vungleSDKwillCloseAdWithViewInfo %d", willPresentProductSheet);

//    "playTime":15,"didDownload":false,"videoLength":15,"completedView":true
	
	BOOL completed = [[viewInfo objectForKey:@"completedView"] boolValue];

    JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,
                                               @{
                                                 @"playTime": [viewInfo objectForKey:@"playTime"],
                                                 @"videoLength": [viewInfo objectForKey:@"videoLength"],
                                                 @"completedView": [viewInfo objectForKey:@"completedView"],
                                                 @"didDownload": [viewInfo objectForKey:@"didDownload"],
                                                 @"willPresentProductSheet": @(willPresentProductSheet)
                                                });
    JSValueRef params[] = { jsViewInfo };
	
	if (completed){
		[self triggerEvent:@"video_onFinish" argc:1 argv:params];
	}else{
		[self triggerEvent:@"video_onClose" argc:1 argv:params];
	}

}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    NSLog(@"vungleSDKwillCloseProductSheet");
    [self triggerEvent:@"video_onBack"];
}

//////////////////////////////////////////////

EJ_BIND_GET(appID, ctx)
{
	return NSStringToJSValue(ctx, appID);
}


EJ_BIND_GET(muted, ctx)
{
    return JSValueMakeBoolean(ctx, sdk.muted);
}

EJ_BIND_SET(muted, ctx, value)
{
    sdk.muted = JSValueToBoolean(ctx, value);
}


EJ_BIND_GET(debug, ctx)
{
	return JSValueMakeBoolean(ctx, debug);
}

EJ_BIND_SET(debug, ctx, value)
{
	debug = JSValueToBoolean(ctx, value);
	[sdk setLoggingEnabled:debug];
}



-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	/*
	 Options ( VunglePlayAdOptionKey + key ) :
	 incentivized    boolean
	 incentivizedAlertTitleText      string
	 incentivizedAlertBodyText       string
	 incentivizedAlertCloseButtonText        string
	 incentivizedAlertContinueButtonText     string
	 orientations        string
	 placement       string
	 user        string
	 * extraInfoDictionary  (don't support)
	 {
	 "videoLength":30,
	 "playTime":30,
	 "completedView":1,
	 "willPresentProductSheet":0,
	 "didDownload":0
	 }
	 
	 */
	
	
	NSError *error;
	
	if (options){

//		if ([type isEqualToString:@"rewardedVideo"]){
//			[options setValue:@(YES) forKey:@"incentivized"];
//		}
		
		NSMutableDictionary *sdkOptions = [NSMutableDictionary new];
		
		NSEnumerator *keys = [options keyEnumerator];

		id keyId;
		while ((keyId = [keys nextObject])) {
			NSString *key = (NSString *)keyId;
			NSString *value = (NSString *)[options objectForKey:keyId];
			NSLog(@"key : %@, value: %@", key, value);
			if ([key isEqualToString:@"incentivized"]){
				[sdkOptions setObject:@([[options objectForKey:keyId] boolValue]) forKey:VunglePlayAdOptionKeyIncentivized];
			}else if ([key isEqualToString:@"incentivizedAlertTitleText"]){
				[sdkOptions setObject:value forKey:VunglePlayAdOptionKeyIncentivizedAlertTitleText];
			}else if ([key isEqualToString:@"incentivizedAlertBodyText"]){
				[sdkOptions setObject:value forKey:VunglePlayAdOptionKeyIncentivizedAlertBodyText];
			}else if ([key isEqualToString:@"incentivizedAlertCloseButtonText"]){
				[sdkOptions setObject:value forKey:VunglePlayAdOptionKeyIncentivizedAlertCloseButtonText];
			}else if ([key isEqualToString:@"incentivizedAlertContinueButtonText"]){
				[sdkOptions setObject:value forKey:VunglePlayAdOptionKeyIncentivizedAlertContinueButtonText];
			}else if ([key isEqualToString:@"orientations"]){
				if ([value isEqualToString:@"portrait"]){
					[sdkOptions setObject:@(UIInterfaceOrientationMaskPortrait) forKey:VunglePlayAdOptionKeyOrientations];
				}else if ([value isEqualToString:@"landscape"]){
					[sdkOptions setObject:@(UIInterfaceOrientationMaskLandscape) forKey:VunglePlayAdOptionKeyOrientations];
				}
			}else if ([key isEqualToString:@"placement"]){
				[sdkOptions setObject:value forKey:VunglePlayAdOptionKeyPlacement];
			}else if ([key isEqualToString:@"user"]){
				[sdkOptions setObject:value forKey:VunglePlayAdOptionKeyUser];
			}
		}
		[sdk playAd:scriptView.window.rootViewController withOptions:sdkOptions error:&error];
		[sdkOptions release];

	}else{
		[sdk playAd:scriptView.window.rootViewController error:&error];
	}
	
	if (error) {
		NSLog(@"Error encountered playing ad: %@", error);
		[self triggerEvent:@"error"];
		return false;
	}
	
	return true;
	
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	return sdk.isAdPlayable;

}


@end
