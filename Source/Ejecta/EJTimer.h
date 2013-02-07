#import <Foundation/Foundation.h>
#import "EJAppViewController.h"

@class EJJavaScriptView;

@interface EJTimerCollection : NSObject {
	NSMutableDictionary * timers;
	int lastId;
}

- (int)scheduleCallback:(JSObjectRef)callback interval:(NSTimeInterval)interval repeat:(BOOL)repeat;
- (void)cancelId:(int)timerId;
- (void)update;

@end


@interface EJTimer : NSObject {
	NSTimeInterval interval;
	JSObjectRef callback;
	BOOL active, repeat;
}

- (id)initWithCallback:(JSObjectRef)callbackp interval:(NSTimeInterval)intervalp repeat:(BOOL)repeatp;
- (void)check;

@property (readonly) BOOL active;

@end
