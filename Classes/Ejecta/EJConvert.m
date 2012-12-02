#import "EJConvert.h"

// Typed array type identifiers
#define TA_Int8Array     1
#define TA_Uint8Array    2
#define TA_Int16Array    3
#define TA_Uint16Array   4
#define TA_Int32Array    5
#define TA_Uint32Array   6
#define TA_Float32Array  7
#define TA_Float64Array  8

NSString * JSValueToNSString( JSContextRef ctx, JSValueRef v ) {
	JSStringRef jsString = JSValueToStringCopy( ctx, v, NULL );
	if( !jsString ) return nil;
	
	NSString * string = (NSString *)JSStringCopyCFString( kCFAllocatorDefault, jsString );
	[string autorelease];
	JSStringRelease( jsString );
	
	return string;
}

JSValueRef NSStringToJSValue( JSContextRef ctx, NSString * string ) {
	JSStringRef jstr = JSStringCreateWithCFString((CFStringRef)string);
	JSValueRef ret = JSValueMakeString(ctx, jstr);
	JSStringRelease(jstr);
	return ret;
}

JSValueRef NSStringToJSValueProtect( JSContextRef ctx, NSString * string ) {
	JSValueRef ret = NSStringToJSValue( ctx, string );
	JSValueProtect(ctx, ret);
	return ret;
}

double JSValueToNumberFast( JSContextRef ctx, JSValueRef v ) {
	unsigned char * bytes = ((unsigned char *) v) + 8;
	unsigned char * tagBytes = ((unsigned char *) v) + 12;
	int32_t unionTag = *((int32_t*)tagBytes);
	if( unionTag < 0xfffffff8 ) {
		return *((double *) bytes);
	}
	else {
		return *((int32_t *) bytes);
	}
}

EJColorRGBA JSValueToColorRGBA(JSContextRef ctx, JSValueRef value) {
	EJColorRGBA c = {.hex = 0xff000000};
	if( !JSValueIsString(ctx, value) ) { return c; }
	
	JSStringRef jsString = JSValueToStringCopy( ctx, value, NULL );
	int length = JSStringGetLength( jsString );
	
	const JSChar * jsc = JSStringGetCharactersPtr(jsString);
	char str[] = "ffffff";
	
	// #f0f format
	if( length == 4 ) {
		str[0] = str[1] = jsc[3];
		str[2] = str[3] = jsc[2];
		str[4] = str[5] = jsc[1];
		c.hex = 0xff000000 | strtol( str, NULL, 16 );
	}
	
	// #ff00ff format
	else if( length == 7 ) {
		str[0] = jsc[5];
		str[1] = jsc[6];
		str[2] = jsc[3];
		str[3] = jsc[4];
		str[4] = jsc[1];
		str[5] = jsc[2];
		c.hex = 0xff000000 | strtol( str, NULL, 16 );
	}
	
	// assume rgb(255,0,255) or rgba(255,0,255,0.5) format
	else {
		int current = 0;
		for( int i = 4; i < length-1 && current < 4; i++ ) {
			if( current == 3 ) {
				// If we have an alpha component, copy the rest of the wide
				// string into a char array and use atof() to parse it.
				char alpha[8] = { 0,0,0,0, 0,0,0,0 };
				for( int j = 0; i + j < length-1 && j < 7; j++ ) {
					alpha[j] = jsc[i+j];
				}
				c.components[current] = atof(alpha) * 255.0f;
				current++;
			}
			else if( isdigit(jsc[i]) ) {
				c.components[current] = c.components[current] * 10 + (jsc[i] - '0'); 
			}
			else if( jsc[i] == ',' || jsc[i] == ')' ) {
				current++;
			}
		}
	}
	JSStringRelease(jsString);
	return c;
}

JSValueRef ColorRGBAToJSValue( JSContextRef ctx, EJColorRGBA c ) {
	static char buffer[32];
	sprintf(buffer, "rgba(%d,%d,%d,%.3f)", c.rgba.r, c.rgba.g, c.rgba.b, (float)c.rgba.a/255.0f );
	
	JSStringRef src = JSStringCreateWithUTF8CString( buffer );
	JSValueRef ret = JSValueMakeString(ctx, src);
	JSStringRelease(src);
	return ret;
}

