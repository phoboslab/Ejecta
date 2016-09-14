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
		
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[UnityAds initialize:appId delegate:self];
        }];
		

//		[UnityAds show:self placementId:self.incentivizedPlacementId];

	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	[appId release];
	[super dealloc];
}


- (void)unityAdsReady:(NSString *)placementId {
	NSLog(@"UADS Ready");
	
	JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,@{
																		   @"placementId": placementId
																		   });
	JSValueRef jsParams[] = { jsViewInfo };
	[self triggerEventOnce:@"video_onReady" argc:1 argv:jsParams];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
	NSLog(@"UnityAds ERROR: %ld - %@",(long)error, message);

	JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,@{
																		   @"message": message
																		   });
	JSValueRef jsParams[] = { jsViewInfo };
	[self triggerEventOnce:@"video_onFail" argc:1 argv:jsParams];
}

- (void)unityAdsDidStart:(NSString *)placementId {
	NSLog(@"UADS Start");
	
	JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,@{
																		   @"placementId": placementId
																		   });
	JSValueRef jsParams[] = { jsViewInfo };
	[self triggerEventOnce:@"video_onDisplay" argc:1 argv:jsParams];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
	
	JSValueRef jsViewInfo = NSObjectToJSValue(scriptView.jsGlobalContext,@{
																		   @"placementId": placementId
																		   });
	JSValueRef jsParams[] = { jsViewInfo };
	
	NSString *stateString = @"UNKNOWN";
	switch (state) {
		case kUnityAdsFinishStateError:
			stateString = @"ERROR";
			[self triggerEventOnce:@"video_onError" argc:1 argv:jsParams];
			break;
		case kUnityAdsFinishStateSkipped:
			stateString = @"SKIPPED";
			[self triggerEventOnce:@"video_onSkip" argc:1 argv:jsParams];
			break;
		case kUnityAdsFinishStateCompleted:
			stateString = @"COMPLETED";
			[self triggerEventOnce:@"video_onFinish" argc:1 argv:jsParams];
			break;
		default:
			break;
	}
	NSLog(@"UnityAds FINISH: %@ - %@", stateString, placementId);
}


//////////////////////////////////////
//////////////////////////////////////


EJ_BIND_GET(appId, ctx)
{
	return NSStringToJSValue(ctx, appId);
}


EJ_BIND_GET(debug, ctx)
{
	return JSValueMakeBoolean(ctx, [UnityAds getDebugMode]);
}

EJ_BIND_SET(debug, ctx, value)
{
	debug = JSValueToBoolean(ctx, value);
	[UnityAds setDebugMode:debug];
}



//////////////////////////////////////
//////////////////////////////////////



-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	NSLog(@"callShow %@",type);
	
	NSString *zone = @"rewardedVideo";
	
	if ([options objectForKey:@"zone"]) {
		zone = [options objectForKey:@"zone"];
	}
	
	if ([UnityAds isReady:zone]){
		[UnityAds show:scriptView.window.rootViewController placementId:zone];
		return true;
	}

	return false;
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	NSString *zone = @"rewardedVideo";
	
	if ([options objectForKey:@"zone"]) {
		zone = [options objectForKey:@"zone"];
	}
	
	return [UnityAds isReady:zone];
}

-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	return true;
}

-(void)callHide:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	

}

@end
