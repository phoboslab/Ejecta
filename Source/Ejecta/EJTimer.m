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

- (int)scheduleCallback:(JSObjectRef)callback interval:(NSTimeInterval)interval repeat:(BOOL)repeat {
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



@interface EJTimer()
@property (nonatomic, retain) NSDate *target;
@end


@implementation EJTimer
@synthesize active;

- (id)initWithCallback:(JSObjectRef)callbackp interval:(NSTimeInterval)intervalp repeat:(BOOL)repeatp {
	if( self = [super init] ) {
		active = true;
		interval = intervalp;
		repeat = repeatp;
		self.target = [NSDate dateWithTimeIntervalSinceNow:interval];
		
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
	if( active && self.target.timeIntervalSinceNow <= 0 ) {
		[[EJApp instance] invokeCallback:callback thisObject:NULL argc:0 argv:NULL];
		
		if( repeat ) {
			self.target = [NSDate dateWithTimeIntervalSinceNow:interval];
		}
		else {
			active = false;
		}
	}
}


@end
