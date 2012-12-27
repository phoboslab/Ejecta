#import "EJBindingImage.h"
#import "EJApp.h"

@implementation EJBindingImage
@synthesize texture;

- (void)beginLoad {
	// This will begin loading the texture in a background thread and will call the
	// JavaScript onload callback when done
	loading = YES;
	
	NSLog(@"Loading Image: %@", path);
	
	NSString * fullPath = [[EJApp instance] pathForResource:path];
	NSOperationQueue * queue = [EJApp instance].opQueue;
	texture = [[EJTexture alloc] initWithPath:fullPath
		loadOnQueue:queue withTarget:self selector:@selector(endLoad:)];
}

- (void)endLoad:(EJTexture *)tex {
	loading = NO;
	
	if( texture.textureId ) {
		[self triggerEvent:@"load" argc:0 argv:NULL];
	}
	else {
		[self triggerEvent:@"error" argc:0 argv:NULL];
	}
}

- (void)dealloc {
	[texture release];
	[path release];
	[super dealloc];
}

EJ_BIND_GET(src, ctx ) { 
	JSStringRef src = JSStringCreateWithUTF8CString( [path UTF8String] );
	JSValueRef ret = JSValueMakeString(ctx, src);
	JSStringRelease(src);
	return ret;
}

EJ_BIND_SET(src, ctx, value) {
	// If the texture is still loading, do nothing to avoid confusion
	// This will break some edge cases; FIXME
	if( loading ) { return; }
	
	NSString * newPath = JSValueToNSString( ctx, value );
	
	// Same as the old path? Nothing to do here
	if( [path isEqualToString:newPath] ) { return; }
	
	
	// Release the old path and texture?
	if( path ) {
		[path release];
		path = nil;
		
		[texture release];
		texture = nil;
	}
	
	if( [newPath length] ) {
		path = [newPath retain];
		[self beginLoad];
	}
}

EJ_BIND_GET(width, ctx ) {
	return JSValueMakeNumber( ctx, texture ? (texture.width / texture.contentScale) : 0);
}

EJ_BIND_GET(height, ctx ) { 
	return JSValueMakeNumber( ctx, texture ? (texture.height / texture.contentScale) : 0 );
}

EJ_BIND_GET(complete, ctx ) {
	return JSValueMakeBoolean(ctx, (texture && texture.textureId) );
}

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);


@end
