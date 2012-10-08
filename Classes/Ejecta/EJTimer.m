#import "EJTimer.h"


@implementation EJTimerCollection

- (id)init {
	if( self = [super init] ) {
		timers = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[timers release];
	[super dealloc];
}

- (int)scheduleCallback:(JSObjectRef)callback interval:(float)interval repeat:(BOOL)repeat {
	lastId++;
	
	EJTimer * timer = [[EJTimer alloc] initWithCallback:callback interval:interval repeat:repeat];
	[timers setObject:timer forKey:[NSNumber numberWithInt:lastId]];
	[timer release];
	return lastId;
}

- (void)cancelId:(int)timerId {
	[timers removeObjectForKey:[NSNumber numberWithInt:timerId]];
}

- (void)update {	
	for( NSNumber * timerId in [timers allKeys]) {
		EJTimer * timer = [timers objectForKey:timerId];
		[timer check];
		
		if( !timer.active ) {
			[timers removeObjectForKey:timerId];
		}		
	}
}

@end



@implementation EJTimer
@synthesize active;

- (id)initWithCallback:(JSObjectRef)callbackp interval:(float)intervalp repeat:(BOOL)repeatp {
	if( self = [super init] ) {
		active = true;
		interval = intervalp;
		repeat = repeatp;
		target = [NSDate timeIntervalSinceReferenceDate] + interval;
		
		callback = callbackp;
		JSValueProtect([EJApp instance].jsGlobalContext, callback);
	}
	return self;
}

- (void)dealloc {
	JSValueUnprotect([EJApp instance].jsGlobalContext, callback);
	[super dealloc];
}

- (void)check {
	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
	
	if( active && target <= currentTime ) {
		[[EJApp instance] invokeCallback:callback thisObject:NULL argc:0 argv:NULL];
		
		if( repeat ) {
			target = currentTime + interval;
		}
		else {
			active = false;
		}
	}
}


@end
