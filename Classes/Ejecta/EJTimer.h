#import <Foundation/Foundation.h>
#import "EJApp.h"

@interface EJTimer : NSObject {
	NSTimeInterval target;
	float interval;
	JSObjectRef callback;
	BOOL active, repeat;
}

- (id)initWithCurrentTime:(NSTimeInterval)currentTime interval:(float)intervalp callback:(JSObjectRef)callbackp repeat:(BOOL)repeatp;
- (void)check:(NSTimeInterval)currentTime;

@property (readonly) NSTimeInterval target;
@property (readonly) BOOL active;


@end
