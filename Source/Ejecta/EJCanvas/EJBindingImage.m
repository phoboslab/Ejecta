#import "EJBindingImage.h"
#import "EJJavaScriptView.h"
#import "EJNonRetainingProxy.h"
#import "EJTexture.h"

@implementation EJBindingImage
@synthesize texture;

- (void)beginLoad {
	// This will begin loading the texture in a background thread and will call the
	// JavaScript onload callback when done
	loading = YES;
	lazyload = NO;
	
	// Protect this image object from garbage collection, as its callback function
	// may be the only thing holding on to it
	JSValueProtect(scriptView.jsGlobalContext, jsObject);
	
	NSString *fullPath;

	// If path is a Data URI or remote URL we don't want to prepend resource paths
	if( [path hasPrefix:@"data:"] ) {
		NSLog(@"Loading Image from Data URI");
		fullPath = path;
	}
	else if( [path hasPrefix:@"http:"] || [path hasPrefix:@"https:"] ) {
		NSLog(@"Loading Image from URL: %@", path);
		fullPath = path;
	}
	else {
		// Only local assets are lazy-loaded
		NSLog(@"Will lazy-load image: %@", path);
		lazyload = YES;
	}
	
	// Use a non-retaining proxy for the callback operation and take care that the
	// loadCallback is always cancelled when dealloc'ing
	loadCallback = [[NSInvocationOperation alloc]
		initWithTarget:[EJNonRetainingProxy proxyWithTarget:self]
		selector:@selector(endLoad) object:nil];
	
	// When lazy loading, blindly execute the onload callback on the next frame.
	if( lazyload ) {
		[NSOperationQueue.mainQueue addOperation:loadCallback];
	}
	else {
		texture = [[EJTexture cachedTextureWithPath:fullPath
			loadOnQueue:scriptView.backgroundQueue callback:loadCallback] retain];
	}
}

- (EJTexture *)texture {
	if( lazyload && !texture ) {
	
		NSLog(@"Lazy-loaded image: %@", path);
		
		// Load texture blocking on main thread
		NSString* lazypath = [scriptView pathForResource:path];
		texture = [[EJTexture alloc] initWithPath:lazypath];
		
		sizeknown = YES;
		knownwidth = texture.width / texture.contentScale;
		knownheight = texture.height / texture.contentScale;
	}
	
	return texture;
}

- (void)releaseTexture {
	if( lazyload && texture ) {
		[texture release];
		texture = nil;
	}
}

- (void)prepareGarbageCollection {
	[loadCallback cancel];
	[loadCallback release];
	loadCallback = nil;
}

- (void)dealloc {
	[loadCallback cancel];
	[loadCallback release];
	
	[texture release];
	
	[path release];
	[super dealloc];
}

- (void)endLoad {
	loading = NO;
	[loadCallback release];
	loadCallback = nil;
	
	if( lazyload || texture.textureId ) {
		[self triggerEvent:@"load"];
	}
	else {
		[self triggerEvent:@"error"];
	}
	
	JSValueUnprotect(scriptView.jsGlobalContext, jsObject);
}

- (void)setTexture:(EJTexture *)texturep path:(NSString *)pathp {
	texture = [texturep retain];
	path = [pathp retain];
}

EJ_BIND_GET(src, ctx ) {
	return NSStringToJSValue(ctx, path);
}

EJ_BIND_SET(src, ctx, value) {
	// If the texture is still loading, do nothing to avoid confusion
	// This will break some edge cases; FIXME
	if( loading ) { return; }
	
	NSString *newPath = JSValueToNSString( ctx, value );
	
	// Same as the old path? Nothing to do here
	if( [path isEqualToString:newPath] ) { return; }
	
	
	// Release the old path and texture?
	if( path ) {
		[path release];
		path = nil;
	}
	
	if( texture ) {
		[texture release];
		texture = nil;
	}
	
	sizeknown = NO;
	
	if( !JSValueIsNull(ctx, value) && newPath.length ) {
		path = [newPath retain];
		[self beginLoad];
	}
}

EJ_BIND_GET(width, ctx ) {
	if( sizeknown ) {
		return JSValueMakeNumber( ctx, knownwidth );
	}
	else {
		return JSValueMakeNumber( ctx, self.texture.width / self.texture.contentScale );
	}
}

EJ_BIND_GET(height, ctx ) {
	if( sizeknown ) {
		return JSValueMakeNumber( ctx, knownheight );
	}
	else {
		return JSValueMakeNumber( ctx, self.texture.height / self.texture.contentScale );
	}
}

EJ_BIND_GET(complete, ctx ) {
	return JSValueMakeBoolean(ctx, (lazyload || (texture && texture.textureId)) );
}

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);

EJ_BIND_GET(nodeName, ctx ) {
	return NSStringToJSValue(ctx, @"IMG");
}

@end
