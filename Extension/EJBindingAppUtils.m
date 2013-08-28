
#import "EJBindingAppUtils.h"
#import "OpenUDID.h"

@implementation EJBindingAppUtils


- (void)logException:(JSValueRef)exception ctx:(JSContextRef)ctxp {
	if( !exception ) return;
	
	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
	JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
	
	JSObjectRef exObject = JSValueToObject( ctxp, exception, NULL );
	JSValueRef line = JSObjectGetProperty( ctxp, exObject, jsLinePropertyName, NULL );
	JSValueRef file = JSObjectGetProperty( ctxp, exObject, jsFilePropertyName, NULL );
	
	NSLog(
          @"%@ at line %@ in %@",
          JSValueToNSString( ctxp, exception ),
          JSValueToNSString( ctxp, line ),
          JSValueToNSString( ctxp, file )
          );
	
	JSStringRelease( jsLinePropertyName );
	JSStringRelease( jsFilePropertyName );
}

EJ_BIND_GET(udid, ctx) {
    NSString* openUDID = [OpenUDID value];
    return NSStringToJSValue(ctx, openUDID);
}


EJ_BIND_GET(uuid, ctx) {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    static NSString* UUID_KEY = @"EJ_APP_UUID";
    
    NSString* app_uuid = [userDefaults stringForKey:UUID_KEY];
    
    if (app_uuid == nil) {
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        
        app_uuid = [NSString stringWithString:(NSString*)uuidString];
        [userDefaults setObject:app_uuid forKey:UUID_KEY];
        [userDefaults synchronize];
        
        CFRelease(uuidString);
        CFRelease(uuidRef);
    }
	return NSStringToJSValue(ctx, app_uuid);
}

EJ_BIND_GET(ver, ctx){
    NSString *ver=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return NSStringToJSValue(ctx, ver);
}

EJ_BIND_GET(systemLocal, ctx) {
    NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    return NSStringToJSValue(ctx, preferredLang);
}

EJ_BIND_FUNCTION( eval, ctx, argc, argv ) {
    
    JSGlobalContextRef jsGlobalContext=[scriptView jsGlobalContext];
    NSString *script = JSValueToNSString(ctx, argv[0]);
    JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);

	JSValueRef exception = NULL;
	JSValueRef ret = JSEvaluateScript(jsGlobalContext, scriptJS, NULL, NULL, 0, &exception );
	[self logException:exception ctx:jsGlobalContext];
 
	JSStringRelease( scriptJS );
 
    // JSType type=JSValueGetType(jsGlobalContext,result);
    
    return ret;
}



@end
