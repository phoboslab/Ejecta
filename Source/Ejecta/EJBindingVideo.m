#import "EJBindingVideo.h"


@implementation EJBindingVideo

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		controller = [AVPlayerViewController new];
		controller.player = [AVPlayer new];
		controller.showsPlaybackControls = NO;
	}
	return self;
}

- (void)prepareGarbageCollection {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[controller.view removeFromSuperview];
	[controller release];
	[path release];
	[super dealloc];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

EJ_BIND_GET(duration, ctx) {
	return JSValueMakeNumber(ctx, controller.player.currentItem.asset.duration.value);
}

EJ_BIND_GET(loop, ctx) {
	return JSValueMakeBoolean( ctx, loop );
}

EJ_BIND_SET(loop, ctx, value) {
	loop = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(controls, ctx) {
	return JSValueMakeBoolean( ctx, controller.showsPlaybackControls);
}

EJ_BIND_SET(controls, ctx, value) {
	controller.showsPlaybackControls = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(currentTime, ctx) {
	return JSValueMakeNumber( ctx, controller.player.currentItem.currentTime.value );
}

EJ_BIND_SET(currentTime, ctx, value) {
	[controller.player seekToTime:CMTimeMakeWithSeconds(JSValueToNumberFast(ctx, value), 1)];
}

EJ_BIND_GET(src, ctx) {
	return path ? NSStringToJSValue(ctx, path) : NULL;
}

EJ_BIND_SET(src, ctx, value) {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[path release];
	path = nil;
	path = [JSValueToNSString(ctx, value) retain];
	
	NSURL *url = [NSURL URLWithString:path];
	if( !url.host ) {
		// No host? Assume we have a local file
		url = [NSURL fileURLWithPath:[scriptView pathForResource:path]];
	}
	
	[controller.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
	controller.showsPlaybackControls = NO;
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
		initWithTarget:self action:@selector(didTap:)];
	tapGesture.delegate = self;
	tapGesture.numberOfTapsRequired = 1;
	[controller.view addGestureRecognizer:tapGesture];
	[tapGesture release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(didFinish:)
		name:AVPlayerItemDidPlayToEndTimeNotification
		object:controller.player.currentItem];
	
	[NSOperationQueue.mainQueue addOperationWithBlock:^{
		[self triggerEvent:@"canplaythrough"];
		[self triggerEvent:@"loadedmetadata"];
	}];
}

- (void)didTap:(UIGestureRecognizer *)gestureRecognizer {
	[self triggerEvent:@"click"];
}

- (void)didFinish:(AVPlayerItem *)moviePlayer {
	if( loop ) {
		[controller.player seekToTime:kCMTimeZero];
	}
	else {
		[controller.player pause];
		[controller.view removeFromSuperview];
		ended = true;
		[self triggerEvent:@"ended"];
	}
}

EJ_BIND_GET(ended, ctx) {
	return JSValueMakeBoolean(ctx, ended);
}

EJ_BIND_GET(paused, ctx) {
	return JSValueMakeBoolean(ctx, (controller.player.rate == 0));
}

EJ_BIND_FUNCTION(play, ctx, argc, argv) {
	if( controller.player.rate != 0 ) {
		// Already playing. Nothing to do here.
		return NULL;
	}
	
	controller.view.frame = scriptView.bounds;
	[scriptView addSubview:controller.view];
	[controller.player play];
	
	return NULL;
}

EJ_BIND_FUNCTION(pause, ctx, argc, argv) {
	[controller.player pause];
	[controller.view removeFromSuperview];
	return NULL;
}

EJ_BIND_FUNCTION(load, ctx, argc, argv) {
	return NULL;
}

EJ_BIND_FUNCTION(canPlayType, ctx, argc, argv) {
	if( argc != 1 ) return NSStringToJSValue(ctx, @"");
	
	NSString *mime = JSValueToNSString(ctx, argv[0]);
	if( [mime hasPrefix:@"video/mp4"] ) {
		return NSStringToJSValue(ctx, @"probably");
	}
	return NSStringToJSValue(ctx, @"");
}

EJ_BIND_EVENT(canplaythrough);
EJ_BIND_EVENT(loadedmetadata);
EJ_BIND_EVENT(ended);
EJ_BIND_EVENT(click);

EJ_BIND_CONST(nodeName, "VIDEO");

@end
