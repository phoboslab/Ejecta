
#import "EJBindingTimer.h"

@implementation EJBindingTimer



- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
    
    if( self = [super initWithContext:ctxp argc:argc argv:argv] ) {
        timers = [[NSMutableDictionary alloc] init];
		// Listen to notifications to pause and resume timers
		NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(pauseTimers:) name:@"UIApplicationWillResignActiveNotification" object:nil];
		[nc addObserver:self selector:@selector(pauseTimers:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
		[nc addObserver:self selector:@selector(resumeTimers:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    }
    return self;
    
}


        
- (JSValueRef)createTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat {
	if( argc != 2 || !JSValueIsObject(ctx, argv[0]) || !JSValueIsNumber(ctx, argv[1]) ) return NULL;
	
	JSObjectRef func = JSValueToObject(ctx, argv[0], NULL);
	JSValueProtect(ctx, func);
	NSValue * callback = [NSValue valueWithPointer:func];
	float interval = JSValueToNumberFast(ctx, argv[1])/1000;
   
	uniqueId++;
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerCallback:) userInfo:callback repeats:repeat];
	[timers setObject:timer forKey:[NSNumber numberWithInt:uniqueId]];
	return JSValueMakeNumber( ctx, uniqueId );
}

- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( argc != 1 || !JSValueIsNumber(ctx, argv[0]) ) return NULL;
	
	NSNumber * timerId = [NSNumber numberWithInt:(int)JSValueToNumberFast(ctx, argv[0])];
	NSTimer * timer = [timers objectForKey:timerId];
	
	//JSObjectRef func = [[timer userInfo] pointeValue];
	//JSValueUnprotect(ctx, func); // Humm... seems to crash? FIXME
	
	[timer invalidate];
	[timers removeObjectForKey:timerId];
	return NULL;
}


- (void)timerCallback:(NSTimer *)timer {
	JSObjectRef func = [[timer userInfo] pointerValue];
	[scriptView invokeCallback:func thisObject:NULL argc:0 argv:NULL];
}

- (void)pauseTimers:(NSNotification *)notification {
	if( pauseTime ) return; // already paused?
	
	pauseTime = [[NSDate dateWithTimeIntervalSinceNow:0] retain];
	timerTimes = [[NSMutableDictionary alloc] init];
    
	for( NSString * key in timers ) {
		NSTimer * timer = [timers objectForKey:key];
		if( [timer isValid] ) {
			//NSLog( @"Pausing timer: %@ with date : %@", timer, [timer fireDate] );
			[timerTimes setObject:[timer fireDate] forKey:key];
			[timer setFireDate:[NSDate distantFuture]];
		}
	}
}

- (void)resumeTimers:(NSNotification *)notification {
	if( !timerTimes ) return;
	
	for( NSString * key in timerTimes ) {
		NSTimer * timer = [timers objectForKey:key];
		NSDate * timerTime = [timerTimes objectForKey:key];
		if(	timer && timerTime ) {
			float nudge = [pauseTime timeIntervalSinceNow] * -1;
			//NSLog( @"Resuming timer: %@ with nudge : %f", timer, nudge );
			[timer setFireDate:[timerTime initWithTimeInterval:nudge sinceDate:timerTime]];
		}
	}
	
	[pauseTime release];
	pauseTime = nil;
	
	[timerTimes release];
	timerTimes = nil;
}


EJ_BIND_FUNCTION(setTimeout, ctx, argc, argv ) {
	return [self createTimer:ctx argc:argc argv:argv repeat:NO];
}

EJ_BIND_FUNCTION(setInterval, ctx, argc, argv ) {
	return [self createTimer:ctx argc:argc argv:argv repeat:YES];
}

EJ_BIND_FUNCTION(clearTimeout, ctx, argc, argv ) {
	return [self deleteTimer:ctx argc:argc argv:argv];
}

EJ_BIND_FUNCTION(clearInterval, ctx, argc, argv ) {
	return [self deleteTimer:ctx argc:argc argv:argv];
}



@end
