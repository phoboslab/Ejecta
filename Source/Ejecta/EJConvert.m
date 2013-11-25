#import "EJConvert.h"

NSString *JSValueToNSString( JSContextRef ctx, JSValueRef v ) {
	JSStringRef jsString = JSValueToStringCopy( ctx, v, NULL );
	if( !jsString ) return nil;
	
	NSString *string = (NSString *)JSStringCopyCFString( kCFAllocatorDefault, jsString );
	[string autorelease];
	JSStringRelease( jsString );
	
	return string;
}

JSValueRef NSStringToJSValue( JSContextRef ctx, NSString *string ) {
	JSStringRef jstr = JSStringCreateWithCFString((CFStringRef)string);
	JSValueRef ret = JSValueMakeString(ctx, jstr);
	JSStringRelease(jstr);
	return ret;
}

double JSValueToNumberFast( JSContextRef ctx, JSValueRef v ) {
	// This struct represents the memory layout of a C++ JSValue instance
	// See JSC/runtime/JSValue.h for an explanation of the tagging
	struct {
		unsigned char cppClassData[4];
		union {
			double asDouble;
			struct { int32_t asInt; int32_t tag; } asBits;
		} payload;
	} *decoded = (void *)v;
	
	return decoded->payload.asBits.tag < 0xfffffff9
		? decoded->payload.asDouble
		: decoded->payload.asBits.asInt;
}

void JSValueUnprotectSafe( JSContextRef ctx, JSValueRef v ) {
	if( ctx && v ) {
		JSValueUnprotect(ctx, v);
	}
}

JSValueRef NSObjectToJSValue( JSContextRef ctx, NSObject *obj ) {
	JSValueRef ret = NULL;
	
	// String
	if( [obj isKindOfClass:[NSString class]] ) {
		ret = NSStringToJSValue(ctx, (NSString *)obj);
	}
	
	// Number or Bool
	else if( [obj isKindOfClass:[NSNumber class]] ) {
		NSNumber *number = (NSNumber *)obj;
		if (strcmp([number objCType], @encode(BOOL)) == 0) {
			ret = JSValueMakeBoolean(ctx, number.boolValue);
		}
		else {
			ret = JSValueMakeNumber(ctx, number.doubleValue);
		}
	}
	
	// Date
	else if( [obj isKindOfClass:[NSDate class]] ) {
		NSDate *date = (NSDate *)obj;
		JSValueRef timestamp = JSValueMakeNumber(ctx, date.timeIntervalSince1970 * 1000.0);
		ret = JSObjectMakeDate(ctx, 1, &timestamp, NULL);
	}
	
	// Array
	else if( [obj isKindOfClass:[NSArray class]] ) {
		NSArray *array = (NSArray *)obj;
		JSValueRef *args = malloc(array.count * sizeof(JSValueRef));
		for( int i = 0; i < array.count; i++ ) {
			args[i] = NSObjectToJSValue(ctx, [array objectAtIndex:i] );
		}
		ret = JSObjectMakeArray(ctx, array.count, args, NULL);
		free(args);
	}
	
	// Dictionary
	else if( [obj isKindOfClass:[NSDictionary class]] ) {
		NSDictionary *dict = (NSDictionary *)obj;
		ret = JSObjectMake(ctx, NULL, NULL);
		for( NSString *key in dict ) {
			JSStringRef jsKey = JSStringCreateWithUTF8CString(key.UTF8String);
			JSValueRef value = NSObjectToJSValue(ctx, [dict objectForKey:key]);
			JSObjectSetProperty(ctx, (JSObjectRef)ret, jsKey, value, NULL, NULL);
			JSStringRelease(jsKey);
		}
	}
	
	return ret ? ret : JSValueMakeNull(ctx);
}

NSObject *JSValueToNSObject( JSContextRef ctx, JSValueRef value ) {
	JSType type = JSValueGetType(ctx, value);
	
	switch( type ) {
		case kJSTypeString: return JSValueToNSString(ctx, value);
		case kJSTypeBoolean: return [NSNumber numberWithBool:JSValueToBoolean(ctx, value)];
		case kJSTypeNumber: return [NSNumber numberWithDouble:JSValueToNumberFast(ctx, value)];
		case kJSTypeNull: return [NSNull null];
		case kJSTypeUndefined: return nil;
		case kJSTypeObject: break;
	}
	
	// All objects are converted to NSDictionary; even Arrays.
	// Doesn't handle Regexp or Date objects correctly. FIXME.
	if( type == kJSTypeObject ) {
		JSObjectRef jsObj = (JSObjectRef)value;
		JSPropertyNameArrayRef properties = JSObjectCopyPropertyNames(ctx, jsObj);
		int count = JSPropertyNameArrayGetCount(properties);
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
		for( int i = 0; i < count; i++ ) {
			JSStringRef jsName = JSPropertyNameArrayGetNameAtIndex(properties, i);
			NSObject *obj = JSValueToNSObject(ctx, JSObjectGetProperty(ctx, jsObj, jsName, NULL));
			
			if( obj ) {
				NSString *name = (NSString *)JSStringCopyCFString( kCFAllocatorDefault, jsName );
				[dict setObject:obj forKey:name];
				[name release];
			}
		}
		
		JSPropertyNameArrayRelease(properties);
		return dict;
	}
	
	return nil;
}

