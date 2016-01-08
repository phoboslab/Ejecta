#import "EJBindingUnityAds.h"

@implementation EJBindingUnityAds


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			appId = [JSValueToNSString(ctx, argv[0]) retain];
		}
		else {
			NSLog(@"Error: Must set appID");
            return self;
		}
        
        [[UnityAds sharedInstance] startWithGameId:appId];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[[UnityAds sharedInstance] setDelegate:self];
        }];

	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	[[UnityAds sharedInstance] setDelegate:nil];
	[[UnityAds sharedInstance] setViewController:nil];
	[appId release];
	[super dealloc];
}

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped {
	NSLog(@"unityAdsVideoCompleted");
	
	if (rewardItemKey){
		if (!skipped){
			JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,@{
								   @"rewardItemKey": rewardItemKey
							   });
			JSValueRef jsParams[] = { jsViewInfo };
			[self triggerEventOnce:@"video_onFinish" argc:1 argv:jsParams];
		}
	}else{
		if (!skipped){
			[self triggerEventOnce:@"video_onFinish"];
		}
	}

//	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
//		JSValueRef jsParams[] = { jsViewInfo };
//		[self triggerEventOnce:@"video_onClose" argc:1 argv:jsParams];
//	}];
}

- (void)unityAdsWillShow {
	NSLog(@"unityAdsWillShow");
	
	[self triggerEventOnce:@"video_onDisplay"];
	
}

- (void)unityAdsDidHide {
	NSLog(@"unityAdsDidHide");
	
	[self triggerEventOnce:@"video_onClose"];
}

//- (void)unityAdsWillLeaveApplication;
//- (void)unityAdsVideoStarted;
//- (void)unityAdsFetchCompleted;

- (void)unityAdsFetchFailed {
	NSLog(@"unityAdsFetchFailed");
	
	[self triggerEventOnce:@"video_onFail"];
}




//////////////////////////////////////////////

EJ_BIND_GET(appId, ctx)
{
	return NSStringToJSValue(ctx, appId);
}


EJ_BIND_GET(debug, ctx)
{
	return [[UnityAds sharedInstance] isDebugMode];
}

EJ_BIND_SET(debug, ctx, value)
{
	debug = JSValueToBoolean(ctx, value);
	[[UnityAds sharedInstance] setDebugMode:debug];
}



//////////////////////////////////////
//////////////////////////////////////



-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	NSLog(@"callShow %@",type);
	
	NSString *zone = @"rewardedVideo";
	
	if ([options objectForKey:@"zone"]) {
		zone = [options objectForKey:@"zone"];
	}
	
	[[UnityAds sharedInstance] setZone:zone];
	
	[[UnityAds sharedInstance] setViewController:scriptView.window.rootViewController];
	
	if ([[UnityAds sharedInstance] canShow]){
		[[UnityAds sharedInstance] show:options];
		return true;
	}
	
	return false;
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	NSString *zone = @"rewardedVideo";
	
	if ([options objectForKey:@"zone"]) {
		zone = [options objectForKey:@"zone"];
	}
	
	[[UnityAds sharedInstance] setZone:zone];
	
	return [[UnityAds sharedInstance] canShowZone:zone];
}

-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	return true;
}

-(void)callHide:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	[[UnityAds sharedInstance] hide];

}

@end
