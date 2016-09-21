// This class provides a simple proxy for other classes to avoid them being
// retained. Adapted from:
// http://stackoverflow.com/a/13921278/1525473

// When installing a delegate object for one of the system APIs, this object
// will typically be retained by that API. This can cause problems where objects
// retain each other, causing them to never be released.

// With this proxy, we can install delegates that won't be retained by the
// system API - however, we now have to take care that these objects remove
// themselfs as a delegate when they are released.


#import <Foundation/Foundation.h>

@interface EJNonRetainingProxy : NSObject {
	id target;
}

+ (EJNonRetainingProxy *)proxyWithTarget:(id)target;

@end
