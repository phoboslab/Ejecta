#import "EJBindingVungle.h"

@implementation EJBindingVungle


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			appId = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set appID");
            return self;
		}
        
        sdk = [VungleSDK sharedSDK];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [sdk setDelegate:self];
            [sdk startWithAppId:appId];
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
	[appId release];
	[super dealloc];
}

-(void)vungleSDKwillShowAd {
    NSLog(@"vungleSDKwillShowAd");

    [self triggerEventOnce:@"video_onDisplay"];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    NSLog(@"vungleSDKwillCloseAdWithViewInfo %d", willPresentProductSheet);

//    "playTime":15,"didDownload":false,"videoLength":15,"completedView":true
	
	BOOL completed = [[viewInfo objectForKey:@"completedView"] boolValue];
	
	JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,@{
								   @"playTime": [viewInfo objectForKey:@"playTime"],
								   @"videoLength": [viewInfo objectForKey:@"videoLength"],
								   @"completedView": [viewInfo objectForKey:@"completedView"],
								   @"didDownload": [viewInfo objectForKey:@"didDownload"],
								   @"willPresentProductSheet": @(willPresentProductSheet)
							   });

	if (completed){
		JSValueRef jsParams[] = { jsViewInfo };
		[self triggerEventOnce:@"video_onFinish" argc:1 argv:jsParams];
	}
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		JSValueRef jsParams[] = { jsViewInfo };
		[self triggerEventOnce:@"video_onClose" argc:1 argv:jsParams];
	}];
	
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    NSLog(@"vungleSDKwillCloseProductSheet");
    [self triggerEventOnce:@"video_onBack"];
}

//////////////////////////////////////////////

EJ_BIND_GET(appId, ctx)
{
	return NSStringToJSValue(ctx, appId);
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


//EJ_BIND_FUNCTION(show, ctx, argc, argv)
//{
//	
//	if (argc < 1){
//		return NULL;
//	}
//	
//	NSString *type = JSValueToNSString(ctx, argv[0]);
//	NSDictionary* options = nil;
//	
//	BOOL rewarded = false;
//	
//	if ([type isEqualToString:@"rewardedVideo"]){
//		type = @"video";
//		rewarded = true;
//	}
//	
//	if (argc > 1){
//		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
//		options = [self getOptions:type ctx:ctx jsOptions:jsOptions];
//		if (rewarded){
//			[options setValue:@(YES) forKey:@"incentivized"];
//		}
//	}else if (rewarded){
//		options = [NSDictionary dictionaryWithObject:@(YES) forKey:@"incentivized"];
//	};
//	
//	BOOL ok = [self callShow:type options:options ctx:ctx argc:argc argv:argv];
//	
//	return ok ? scriptView->jsTrue : scriptView->jsFalse;
//}



//////////////////////////////////////
//////////////////////////////////////



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
		[self triggerEventOnce:@"error"];
		return false;
	}
	
	return true;
	
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	return sdk.isAdPlayable;

}

-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	return true;
}

@end
