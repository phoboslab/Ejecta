#import "EJBindingBase.h"
#import <CoreLocation/CoreLocation.h>

typedef struct {
	JSObjectRef callback;
	JSObjectRef errback;
	BOOL oneShot;
} EJGeolocationCallback;

enum {
	kEJGeolocationErrorDenied = 1,
	kEJGeolocationErrorUnavailable = 2,
	kEJGeolocationErrorTimeout = 3
};

@interface EJBindingGeolocation : EJBindingBase <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	NSMutableDictionary *callbacks;
	int currentIndex;
}

@end
