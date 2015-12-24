#import "EJBindingAppUtils.h"
#import "EJDrawable.h"
#import "EJDeviceUID.h"

@implementation EJBindingAppUtils


- (void) download:(NSString *)urlStr destination:(NSString *)destination callback:(JSObjectRef)callback {
    
    NSString *filePath = [scriptView pathForResource:destination];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        NSLog(@"Download data:%@",data);
//        NSLog(@"Download response:%@",response);
        
        NSString *errorDesc = NULL;
        if (error) {
            NSLog(@"Download Error:%@",error.description);
        }


        if (data) {
            [data writeToFile:filePath atomically:YES];
            NSLog(@"File is saved to %@",filePath);
        }
        
        if( callback ) {
            JSContextRef gctx = scriptView.jsGlobalContext;
            JSStringRef jsFilePath = JSStringCreateWithUTF8CString([filePath UTF8String]);
            JSStringRef jsErrorDesc = errorDesc?JSStringCreateWithUTF8CString([errorDesc UTF8String]):NULL;
            
            JSValueRef params[] = {
                error?JSValueMakeString(gctx, jsErrorDesc):JSValueMakeNull(gctx),
                JSValueMakeString(gctx, jsFilePath)
            };
            [scriptView invokeCallback:callback thisObject:NULL argc:2 argv:params];
            JSValueUnprotectSafe(gctx, callback);
        }


    }] resume];
   

    
}


- (void) saveImage:(NSObject<EJDrawable> *)drawable destination:(NSString *)destination callback:(JSObjectRef)callback {
    
    UIImage *image = [drawable.texture image];
    
    NSString *filePath = image ? [scriptView pathForResource:destination] : NULL;

    NSData *raw = nil;
    
    if (image){
        if ([destination hasSuffix:@".jpg"] || [destination hasSuffix:@".jpeg"]){
            raw = UIImageJPEGRepresentation(image, 0.80);
        }else{
            raw = UIImagePNGRepresentation(image);
        }
    }
    
    dispatch_queue_t saveFileQueue = dispatch_get_main_queue();
    dispatch_retain(saveFileQueue);

    dispatch_async(saveFileQueue, ^{
        
        if (raw) {
            [raw writeToFile:filePath atomically:YES];
        }

        if(callback) {
            JSContextRef gctx = scriptView.jsGlobalContext;
            JSStringRef jsFilePath = JSStringCreateWithUTF8CString([filePath UTF8String]);

            JSValueRef params[] = {
                JSValueMakeString(gctx, jsFilePath)
            };
            [scriptView invokeCallback:callback thisObject:NULL argc:1 argv:params];
            JSValueUnprotectSafe(gctx, callback);
        }

        dispatch_release(saveFileQueue);
    });
    
}

- (void)dealloc {
    [super dealloc];
}




EJ_BIND_FUNCTION(download, ctx, argc, argv)
{

    NSString *url = JSValueToNSString(ctx, argv[0]);
    NSString *destination = JSValueToNSString(ctx, argv[1]);
    JSObjectRef callback = nil;
    
    if (argc == 3){
        callback = JSValueToObject(ctx, argv[2], NULL);
        if (callback) {
            JSValueProtect(ctx, callback);
        }
    }

    [self download:url destination:destination callback:callback];
                                                         
    return JSValueMakeBoolean(ctx, true);
}


EJ_BIND_FUNCTION(saveImage, ctx, argc, argv)
{
    
    NSObject<EJDrawable> *drawable = (NSObject<EJDrawable> *)JSValueGetPrivate(argv[0]);
    
    NSString *destination = JSValueToNSString(ctx, argv[1]);
    JSObjectRef callback = nil;
    
    if (argc == 3){
        callback = JSValueToObject(ctx, argv[2], NULL);
        if (callback) {
            JSValueProtect(ctx, callback);
        }
    }
    
    [self saveImage:drawable destination:destination callback:callback];
                                                      
    return JSValueMakeBoolean(ctx, true);
}


EJ_BIND_FUNCTION(eval, ctx, argc, argv)
{
    NSString *script = JSValueToNSString(ctx, argv[0]);
    
    JSValueRef result = [scriptView evaluateScript:script];
    
    //  JSGlobalContextRef jsGlobalContext=[scriptView jsGlobalContext];
    //  JSType type=JSValueGetType(jsGlobalContext,result);
    
    
    return result;
}


EJ_BIND_GET(ver, ctx)
{
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return NSStringToJSValue(ctx, ver);
}


EJ_BIND_GET(udid, ctx)
{
    
    NSString* udid = [EJDeviceUID uid];
    
    return NSStringToJSValue(ctx, udid);
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


EJ_BIND_GET(systemVersion, ctx)
{
    return NSStringToJSValue(ctx, [[UIDevice currentDevice] systemVersion]);
}


EJ_BIND_GET(systemLocal, ctx)
{
	NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
	return NSStringToJSValue(ctx, preferredLang);
}

EJ_BIND_FUNCTION(fileExists, ctx, argc, argv ) {
    if(argc > 0) {
        NSString *path = JSValueToNSString(ctx, argv[0]);
        if ([[NSFileManager defaultManager] fileExistsAtPath:[scriptView pathForResource:path]]){
            return JSValueMakeBoolean(ctx, true);
        }
    }
    return JSValueMakeBoolean(ctx, false);
}



@end
