#import "EJBindingImageData.h"
#import <JavaScriptCore/JSTypedArray.h>

@implementation EJBindingImageData
@synthesize imageData;

- (id)initWithImageData:(EJImageData *)data {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		imageData = [data retain];
		dataArray = NULL;
	}
	return self;
}

- (void)dealloc {
	JSContextRef ctx = [EJApp instance].jsGlobalContext;
	if( dataArray ) {
		JSValueUnprotect(ctx, dataArray);
	}
	
	[imageData release];
	[super dealloc];
}

- (EJImageData *)imageData {
	if( dataArray ) {
		// Copy values from the JSArray back into the imageData
		JSContextRef ctx = [EJApp instance].jsGlobalContext;
		int count = imageData.width * imageData.height * 4;
		
		void * data = JSTypedArrayGetDataPtr(ctx, dataArray, NULL);
		memcpy(imageData.pixels.mutableBytes, data, count);
	}
	
	return imageData;
}

- (EJTexture *)texture {
	return imageData.texture;
}

EJ_BIND_GET(data, ctx ) {
	if( !dataArray ) {
		int count = imageData.width * imageData.height * 4;
		
		dataArray = JSTypedArrayMake(ctx, kJSTypedArrayTypeUint8ClampedArray, count);
		JSValueProtect(ctx, dataArray);
		
		void * data = JSTypedArrayGetDataPtr(ctx, dataArray, NULL);
		memcpy(data, imageData.pixels.bytes, count);
	}
	return dataArray;
}

EJ_BIND_GET(width, ctx ) {
	return JSValueMakeNumber( ctx, imageData.width);
}

EJ_BIND_GET(height, ctx ) { 
	return JSValueMakeNumber( ctx, imageData.height );
}

@end
