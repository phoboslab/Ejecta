#import "EJBindingEjectaCore.h"

@implementation EJBindingEjectaCore

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
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Open Browser?" message:confirm delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
		[alert show];
		[alert release];
	}
	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
	}
	return NULL;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	if( index == 0 ) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlToOpen]];
	}
	[urlToOpen release];
	urlToOpen = nil;
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

@end
