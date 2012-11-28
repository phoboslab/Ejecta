#import "EJBindingEjectaCore.h"

#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation EJBindingEjectaCore

- (void)dealloc {
	[urlToOpen release];
	if( getTextCallback ) {
		JSValueUnprotect([EJApp instance].jsGlobalContext, getTextCallback);
	}
	[super dealloc];
}

EJ_BIND_FUNCTION(log, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSLog( @"JS: %@", JSValueToNSString(ctx, argv[0]) );
	return NULL;
}

EJ_BIND_FUNCTION(require, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }

	[[EJApp instance] loadScriptAtPath:JSValueToNSString(ctx, argv[0])];
	return NULL;
}

EJ_BIND_FUNCTION(openURL, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }
	
	NSString * url = JSValueToNSString( ctx, argv[0] );
	if( argc == 2 ) {
		[urlToOpen release];
		urlToOpen = [url retain];
		
		NSString * confirm = JSValueToNSString( ctx, argv[1] );
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Open Browser?" message:confirm delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
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
	
	NSString * title = JSValueToNSString(ctx, argv[0]);
	NSString * message = JSValueToNSString(ctx, argv[1]);
	
	if( getTextCallback ) {
		JSValueUnprotect(ctx, getTextCallback);
	}
	getTextCallback = JSValueToObject(ctx, argv[2], NULL);
	JSValueProtect(ctx, getTextCallback);
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self
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
		NSString * text = @"";
		if( index == 1 ) {
			text = [[alertView textFieldAtIndex:0] text];
		}
		JSValueRef params[] = { NSStringToJSValue([EJApp instance].jsGlobalContext, text) };
		[[EJApp instance] invokeCallback:getTextCallback thisObject:NULL argc:1 argv:params];
		
		JSValueUnprotect([EJApp instance].jsGlobalContext, getTextCallback);
		getTextCallback = NULL;
	}
}


EJ_BIND_FUNCTION(setTimeout, ctx, argc, argv ) {
	return [[EJApp instance] createTimer:ctx argc:argc argv:argv repeat:NO];
}

EJ_BIND_FUNCTION(setInterval, ctx, argc, argv ) {
	return [[EJApp instance] createTimer:ctx argc:argc argv:argv repeat:YES];
}

EJ_BIND_FUNCTION(clearTimeout, ctx, argc, argv ) {
	return [[EJApp instance] deleteTimer:ctx argc:argc argv:argv];
}

EJ_BIND_FUNCTION(clearInterval, ctx, argc, argv ) {
	return [[EJApp instance] deleteTimer:ctx argc:argc argv:argv];
}



EJ_BIND_GET(devicePixelRatio, ctx ) {
	return JSValueMakeNumber( ctx, [UIScreen mainScreen].scale );
}

EJ_BIND_GET(screenWidth, ctx ) {
	return JSValueMakeNumber( ctx, [EJApp instance].view.bounds.size.width );
}

EJ_BIND_GET(screenHeight, ctx ) {
	return JSValueMakeNumber( ctx, [EJApp instance].view.bounds.size.height );
}

EJ_BIND_GET(landscapeMode, ctx ) {
	return JSValueMakeBoolean( ctx, [EJApp instance].landscapeMode );
}

EJ_BIND_GET(userAgent, ctx ) {
	// FIXME?! iPhone3/4/5 and iPod all have the same user agent string ('iPhone')
	// Only iPad is different
	
	return NSStringToJSValue(ctx,
		(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			? @"iPad"
			: @"iPhone"
	);
}

EJ_BIND_GET(appVersion, ctx ) {
	return NSStringToJSValue( ctx, EJECTA_VERSION );
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

@end
