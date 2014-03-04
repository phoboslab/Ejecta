
#import "EJBindingAppUtils.h"
#import "OpenUDID.h"
#import "base64.h"

@implementation EJBindingAppUtils



- (NSString *)decodeScript:(NSString *)script {
	
	script = [script substringFromIndex:[EJECTA_SECRET_PREFIX length]];
	
	NSData *keyData = [EJECTA_SECRET_KEY dataUsingEncoding:NSUTF8StringEncoding];
	size_t keyLen = keyData.length;
	char const *key = keyData.bytes;
	
	NSData *encodeData = [script dataUsingEncoding:NSUTF8StringEncoding];
	size_t decodeLen = encodeData.length * 3 / 4;
	NSMutableData *decodedData = [NSMutableData dataWithLength:decodeLen];
    //	NSLog(@"data length: %d %d",encodeData.length, decodeLen);
	
    //	NOTE: b64_pton will ignore blank-lines at the start & end of the code.
	size_t tarindex = b64_pton(encodeData.bytes, decodedData.mutableBytes, decodeLen);
	if ( tarindex != -1 ){
		decodeLen = tarindex;
	}
    //	NSLog(@"tarindex : %d",tarindex);
	
	char *decode = decodedData.mutableBytes;
	for (int i = 0; i < decodeLen; i++) {
		char v = decode[i];
		char kv = key[i % keyLen];
		decode[i] = v ^ kv;
	}
	[decodedData setLength:decodeLen];
	
	script = [[[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding] autorelease];
    //	NSLog(@"Decoded : %@",script);
	
	return script;
}


EJ_BIND_FUNCTION(include, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }
    
    NSString *path=JSValueToNSString(ctx, argv[0]);

    NSString *script = [NSString stringWithContentsOfFile:[scriptView pathForResource:path]
                                                 encoding:NSUTF8StringEncoding error:NULL];
	
	if ( [script hasPrefix:EJECTA_SECRET_PREFIX] ){
		NSLog(@"Decoding JavaScript : %@",path);
		script = [self decodeScript:script];
	}
	
	[scriptView evaluateScript:script sourceURL:path];

	return NULL;
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
    
    NSString *script = JSValueToNSString(ctx, argv[0]);
    
    JSValueRef result=[scriptView evaluateScript:script];
    
    //  JSGlobalContextRef jsGlobalContext=[scriptView jsGlobalContext];
    //  JSType type=JSValueGetType(jsGlobalContext,result);
        
    
    return result;

}

EJ_BIND_GET(systemVersion, ctx ) {
	return NSStringToJSValue(ctx, [[UIDevice currentDevice] systemVersion]);
}


@end
