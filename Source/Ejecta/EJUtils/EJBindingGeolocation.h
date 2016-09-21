// This class exposes the geo-location of the device to JavaScript. Typically,
// this it is lazily instantiated in the Ejecta.js, when `navigator.geolocation`
// is first accessed.

// The `watchPosition()`, `clearWatch()` and `getCurrentPosition()` methods are
// closely modeled to the spec.

#import "EJBindingBase.h"
#import <CoreLocation/CoreLocation.h>

enum {
	kEJGeolocationErrorDenied = 1,
	kEJGeolocationErrorUnavailable = 2,
	kEJGeolocationErrorTimeout = 3
};

@interface EJGeolocationCallback : NSObject {
	EJJavaScriptView *scriptView;
	JSObjectRef callback;
	JSObjectRef errback;
	BOOL oneShot;
}

- (id)initWithScriptView:(EJJavaScriptView *)scriptViewp
	callback:(JSObjectRef)callbackp errback:(JSObjectRef)errbackp
	oneShot:(BOOL)oneShotp;

@property (readonly) JSObjectRef callback;
@property (readonly) JSObjectRef errback;
@property (readonly) BOOL oneShot;

@end


@interface EJBindingGeolocation : EJBindingBase <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	NSMutableDictionary *callbacks;
	int currentIndex;
}

@end
