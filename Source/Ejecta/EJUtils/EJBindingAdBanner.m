#import "EJBindingAdBanner.h"
#import "EJJavaScriptView.h"

@implementation EJBindingAdBanner

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		isAtBottom = NO;
		wantsToShow = NO;
		isReady = NO;
		
		banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
		banner.delegate = self;
		banner.hidden = YES;
		
		banner.requiredContentSizeIdentifiers = [NSSet setWithObjects:
			([[EJAppViewController instance] landscapeMode]
				? ADBannerContentSizeIdentifierLandscape
				: ADBannerContentSizeIdentifierPortrait),
			nil];
		
		[[EJJavaScriptView sharedView] addSubview:banner];
		NSLog(@"AdBanner: init at y %f", banner.frame.origin.y);
	}
	return self;
}

- (void)dealloc {
	[banner removeFromSuperview];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)theBanner {
	NSLog(@"AdBanner: Ad loaded");
	isReady = YES;
	if( wantsToShow ) {
		[[EJJavaScriptView sharedView] bringSubviewToFront:banner];
		banner.hidden = NO;
	}
	[self triggerEvent:@"load" argc:0 argv:NULL];
}

- (void)bannerView:(ADBannerView *)theBanner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"AdBanner: Failed to receive Ad. Error: %d - %@", error.code, error.localizedDescription);
	[self triggerEvent:@"error" argc:0 argv:NULL];
	banner.hidden = YES;
}


EJ_BIND_GET( isAtBottom, ctx ) {
	return JSValueMakeBoolean(ctx, isAtBottom);
}

EJ_BIND_SET( isAtBottom, ctx, value ) {
	isAtBottom = JSValueToBoolean(ctx, value);
	
	CGRect frame = banner.frame;
	frame.origin.y = isAtBottom
		? [EJJavaScriptView sharedView].bounds.size.height - frame.size.height
		: 0;
		
	banner.frame = frame;
}

EJ_BIND_FUNCTION(hide, ctx, argc, argv ) {
	banner.hidden = YES;
	wantsToShow = NO;
	return NULL;
}

EJ_BIND_FUNCTION(show, ctx, argc, argv ) {
	wantsToShow = YES;
	if( isReady ) {
		[[EJJavaScriptView sharedView] bringSubviewToFront:banner];
		banner.hidden = NO;
	}
	return NULL;
}

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);

@end
