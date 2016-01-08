#import "EJBindingAdColony.h"

@implementation EJBindingAdColony


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 1) {
			appId = [JSValueToNSString(ctx, argv[0]) retain];
			zones = (NSArray *)[JSValueToNSObject(ctx, argv[1]) retain];
		}
		else {
			NSLog(@"Error: Must set appId & zones");
            return self;
		}
		if (argc > 2) {
			debug = JSValueToBoolean(ctx, argv[2]);
		}
		availabilityState = [NSMutableDictionary new];
		[AdColony configureWithAppID:appId zoneIDs:zones delegate:self logging:debug];
	}

	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
}

- (void)dealloc {
	[appId release];
	[zones release];
	[availabilityState release];
	[super dealloc];
}

- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID {
	
	NSLog(@"========  Availability Change  ========\n  %@  %@",zoneID, @(available));

	[availabilityState setObject:@(available) forKey:zoneID];
	
}

- (void)onAdColonyV4VCReward:(BOOL)success currencyName:(NSString *)currencyName currencyAmount:(int)amount inZone:(NSString *)zoneID{
	if (success){
		[self triggerEventOnce:@"video_onFinish" properties:(JSEventProperty[]){
			{"zone", NSStringToJSValue(scriptView.jsGlobalContext, zoneID)},
			{"rewardedName", NSStringToJSValue(scriptView.jsGlobalContext, currencyName)},
			{"rewardedAmount", JSValueMakeNumber(scriptView.jsGlobalContext, amount)},
			{NULL, NULL}
		}];
	}
}

- (void)onAdColonyAdStartedInZone:(NSString *)zoneID{
	[self triggerEventOnce:@"video_onDisplay" properties:(JSEventProperty[]){
		{"zone", NSStringToJSValue(scriptView.jsGlobalContext, zoneID)},
		{NULL, NULL}
	}];
}

- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID{
	[self triggerEventOnce:@"video_onClose" properties:(JSEventProperty[]){
		{"zone", NSStringToJSValue(scriptView.jsGlobalContext, zoneID)},
		{"shown", JSValueMakeBoolean(scriptView.jsGlobalContext, shown)},
		{NULL, NULL}
	}];
}

//- (void)onAdColonyAdFinishedWithInfo:(AdColonyAdInfo *)info{
//	
//}



//////////////////////////////////////////////

EJ_BIND_GET(appId, ctx)
{
	return NSStringToJSValue(ctx, appId);
}

EJ_BIND_GET(debug, ctx)
{
	return JSValueMakeBoolean(ctx, debug);
}

EJ_BIND_SET(debug, ctx, value)
{

}



//////////////////////////////////////
//////////////////////////////////////



-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	NSString *zone = nil;
	
	if ([options objectForKey:@"zone"]) {
		zone = [options objectForKey:@"zone"];
	}

	if (!zone){
		return false;
	}

	[AdColony playVideoAdForZone:zone
						withDelegate:self
					withV4VCPrePopup:YES
					andV4VCPostPopup:YES];

	return true;
	
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	NSString *zone = nil;
	
	if ([options objectForKey:@"zone"]) {
		zone = [options objectForKey:@"zone"];
	}
	
	if (!zone){
		return false;
	}

	return [[availabilityState objectForKey:zone] boolValue];

}

-(void)callHide:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	[AdColony cancelAd];
}


@end
