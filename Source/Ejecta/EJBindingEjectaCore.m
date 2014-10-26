#import "EJBindingEjectaCore.h"

#import <netinet/in.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AVFoundation/AVFoundation.h>

#import "EJJavaScriptView.h"

@implementation EJBindingEjectaCore

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		baseTime = [NSDate timeIntervalSinceReferenceDate];
        animationCallbackBuffer = 0;
        for (int i = 0; i < 2; ++i)
            animationCallbacks[i] = [[NSPointerArray alloc] initWithOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsObjectPointerPersonality)];
	}
	return self;
}

- (NSString*)deviceName {
	struct utsname systemInfo;
	uname( &systemInfo );
	
	NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	
	if( [machine isEqualToString: @"i386"] ||
	    [machine isEqualToString: @"x86_64"] ) {
		
		NSString *deviceType = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
			? @"iPad"
			: @"iPhone";
		
		return [NSString stringWithFormat: @"%@ Simulator", deviceType];
		
	} else {
		return machine;
	}
}

- (void)dealloc {
	[urlToOpen release];
	JSValueUnprotectSafe(scriptView.jsGlobalContext, getTextCallback);
    for (int i = 0; i < 2; ++i)
    {
        NSPointerArray *callbackBuffer = animationCallbacks[i];
        for (int j = 0, n = callbackBuffer.count; j < n; ++j)
        {
            JSObjectRef object = [callbackBuffer pointerAtIndex:j];
            if (object)
            {
                JSValueUnprotectSafe(scriptView.jsGlobalContext, object);
            }
        }
        [callbackBuffer setCount:0];
        [callbackBuffer release];
    }
	[super dealloc];
}

EJ_BIND_FUNCTION(log, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
    
	NSLog( @"JS: %@", JSValueToNSString(ctx, argv[0]) );
	return NULL;
}

EJ_BIND_FUNCTION(load, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSObject<UIApplicationDelegate> *app = [[UIApplication sharedApplication] delegate];
	if( [app respondsToSelector:@selector(loadViewControllerWithScriptAtPath:)] ) {
		// Queue up the loading till the next frame; the script view may be in the
		// midst of a timer update
		[app performSelectorOnMainThread:@selector(loadViewControllerWithScriptAtPath:)
			withObject:JSValueToNSString(ctx, argv[0]) waitUntilDone:NO];
	}
	else {
		NSLog(@"Error: Current UIApplicationDelegate does not support loadViewControllerWithScriptAtPath.");
	}
	
	return NULL;
}

EJ_BIND_FUNCTION(include, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }

	[scriptView loadScriptAtPath:JSValueToNSString(ctx, argv[0])];
	return NULL;
}

EJ_BIND_FUNCTION(loadFont, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }

	NSString *path = JSValueToNSString(ctx, argv[0]);
	NSString *fullPath = [scriptView pathForResource:path];
	[EJFont loadFontAtPath:fullPath];
	return NULL;
}

EJ_BIND_FUNCTION(requireModule, ctx, argc, argv ) {
	if( argc < 3 ) { return NULL; }
	
	return [scriptView loadModuleWithId:JSValueToNSString(ctx, argv[0]) module:argv[1] exports:argv[2]];
}

EJ_BIND_FUNCTION(openURL, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }
	
	NSString *url = JSValueToNSString( ctx, argv[0] );
	if( argc == 2 ) {
		[urlToOpen release];
		urlToOpen = [url retain];
		
		NSString *confirm = JSValueToNSString( ctx, argv[1] );
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open Browser?" message:confirm delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
		alert.tag = kEJCoreAlertViewOpenURL;
		[alert show];
		[alert release];
	}
	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
	}
	return NULL;
}