JSObjectRef ByteArrayToJSObject( JSContextRef ctx, unsigned char * bytes, int count ) {
	// This creates a JSON string from a byte array and then uses the JSC APIs
	// JSValueMakeFromJSONString function to convert it into a JSObject that
	// is an array. It's faster than repeatedly calling JSValueMakeNumber and
	// JSValueMakeArray.

	// This sucks. Where's the JSC API for ByteArrays?
	
	
	if( count < 1 ) {
		return JSObjectMakeArray(ctx, 0, NULL, NULL);
	}
	
	// Build the JSON string from the byte array
	int bufferLength = count * 4 + 3; // Max 4 chars per element + "[]\0"
	char * jsonBuffer = (char *)malloc( bufferLength );
		
	jsonBuffer[0] = '[';
	int pos = 0;
	for( int i = 0; i < count; i++ ) {
		unsigned char n = *(bytes + i);
		if( n > 99 ) { jsonBuffer[++pos] = (n / 100) + '0'; }
		if( n > 9 ) { jsonBuffer[++pos] = ((n % 100)/10) + '0'; }
		jsonBuffer[++pos] = (n % 10) + '0';
		jsonBuffer[++pos] = ',';
	}
	
	jsonBuffer[pos] = ']'; // overwrite last comma
	jsonBuffer[++pos] = '\0';
	
	// Convert the json string to an object
	JSStringRef jss = JSStringCreateWithUTF8CString(jsonBuffer);
	JSObjectRef array = (JSObjectRef)JSValueMakeFromJSONString(ctx, jss);
	
	free(jsonBuffer);
	JSStringRelease(jss);
	
	return array;
}

void JSObjectToByteArray( JSContextRef ctx, JSObjectRef array, unsigned char * bytes, int count ) {
	// Converting a JSArray to byte buffer seems to be faster without the JSON intermediate
	for( int i = 0; i < count; i++ ) {
		bytes[i] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, array, i, NULL));
	}
}

void JSTypedArrayToBuffer( JSContextRef ctx, JSObjectRef jsArray, int *size, void **buffer) {
    // Convert the Ejecta Typed array shim object to a buffer.
    JSStringRef jsLengthProp = JSStringCreateWithUTF8CString("length");
    JSValueRef jsLength = JSObjectGetProperty(ctx, jsArray, jsLengthProp, NULL);
    JSStringRelease(jsLengthProp);
    
    JSStringRef jsTypeProp = JSStringCreateWithUTF8CString("__ejecta_type__");
    JSValueRef jsType = JSObjectGetProperty(ctx, jsArray, jsTypeProp, NULL);
    JSStringRelease(jsTypeProp);
    
    int length = (size_t) JSValueToNumberFast(ctx, jsLength);
    int type = (int) JSValueToNumberFast(ctx, jsType);
    
    *size = 0;
    
    // TODO(vikram): Clean this up to a more concise form.
    switch (type) {
        case TA_Int8Array:
        {
            *size = length;
            char *a = (char *)malloc(*size);
            
            for( int i = 0; i < length; i++ ) {
                a[i] = (char)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Uint8Array:
        {
            *size = length;
            unsigned char *a = (unsigned char *)malloc((*size));
            
            for( int i = 0; i < length; i++ ) {
                a[i] = (unsigned char)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Int16Array:
        {
            *size = length * sizeof(short);
            short *a = (short *)malloc(*size);
            
            for( int i = 0; i < length; i++ ) {
                a[i] = (short)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Uint16Array:
        {
            *size = length * sizeof(unsigned short);
            unsigned short *a = (unsigned short *)malloc(*size);
            
            for ( int i = 0; i < length; i++ ) {
                a[i] = (unsigned short)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Int32Array:
        {
            *size = length * sizeof(int);
            int *a = (int *)malloc(*size);
            
            for( int i = 0; i < length; i++ ) {
                a[i] = (int)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Uint32Array:
        {
            *size = length * sizeof(unsigned int);
            unsigned int *a = (unsigned int *)malloc(*size);
            
            for ( int i = 0; i < length; i++ ) {
                a[i] = (unsigned int)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Float32Array:
        {
            *size = length * sizeof(float);
            float *a = (float *)malloc(*size);
            
            for( int i = 0; i < length; i++ ) {
                a[i] = (float)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
        case TA_Float64Array:
        {
            *size = length * sizeof(double);
            double *a = (double *)malloc(*size);
            
            for( int i = 0; i < length; i++ ) {
                a[i] = (double)JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
            }
            
            *buffer = (GLvoid *)a;
            break;
        }
    }
}

