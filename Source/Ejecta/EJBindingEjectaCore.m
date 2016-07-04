#import "EJBindingEjectaCore.h"

#import <netinet/in.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AVFoundation/AVFoundation.h>

#import "EJJavaScriptView.h"

@implementation EJBindingEjectaCore

- (NSString*)deviceName {
	struct utsname systemInfo;
	uname( &systemInfo );
	
	NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	
	if(
		[machine isEqualToString: @"i386"] ||
	    [machine isEqualToString: @"x86_64"]
	) {
		#if TARGET_OS_TV
			NSString *deviceType = @"AppleTV";
		#else
			NSString *deviceType = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
				? @"iPad"
				: @"iPhone";
		#endif
		
		return [NSString stringWithFormat: @"%@ Simulator", deviceType];
	}
	else {
		return machine;
	}
}

EJ_BIND_FUNCTION(log, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
    
	NSLog( @"JS %@", JSValueToNSString(ctx, argv[0]) );
	return NULL;
}

EJ_BIND_FUNCTION(load, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSObject<UIApplicationDelegate> *app = UIApplication.sharedApplication.delegate;
	SEL loadViewControllerWithScriptAtPath = sel_registerName("loadViewControllerWithScriptAtPath:");
	if( [app respondsToSelector:loadViewControllerWithScriptAtPath] ) {
		// Queue up the loading till the next frame; the script view may be in the
		// midst of a timer update
		[app performSelectorOnMainThread:loadViewControllerWithScriptAtPath
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

EJ_BIND_FUNCTION(import, ctx, argc, argv ) {
    static dispatch_once_t onceToken;
    static NSMutableSet *_ejImports;
    dispatch_once(&onceToken, ^{
        _ejImports = [NSMutableSet new];
    });
    if( argc < 1 ) { return NULL; }
    NSString *importName = JSValueToNSString(ctx, argv[0]);
    if (![_ejImports containsObject:importName]){
        [_ejImports addObject:importName];
        [scriptView loadScriptAtPath:importName];
    }
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
		NSString *confirm = JSValueToNSString( ctx, argv[1] );
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open Browser?"
			message:confirm preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
			handler:^(UIAlertAction * action) {
				[UIApplication.sharedApplication openURL:[NSURL URLWithString:url]
					options:@{} completionHandler:^(BOOL success) {}];
			}];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
			handler:^(UIAlertAction * action) {}];
		
		[alert addAction:ok];
		[alert addAction:cancel];
		
		[self.scriptView.window.rootViewController presentViewController:alert animated:YES completion:nil];
	}
	else {
		[UIApplication.sharedApplication openURL:[NSURL URLWithString:url]
					options:@{} completionHandler:^(BOOL success) {}];
	}
	return NULL;
}

EJ_BIND_FUNCTION(getText, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	NSString *title = JSValueToNSString(ctx, argv[0]);
	NSString *message = JSValueToNSString(ctx, argv[1]);
	
	JSObjectRef getTextCallback = JSValueToObject(ctx, argv[2], NULL);
	JSValueProtect(ctx, getTextCallback);
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
		message:message preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
		handler:^(UIAlertAction * action) {
			JSValueRef params[] = { NSStringToJSValue(scriptView.jsGlobalContext, alert.textFields[0].text) };
			[scriptView invokeCallback:getTextCallback thisObject:NULL argc:1 argv:params];
			JSValueUnprotectSafe(scriptView.jsGlobalContext, getTextCallback);
		}];
	
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
		handler:^(UIAlertAction * action) {
			[scriptView invokeCallback:getTextCallback thisObject:NULL argc:0 argv:NULL];
			JSValueUnprotectSafe(scriptView.jsGlobalContext, getTextCallback);
		}];
	
    [alert addAction:ok];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){}];
	
    [self.scriptView.window.rootViewController presentViewController:alert animated:YES completion:nil];
	return NULL;
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
	double time = NSProcessInfo.processInfo.systemUptime;
	return JSValueMakeNumber(ctx, time * 1000.0);
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
		[NSString stringWithFormat: @"Ejecta/%@ (%@; OS %@)",
			EJECTA_VERSION, [self deviceName], UIDevice.currentDevice.systemVersion]
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
	
	#if !TARGET_OS_TV
		switch( UIApplication.sharedApplication.statusBarOrientation ) {
			case UIDeviceOrientationPortrait: angle = 0; break;
			case UIInterfaceOrientationLandscapeLeft: angle = -90; break;
			case UIInterfaceOrientationLandscapeRight: angle = 90; break;
			case UIInterfaceOrientationPortraitUpsideDown: angle = 180; break;
			default: angle = 0; break;
		}
	#endif
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
	return JSValueMakeBoolean(ctx, !UIApplication.sharedApplication.idleTimerDisabled);
}

EJ_BIND_SET(allowSleepMode, ctx, value) {
	UIApplication.sharedApplication.idleTimerDisabled = !JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(otherAudioPlaying, ctx) {
	return JSValueMakeBoolean(ctx, AVAudioSession.sharedInstance.isOtherAudioPlaying);
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
	AVAudioSession *instance = AVAudioSession.sharedInstance;
	
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