EJ_BIND_FUNCTION(getText, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	NSString *title = JSValueToNSString(ctx, argv[0]);
	NSString *message = JSValueToNSString(ctx, argv[1]);
	
	JSValueUnprotectSafe(ctx, getTextCallback);
	getTextCallback = JSValueToObject(ctx, argv[2], NULL);
	JSValueProtect(ctx, getTextCallback);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self
		cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = kEJCoreAlertViewGetText;
	[alert show];
	[alert release];
	return NULL;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	if( alertView.tag == kEJCoreAlertViewOpenURL ) {
		if( index == 1 ) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlToOpen]];
		}
		[urlToOpen release];
		urlToOpen = nil;
	}
	
	else if( alertView.tag == kEJCoreAlertViewGetText ) {
		NSString *text = @"";
		if( index == 1 ) {
			text = [[alertView textFieldAtIndex:0] text];
		}
		JSValueRef params[] = { NSStringToJSValue(scriptView.jsGlobalContext, text) };
		[scriptView invokeCallback:getTextCallback thisObject:NULL argc:1 argv:params];
		
		JSValueUnprotectSafe(scriptView.jsGlobalContext, getTextCallback);
		getTextCallback = NULL;
	}
}

EJ_BIND_FUNCTION(requestAnimationFrame, ctx, argc, argv) {
    if (!displayLink)
    {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    NSPointerArray *callbackBuffer = animationCallbacks[animationCallbackBuffer];
    JSObjectRef callback = JSValueToObject(ctx, argv[0], NULL);
    JSValueProtect(ctx, callback);
    [callbackBuffer addPointer:callback];
    
    return JSValueMakeNumber(ctx, callbackBuffer.count);
}

EJ_BIND_FUNCTION(cancelAnimationFrame, ctx, argc, argv) {
    NSUInteger bufferIndex = runningDisplayLinkUpdate ? (animationCallbackBuffer + 1) % 2 : animationCallbackBuffer;
    NSPointerArray *callbackBuffer = animationCallbacks[bufferIndex];
    NSUInteger objectIndex = (NSUInteger)(JSValueToNumberFast(ctx, argv[0]) - 1);
    JSObjectRef callback = [callbackBuffer pointerAtIndex:objectIndex];
    if (callback)
    {
        JSValueUnprotectSafe(scriptView.jsGlobalContext, callback);
        [callbackBuffer replacePointerAtIndex:objectIndex withPointer:NULL];
    }
    return NULL;
}

-(void) displayLinkUpdate:(CADisplayLink*)dl
{
    runningDisplayLinkUpdate = YES;
    NSPointerArray *callbackBuffer = animationCallbacks[animationCallbackBuffer];
    animationCallbackBuffer = (animationCallbackBuffer + 1) % 2;
    
    JSValueRef timeParam[] = { JSValueMakeNumber(scriptView.jsGlobalContext, ([NSDate timeIntervalSinceReferenceDate] - baseTime) * 1000.0) };
    
    for (int j = 0, n = callbackBuffer.count; j < n; ++j)
    {
        JSObjectRef callback = [callbackBuffer pointerAtIndex:j];
        if (callback)
        {
            [scriptView invokeCallback:callback thisObject:NULL argc:1 argv:timeParam];
            JSValueUnprotectSafe(scriptView.jsGlobalContext, callback);
        }
    }
    [callbackBuffer setCount:0];
    
    if (!animationCallbacks[animationCallbackBuffer].count)
    {
        [displayLink invalidate];
        displayLink = nil;
    }
    
    runningDisplayLinkUpdate = NO;
}

EJ_BIND_FUNCTION(setTimeout, ctx, argc, argv ) {
	return [scriptView createTimer:ctx argc:argc argv:argv repeat:NO];
}

EJ_BIND_FUNCTION(setInterval, ctx, argc, argv ) {
	return [scriptView createTimer:ctx argc:argc argv:argv repeat:YES];
}

EJ_BIND_FUNCTION(clearTimeout, ctx, argc, argv ) {
	return [scriptView deleteTimer:ctx argc:argc argv:argv];
}

EJ_BIND_FUNCTION(clearInterval, ctx, argc, argv ) {
	return [scriptView deleteTimer:ctx argc:argc argv:argv];
}

EJ_BIND_FUNCTION(performanceNow, ctx, argc, argv ) {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	return JSValueMakeNumber(ctx, (now - baseTime) * 1000.0);
}

EJ_BIND_GET(devicePixelRatio, ctx ) {
	return JSValueMakeNumber( ctx, [UIScreen mainScreen].scale );
}

EJ_BIND_GET(screenWidth, ctx ) {
	return JSValueMakeNumber( ctx, scriptView.bounds.size.width );
}

EJ_BIND_GET(screenHeight, ctx ) {
	return JSValueMakeNumber( ctx, scriptView.bounds.size.height );
}

EJ_BIND_GET(userAgent, ctx ) {	
	return NSStringToJSValue(
		ctx,
		[NSString stringWithFormat: @"Ejecta/%@ (%@; OS %@)", EJECTA_VERSION, [self deviceName], [[UIDevice currentDevice] systemVersion]]
	);
}

EJ_BIND_GET(platform, ctx ) {
	char machine[32];
	size_t size = sizeof(machine);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
	return NSStringToJSValue(ctx, [NSString stringWithUTF8String:machine] );
}

EJ_BIND_GET(language, ctx) {
	return NSStringToJSValue( ctx, NSLocale.preferredLanguages[0] );
}

EJ_BIND_GET(appVersion, ctx ) {
	return NSStringToJSValue( ctx, EJECTA_VERSION );
}

EJ_BIND_GET(orientation, ctx ) {
	int angle = 0;
	switch( UIApplication.sharedApplication.statusBarOrientation ) {
		case UIDeviceOrientationPortrait: angle = 0; break;
		case UIInterfaceOrientationLandscapeLeft: angle = -90; break;
		case UIInterfaceOrientationLandscapeRight: angle = 90; break;
		case UIInterfaceOrientationPortraitUpsideDown: angle = 180; break;
		default: angle = 0; break;
	}
	return JSValueMakeNumber(ctx, angle);
}

EJ_BIND_GET(onLine, ctx) {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(
		kCFAllocatorDefault,
		(const struct sockaddr*)&zeroAddress
	);
	if( reachability ) {
		SCNetworkReachabilityFlags flags;
		SCNetworkReachabilityGetFlags(reachability, &flags);
		
		CFRelease(reachability);
		
		if(
			// Reachable and no connection required
			(
				(flags & kSCNetworkReachabilityFlagsReachable) &&
				!(flags & kSCNetworkReachabilityFlagsConnectionRequired)
			) ||
			// or connection can be established without user intervention
			(
				(flags & kSCNetworkReachabilityFlagsConnectionOnDemand) &&
				(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) &&
				!(flags & kSCNetworkReachabilityFlagsInterventionRequired)
			)
		) {
			return JSValueMakeBoolean(ctx, true);
		}
	}
	
	return JSValueMakeBoolean(ctx, false);
}

EJ_BIND_GET(allowSleepMode, ctx) {
	return JSValueMakeBoolean(ctx, ![UIApplication sharedApplication].idleTimerDisabled);
}

EJ_BIND_SET(allowSleepMode, ctx, value) {
	[UIApplication sharedApplication].idleTimerDisabled = !JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(otherAudioPlaying, ctx) {
	// Make sure we have an AudioSession instance
	[AVAudioSession sharedInstance];
	
	UInt32 otherAudioPlaying = 0;
	UInt32 propertySize = sizeof(UInt32);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherAudioPlaying);
	return JSValueMakeBoolean(ctx, otherAudioPlaying);
}

EJ_BIND_ENUM(audioSession, self.audioSession,
	"ambient",		// kEJCoreAudioSessionAmbient
	"solo-ambient", // kEJCoreAudioSessionSoloAmbient,
	"playback"		// kEJCoreAudioSessionPlayback
);

- (EJCoreAudioSession)audioSession {
	return audioSession;
}

- (void)setAudioSession:(EJCoreAudioSession)session {
	audioSession = session;
	AVAudioSession *instance = [AVAudioSession sharedInstance];
	
	switch(audioSession) {
		case kEJCoreAudioSessionAmbient:
			[instance setCategory:AVAudioSessionCategoryAmbient error:NULL];
			break;
		case kEJCoreAudioSessionSoloAmbient:
			[instance setCategory:AVAudioSessionCategorySoloAmbient error:NULL];
			break;
		case kEJCoreAudioSessionPlayback:
			[instance setCategory:AVAudioSessionCategoryPlayback error:NULL];
			break;
	}
}

@end
