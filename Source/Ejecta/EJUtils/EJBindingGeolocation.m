#import "EJBindingGeolocation.h"

@implementation EJBindingGeolocation

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		
		callbacks = [NSMutableDictionary new];
	}
	return self;
}

- (void)prepareGarbageCollection {
	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
	[locationManager release];
	locationManager = NULL;
	
	[self clearCallbacks];
}

- (void)dealloc {
	[locationManager release];
	[self clearCallbacks];
	[super dealloc];
}

- (void)clearCallbacks {
	// Unprotect and remove all callbacks
	for( NSNumber *key in callbacks ) {
		EJGeolocationCallback cb;
		[callbacks[key] getValue:&cb];
		
		JSValueUnprotectSafe(scriptView.jsGlobalContext, cb.callback);
		JSValueUnprotectSafe(scriptView.jsGlobalContext, cb.errback);
	}
	[callbacks removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if( callbacks.count == 0 ) { return; } // Nothing to do here?
	
	// Build the position object
	CLLocation *location = [locations lastObject];
	JSValueRef position = NSObjectToJSValue(scriptView.jsGlobalContext, @{
		@"coords":@{
			@"latitude": @(location.coordinate.latitude),
			@"longitude": @(location.coordinate.longitude),
			@"altitude": @(location.altitude),
			@"accuracy": @(location.horizontalAccuracy),
			@"altitudeAccuracy": @(location.verticalAccuracy),
			@"heading": @(manager.heading.trueHeading),
			@"speed": @(location.speed)
		},
		@"timestamp": location.timestamp
	});
	
	[self invokeCallbacksWithError:false argc:1 argv:(JSValueRef[]){position}];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if( error.code == kCLErrorLocationUnknown ) { return; } // Ignore this error; System will try again
	
	int code = error.code == kCLErrorDenied
		? kEJGeolocationErrorDenied
		: kEJGeolocationErrorUnavailable;
	
	NSString *message = error.code == kCLErrorDenied
		? @"Denied"
		: @"Unknown Error";
			
	JSValueRef jsError = NSObjectToJSValue(scriptView.jsGlobalContext, @{
		@"code": @(code),
		@"message": message
	});
	
	[self invokeCallbacksWithError:true argc:1 argv:(JSValueRef[]){jsError}];
}

- (void)invokeCallbacksWithError:(BOOL)error argc:(int)argc argv:(JSValueRef[])argv {
	NSMutableArray *toRemove = [NSMutableArray new];
	for( NSNumber *key in callbacks ) {
		EJGeolocationCallback cb;
		[callbacks[key] getValue:&cb];
		
		if( !error && cb.callback ) {
			[scriptView invokeCallback:cb.callback thisObject:NULL argc:argc argv:argv];
		}
		else if( error && cb.errback ) {
			[scriptView invokeCallback:cb.errback thisObject:NULL argc:argc argv:argv];
		}
		
		// Unprotect and remove this callback?
		if( cb.oneShot ) {
			JSValueUnprotectSafe(scriptView.jsGlobalContext, cb.callback);
			JSValueUnprotectSafe(scriptView.jsGlobalContext, cb.errback);
			[toRemove addObject:key];
		}
	}
	[callbacks removeObjectsForKeys:toRemove];
	
	
	// Stop updating if we don't have any callbacks left
	if( callbacks.count == 0 ) {
		[locationManager stopUpdatingLocation];
		[locationManager stopUpdatingHeading];
	}
}

- (int)addCallback:(JSObjectRef)callback errback:(JSObjectRef)errback oneShot:(BOOL)oneShot {
	// Stop first, so we get at least one call to didUpdate
	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
	
	[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
	
	if( callback ) { JSValueProtect(scriptView.jsGlobalContext, callback); }
	if( errback ) { JSValueProtect(scriptView.jsGlobalContext, errback); }
	
	EJGeolocationCallback cb = {
		.callback = callback,
		.errback = errback,
		.oneShot = oneShot
	};
	
	currentIndex++;
	callbacks[@(currentIndex)] = [NSValue valueWithBytes:&cb objCType:@encode(EJGeolocationCallback)];
	return currentIndex;
}



EJ_BIND_FUNCTION(watchPosition, ctx, argc, argv) {
	if( argc < 1 || !JSValueIsObject(ctx, argv[0]) ) {
		return NULL;
	}
	
	JSObjectRef callback = (JSObjectRef)argv[0];
	JSObjectRef errback = NULL;
	
	if( argc > 1 && JSValueIsObject(ctx, argv[1]) ) {
		errback = (JSObjectRef)argv[1];
	}
	
	// Allways enable high accuracy when watching
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.distanceFilter = kCLDistanceFilterNone;

	int index = [self addCallback:callback errback:errback oneShot:NO];
	return JSValueMakeNumber(ctx, index);
}

EJ_BIND_FUNCTION(clearWatch, ctx, argc, argv) {
	EJ_UNPACK_ARGV(int index);
	
	EJGeolocationCallback cb = {};
	[callbacks[@(index)] getValue:&cb];
	
	JSValueUnprotectSafe(ctx, cb.callback);
	JSValueUnprotectSafe(ctx, cb.errback);
	[callbacks removeObjectForKey:@(index)];
	
	// Stop updating if we don't have any callbacks left
	if( callbacks.count == 0 ) {
		[locationManager stopUpdatingLocation];
		[locationManager stopUpdatingHeading];
	}
	
	return NULL;
}

EJ_BIND_FUNCTION(getCurrentPosition, ctx, argc, argv) {
	if( argc < 1 || !JSValueIsObject(ctx, argv[0]) ) {
		return NULL;
	}
	
	JSObjectRef callback = (JSObjectRef)argv[0];
	JSObjectRef errback = NULL;
	
	if( argc > 1 && JSValueIsObject(ctx, argv[1]) ) {
		errback = (JSObjectRef)argv[1];
	}
	
	if( argc > 2 && JSValueIsObject(ctx, argv[2]) ) {
		JSStringRef jsHighAccuracyName = JSStringCreateWithUTF8CString("enableHighAccuracy");
		if( JSValueToBoolean(ctx, JSObjectGetProperty(ctx, (JSObjectRef)argv[2], jsHighAccuracyName, NULL)) ) {
			locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		}
		JSStringRelease(jsHighAccuracyName);
	}
	
	[self addCallback:callback errback:errback oneShot:true];
	return NULL;
}

EJ_BIND_CONST(PERMISSION_DENIED, kEJGeolocationErrorDenied);
EJ_BIND_CONST(POSITION_UNAVAILABLE, kEJGeolocationErrorUnavailable);
EJ_BIND_CONST(TIMEOUT, kEJGeolocationErrorTimeout);

@end
