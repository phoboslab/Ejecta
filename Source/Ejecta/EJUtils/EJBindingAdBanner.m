#if !TARGET_OS_TV

#import "EJBindingAdBanner.h"
#import "EJJavaScriptView.h"

@implementation EJBindingAdBanner

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		if (argc > 0) {
			type = [JSValueToNSString(ctx, argv[0]) retain];
			if (type) {
				type = [type lowercaseString];
			}
		}
	}
	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	
	isAtBottom = NO;
	isAtRight = NO;
	wantsToShow = NO;
	isReady = NO;
	alwaysPortrait = NO;
	x = 0;
	y = 0;
	banner = nil;
	isRectangle = NO;

	if ([type isEqualToString:@"rect"] || [type isEqualToString:@"rectangle"] || [type isEqualToString:@"mediumrectangle"]) {
		@try {
			banner = [[ADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
		}
		@catch (NSException *exception)
		{
			NSLog(@"Current iOS version doesn't supports iAd with ADAdTypeMediumRectangle");
		}
	}
	if (!banner) {
		banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
	}
	else {
		isRectangle = YES;
		alwaysPortrait = NO;
	}

	banner.delegate = self;
	banner.hidden = YES;
	banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	[self doLayout];
	
	[scriptView addSubview:banner];
}

- (void)doLayout {
	short w = 0, h = 0;
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    
//	BOOL landscape = NO;
	if (alwaysPortrait) {
		w = screenRect.size.width;
		h = screenRect.size.height;
//		landscape = NO;
	}
	else {
		w = scriptView.bounds.size.width;
		h = scriptView.bounds.size.height;
//		landscape = [[[NSBundle mainBundle] infoDictionary][@"UIInterfaceOrientation"]
//		             hasPrefix:@"UIInterfaceOrientationLandscape"];
	}

	if (!isRectangle) {
		banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}

	CGRect rect = CGRectMake(x, y, w, h);
	CGSize adSize = [banner sizeThatFits:rect.size];
	[banner setFrame:CGRectMake(x, y, adSize.width, adSize.height)];
}

- (void)doLocate {
	CGRect frame = banner.frame;
	frame.origin.x = x;
	frame.origin.y = y;
	banner.frame = frame;
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	[self triggerEvent:@"click"];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	[self triggerEvent:@"finish"];
}

- (void)dealloc {
	[banner removeFromSuperview];
	[banner release];
	[super dealloc];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)theBanner {
	NSLog(@"AdBanner: Ad loaded");
	isReady = YES;
	if( wantsToShow ) {
		[scriptView bringSubviewToFront:banner];
		banner.hidden = NO;
	}
	[self triggerEvent:@"load"];
}

- (void)bannerView:(ADBannerView *)theBanner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"AdBanner: Failed to receive Ad. Error: %ld - %@", (long)error.code, error.localizedDescription);
	[self triggerEvent:@"error"];
	banner.hidden = YES;
}

EJ_BIND_GET( isReady, ctx ) {
	return JSValueMakeBoolean(ctx, isReady);
}

EJ_BIND_GET( isAtBottom, ctx ) {
	return JSValueMakeBoolean(ctx, isAtBottom);
}

EJ_BIND_SET( isAtBottom, ctx, value ) {
	isAtBottom = JSValueToBoolean(ctx, value);
	y = isAtBottom
	    ? scriptView.bounds.size.height - banner.frame.size.height
		: 0;
	[self doLocate];
}


EJ_BIND_GET(isAtRight, ctx)
{
	return JSValueMakeBoolean(ctx, isAtRight);
}

EJ_BIND_SET(isAtRight, ctx, value)
{
	isAtRight = JSValueToBoolean(ctx, value);
	x = isAtRight
	    ? scriptView.bounds.size.width - banner.frame.size.width
		: 0;
	[self doLocate];
}


EJ_BIND_GET(isRectangle, ctx)
{
	return JSValueMakeBoolean(ctx, isRectangle);
}

EJ_BIND_GET(alwaysPortrait, ctx)
{
	return JSValueMakeBoolean(ctx, alwaysPortrait);
}

EJ_BIND_SET(alwaysPortrait, ctx, value)
{
	if (isRectangle) {
		return;
	}
	alwaysPortrait = JSValueToBoolean(ctx, value);

	[self doLayout];
}


EJ_BIND_GET(x, ctx)
{
	return JSValueMakeNumber(ctx, x);
}

EJ_BIND_SET(x, ctx, value)
{
	short newX = JSValueToNumberFast(ctx, value);
	if (newX != x) {
		x = newX;
		CGRect frame = banner.frame;
		frame.origin.x = x;
	}
}

EJ_BIND_GET(y, ctx)
{
	return JSValueMakeNumber(ctx, y);
}

EJ_BIND_SET(y, ctx, value)
{
	short newY = JSValueToNumberFast(ctx, value);
	if (newY != y) {
		y = newY;
		CGRect frame = banner.frame;
		frame.origin.y = y;
	}
}

EJ_BIND_GET(width, ctx)
{
	return JSValueMakeNumber(ctx, banner.frame.size.width);
}
EJ_BIND_GET(height, ctx)
{
	return JSValueMakeNumber(ctx, banner.frame.size.height);
}
EJ_BIND_GET(type, ctx)
{
	return NSStringToJSValue(ctx, type);
}

EJ_BIND_FUNCTION(hide, ctx, argc, argv ) {
	banner.hidden = YES;
	wantsToShow = NO;
	return NULL;
}

EJ_BIND_FUNCTION(show, ctx, argc, argv ) {
	wantsToShow = YES;
	if( isReady ) {
		[scriptView bringSubviewToFront:banner];
		banner.hidden = NO;
	}
	return NULL;
}

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(click);
EJ_BIND_EVENT(finish);

@end

#endif
