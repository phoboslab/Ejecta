#import "EJBindingImageData.h"

@implementation EJBindingImageData
@synthesize imageData;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj imageData:(EJImageData *)data {
	if( self = [super initWithContext:ctx object:obj argc:0 argv:NULL] ) {
		JSValueProtect(ctx, jsObject);
		imageData = [data retain];
		
		GLubyte * pixels = imageData.pixels;
		int count = imageData.width * imageData.height * 4;
		JSValueRef * values = (JSValueRef*)malloc(count * sizeof(JSValueRef));
		
		for( int i = 0; i < count; i++ ) {
			values[i] = JSValueMakeNumber(ctx, pixels[i]);
			JSValueProtect(ctx, values[i]);
		}
		
		dataArray = JSObjectMakeArray(ctx, count, values, NULL);
		JSValueProtect(ctx, dataArray);
		
		for( int i = 0; i < count; i++ ) {
			JSValueUnprotect(ctx, values[i]);
		}
		free(values);
	}
	return self;
}

- (void)dealloc {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	JSValueUnprotect(ctx, jsObject);
	JSValueUnprotect(ctx, dataArray);
	[imageData release];
	[super dealloc];
}

- (EJImageData *)imageData {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	GLubyte * pixels = imageData.pixels;
	int count = imageData.width * imageData.height * 4;
	
	// Well, this sucks. Where's the JSC API for ByteArrays?
	for( int i = 0; i < count; i+=4 ) {
		pixels[i] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, dataArray, i, NULL));
		pixels[i+1] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, dataArray, i+1, NULL));
		pixels[i+2] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, dataArray, i+2, NULL));
		pixels[i+3] = JSValueToNumberFast(ctx, JSObjectGetPropertyAtIndex(ctx, dataArray, i+3, NULL));
	}
	return imageData;
}

EJ_BIND_GET(data, ctx ) {
	return dataArray;
}

EJ_BIND_GET(width, ctx ) {
	return JSValueMakeNumber( ctx, imageData.width);
}

EJ_BIND_GET(height, ctx ) { 
	return JSValueMakeNumber( ctx, imageData.height );
}

@end
