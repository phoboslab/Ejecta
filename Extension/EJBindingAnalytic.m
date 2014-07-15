#import "EJBindingAnalytic.h"
#import "MobClick.h"
#import "MobClickGameAnalytics.h"

@implementation EJBindingAnalytic


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		logEnabled = false;
		crashReportEnabled = true;
		appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		if (argc > 0) {
			appKey = [JSValueToNSString(ctx, argv[0]) retain];
			[MobClick startWithAppkey:appKey];
			[MobClick startSession:nil];
			[MobClick setAppVersion:appVersion];
		}
		else {
			NSLog(@"Error: Must set appKey");
		}
	}
	return self;
}

EJ_BIND_FUNCTION(setLogEnabled, ctx, argc, argv)
{
	logEnabled = JSValueToBoolean(ctx, argv[0]);
	[MobClick setLogEnabled:logEnabled];
	return NULL;
}


EJ_BIND_FUNCTION(setCrashReportEnabled, ctx, argc, argv)
{
	crashReportEnabled = JSValueToBoolean(ctx, argv[0]);
	[MobClick setCrashReportEnabled:crashReportEnabled];
	return NULL;
}

EJ_BIND_FUNCTION(setAppVersion, ctx, argc, argv)
{
	appVersion = JSValueToNSString(ctx, argv[0]);
	[MobClick setAppVersion:appVersion];
	return NULL;
}

EJ_BIND_FUNCTION(logPageView, ctx, argc, argv)
{
	NSString *pageName = JSValueToNSString(ctx, argv[0]);
	int *seconds = (int)JSValueToNumberFast(ctx, argv[0]);
	[MobClick logPageView:pageName seconds:seconds];
	return NULL;
}

EJ_BIND_FUNCTION(beginLogPageView, ctx, argc, argv)
{
	NSString *pageName = JSValueToNSString(ctx, argv[0]);
	[MobClick beginLogPageView:pageName];
	return NULL;
}

EJ_BIND_FUNCTION(endLogPageView, ctx, argc, argv)
{
	NSString *pageName = JSValueToNSString(ctx, argv[0]);
	[MobClick endLogPageView:pageName];
	return NULL;
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////

EJ_BIND_FUNCTION(eventCount, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	NSInteger accumulation = JSValueToNumberFast(ctx, argv[1]);
	if (!accumulation) {
		[MobClick event:eventId];
	}
	else {
		[MobClick event:eventId acc:(NSInteger)accumulation];
	}
	return NULL;
}

EJ_BIND_FUNCTION(eventCountWithAttribute, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	NSDictionary *attributes = (NSDictionary *)JSValueToNSObject(ctx, argv[1]);
	NSInteger accumulation = JSValueToNumberFast(ctx, argv[2]);
	if (!accumulation) {
		[MobClick event:eventId attributes:attributes];
	}
	else {
		[MobClick event:eventId attributes:attributes counter:(int)accumulation];
	}
	return NULL;
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////

EJ_BIND_FUNCTION(event, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	NSInteger durations = JSValueToNumberFast(ctx, argv[1]);
	if (!durations) {
		[MobClick event:eventId durations:1];
	}
	else {
		[MobClick event:eventId durations:durations];
	}
	return NULL;
}

EJ_BIND_FUNCTION(eventWithAttribute, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	NSDictionary *attributes = (NSDictionary *)JSValueToNSObject(ctx, argv[1]);
	NSInteger durations = JSValueToNumberFast(ctx, argv[2]);
	if (!durations) {
		[MobClick event:eventId attributes:attributes durations:1];
	}
	else {
		[MobClick event:eventId attributes:attributes durations:(int)durations];
	}
	return NULL;
}


/////////////////////////////////////////////////
/////////////////////////////////////////////////


EJ_BIND_FUNCTION(beginEvent, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	[MobClick beginEvent:eventId];
	return NULL;
}


EJ_BIND_FUNCTION(endEvent, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	[MobClick endEvent:eventId];
	return NULL;
}


EJ_BIND_FUNCTION(beginEventWithAttribute, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	NSDictionary *attributes = (NSDictionary *)JSValueToNSObject(ctx, argv[1]);
	NSString *primarykey = JSValueToNSString(ctx, argv[2]);
	if (!primarykey) {
		primarykey = eventId;
	}
	[MobClick beginEvent:eventId primarykey:primarykey attributes:attributes];
	return NULL;
}


EJ_BIND_FUNCTION(endEventWithAttribute, ctx, argc, argv)
{
	NSString *eventId = JSValueToNSString(ctx, argv[0]);
	NSString *primarykey = JSValueToNSString(ctx, argv[1]);
	if (!primarykey) {
		primarykey = eventId;
	}
//	NSDictionary *attributes = (NSDictionary *)JSValueToNSObject(ctx, argv[2]);
	[MobClick endEvent:eventId primarykey:primarykey];
	return NULL;
}


/////////////////////////////////////////////////
/////////////////////////////////////////////////



EJ_BIND_FUNCTION(isJailbroken, ctx, argc, argv)
{
	return JSValueMakeBoolean(ctx, [MobClick isJailbroken]);
}

EJ_BIND_FUNCTION(isPirated, ctx, argc, argv)
{
	return JSValueMakeBoolean(ctx, [MobClick isPirated]);
}


EJ_BIND_FUNCTION(isLogEnabled, ctx, argc, argv)
{
	return JSValueMakeBoolean(ctx, logEnabled);
}

EJ_BIND_FUNCTION(isCrashReportEnabled, ctx, argc, argv)
{
	return JSValueMakeBoolean(ctx, crashReportEnabled);
}


EJ_BIND_FUNCTION(getAppVersion, ctx, argc, argv)
{
	return NSStringToJSValue(ctx, appVersion);
}



EJ_BIND_FUNCTION(startLevel, ctx, argc, argv)
{
	NSString *level = JSValueToNSString(ctx, argv[0]);
	[MobClickGameAnalytics startLevel:level];
	return NULL;
}

EJ_BIND_FUNCTION(finishLevel, ctx, argc, argv)
{
	NSString *level = JSValueToNSString(ctx, argv[0]);
	[MobClickGameAnalytics finishLevel:level];
	return NULL;
}

EJ_BIND_FUNCTION(failLevel, ctx, argc, argv)
{
	NSString *level = JSValueToNSString(ctx, argv[0]);
	[MobClickGameAnalytics failLevel:level];
	return NULL;
}

@end
