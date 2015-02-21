#import "EJBindingAppUtils.h"
#import "OpenUDID.h"


@implementation EJBindingAppUtils


EJ_BIND_GET(udid, ctx)
{
	NSString *openUDID = [OpenUDID value];
	return NSStringToJSValue(ctx, openUDID);
}


EJ_BIND_GET(uuid, ctx)
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	static NSString *UUID_KEY = @"EJ_APP_UUID";

	NSString *app_uuid = [userDefaults stringForKey:UUID_KEY];

	if (app_uuid == nil) {
		CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
		CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);

		app_uuid = [NSString stringWithString:(NSString *)uuidString];
		[userDefaults setObject:app_uuid forKey:UUID_KEY];
		[userDefaults synchronize];

		CFRelease(uuidString);
		CFRelease(uuidRef);
	}
	return NSStringToJSValue(ctx, app_uuid);
}

EJ_BIND_GET(ver, ctx)
{
	NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	return NSStringToJSValue(ctx, ver);
}

EJ_BIND_GET(systemLocal, ctx)
{
	NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
	return NSStringToJSValue(ctx, preferredLang);
}

EJ_BIND_FUNCTION(eval, ctx, argc, argv)
{
	NSString *script = JSValueToNSString(ctx, argv[0]);

	JSValueRef result = [scriptView evaluateScript:script];

	//  JSGlobalContextRef jsGlobalContext=[scriptView jsGlobalContext];
	//  JSType type=JSValueGetType(jsGlobalContext,result);


	return result;
}

EJ_BIND_GET(systemVersion, ctx)
{
	return NSStringToJSValue(ctx, [[UIDevice currentDevice] systemVersion]);
}


@end
