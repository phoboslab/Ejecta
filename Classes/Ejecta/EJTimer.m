#import "EJTimer.h"

@implementation EJTimer
@synthesize target;
@synthesize active;

- (id)initWithCurrentTime:(NSTimeInterval)currentTime interval:(float)intervalp callback:(JSObjectRef)callbackp repeat:(BOOL)repeatp {
	if( self = [super init] ) {
		active = true;
		interval = intervalp;
		repeat = repeatp;
		target = currentTime + interval;
		
		callback = callbackp;
		JSValueProtect([EJApp instance].jsGlobalContext, callback);
	}
	return self;
}

- (void)dealloc {
	JSValueUnprotect([EJApp instance].jsGlobalContext, callback);
	[super dealloc];
}

- (void)check:(NSTimeInterval)currentTime {
	if( target <= currentTime ) {
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
