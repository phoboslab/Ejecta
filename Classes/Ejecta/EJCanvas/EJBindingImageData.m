#import "EJBindingImageData.h"

@implementation EJBindingImageData
@synthesize imageData;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj imageData:(EJImageData *)data {
	if( self = [super initWithContext:ctx object:obj argc:0 argv:NULL] ) {
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
		
		JSObjectToByteArray(ctx, dataArray, imageData.pixels, count );
	}
	
	return imageData;
}

EJ_BIND_GET(data, ctx ) {
	if( !dataArray ) {
		int count = imageData.width * imageData.height * 4;
		dataArray = ByteArrayToJSObject(ctx, imageData.pixels, count);
		JSValueProtect(ctx, dataArray);
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
