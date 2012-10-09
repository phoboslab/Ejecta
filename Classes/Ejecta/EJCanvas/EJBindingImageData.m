#import "EJBindingImageData.h"

@implementation EJBindingImageData
@synthesize imageData;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj imageData:(EJImageData *)data {
	if( self = [super initWithContext:ctx object:obj argc:0 argv:NULL] ) {
		JSValueProtect(ctx, jsObject);
		imageData = [data retain];
		
		GLubyte * pixels = imageData.pixels;
		int count = imageData.width * imageData.height * 4;
		
		dataArray = ByteArrayToJSObject(ctx, pixels, count);
		JSValueProtect(ctx, dataArray);
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
	int count = imageData.width * imageData.height * 4;
	
	JSObjectToByteArray(ctx, dataArray, imageData.pixels, count );
	
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
