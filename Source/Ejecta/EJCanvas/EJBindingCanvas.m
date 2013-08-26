#import "EJBindingCanvas.h"

#import "EJCanvasContext2DScreen.h"
#import "EJCanvasContext2DTexture.h"
#import "EJBindingCanvasContext2D.h"

#import "EJCanvasContextWebGL.h"
#import "EJBindingCanvasContextWebGL.h"

#import "EJJavaScriptView.h"
#import "base64.h"


@implementation EJBindingCanvas
@synthesize styleWidth, styleHeight;
@synthesize styleLeft, styleTop;

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	
	useRetinaResolution = true;
	msaaEnabled = false;
	msaaSamples = 2;
	
	// If we don't have a screen canvas yet, make it this one
	if( !scriptView.hasScreenCanvas ) {
		isScreenCanvas = YES;
		scriptView.hasScreenCanvas = YES;
	}
	
	CGSize screen = scriptView.bounds.size;
	width = screen.width;
	height = screen.height;
	
	JSContextRef ctx = scriptView.jsGlobalContext;
	styleObject = [[EJBindingCanvasStyle alloc] init];
	styleObject.binding = self;
	[EJBindingCanvasStyle createJSObjectWithContext:scriptView.jsGlobalContext scriptView:scriptView instance:styleObject];
	JSValueProtect(ctx, styleObject.jsObject);
}

- (void)dealloc {
	if( isScreenCanvas ) {
		scriptView.hasScreenCanvas = NO;
	}
	[renderingContext release];
	JSValueUnprotectSafe(scriptView.jsGlobalContext, jsCanvasContext);
	
	JSValueUnprotectSafe(scriptView.jsGlobalContext, styleObject.jsObject);
	styleObject.binding = nil;
	[styleObject release];
	
	[super dealloc];
}

- (EJTexture *)texture {
	if( [renderingContext respondsToSelector:@selector(texture)] ) {
		return [(id)renderingContext texture];
	}
	else {
		return nil;
	}
}

#define EJ_GET_SET_STYLE(GETTER, SETTER, TARGET) \
	- (float)GETTER { return TARGET; } \
	- (void)SETTER:(float)value { \
		TARGET = value; \
		if( renderingContext && [renderingContext conformsToProtocol:@protocol(EJPresentable)] ) { \
			scriptView.currentRenderingContext = renderingContext; \
			((NSObject<EJPresentable> *)renderingContext).style = style; \
		} \
	} \
	
	EJ_GET_SET_STYLE(styleWidth, setStyleWidth, style.size.width);
	EJ_GET_SET_STYLE(styleHeight, setStyleHeight, style.size.height);
	EJ_GET_SET_STYLE(styleLeft, setStyleLeft, style.origin.x);
	EJ_GET_SET_STYLE(styleTop, setStyleTop, style.origin.y);

#undef EJ_GET_SET_STYLE


EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_SET(width, ctx, value) {
	short newWidth = JSValueToNumberFast(ctx, value);
	if( renderingContext ) {
		scriptView.currentRenderingContext = renderingContext;
		renderingContext.width = newWidth;
		width = renderingContext.width;
		return;
	}
	else {
		width = newWidth;
	}
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, height);
}

EJ_BIND_SET(height, ctx, value) {
	short newHeight = JSValueToNumberFast(ctx, value);
	if( renderingContext ) {
		scriptView.currentRenderingContext = renderingContext;
		renderingContext.height = newHeight;
		height = renderingContext.height;
	}
	else {
		height = newHeight;
	}
}

EJ_BIND_GET(style, ctx) {
	return styleObject.jsObject;
}

EJ_BIND_GET(offsetLeft, ctx) {
	return JSValueMakeNumber(ctx, style.origin.x);
}

EJ_BIND_GET(offsetTop, ctx) {
	return JSValueMakeNumber(ctx, style.origin.y);
}

EJ_BIND_GET(offsetWidth, ctx) {
	return JSValueMakeNumber(ctx, style.size.width ? style.size.width : width);
}

EJ_BIND_GET(offsetHeight, ctx) {
	return JSValueMakeNumber(ctx, style.size.height ? style.size.height : height);
}

EJ_BIND_SET(retinaResolutionEnabled, ctx, value) {
	useRetinaResolution = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(retinaResolutionEnabled, ctx) {
	return JSValueMakeBoolean(ctx, useRetinaResolution);
}

EJ_BIND_SET(MSAAEnabled, ctx, value) {
	msaaEnabled = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(MSAAEnabled, ctx) {
	return JSValueMakeBoolean(ctx, msaaEnabled);
}

EJ_BIND_SET(MSAASamples, ctx, value) {
	int samples = JSValueToNumberFast(ctx, value);
	if( samples == 2 || samples == 4 ) {
		msaaSamples	= samples;
	}
}

EJ_BIND_GET(MSAASamples, ctx) {
	return JSValueMakeNumber(ctx, msaaSamples);
}

EJ_BIND_FUNCTION(getContext, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; };
	
	NSString *type = JSValueToNSString(ctx, argv[0]);
	EJCanvasContextMode newContextMode = kEJCanvasContextModeInvalid;
	
	if( [type isEqualToString:@"2d"] ) {
		newContextMode = kEJCanvasContextMode2D;
	}
	else if( [type rangeOfString:@"webgl"].location != NSNotFound ) {
		newContextMode = kEJCanvasContextModeWebGL;
	}
	
	
	if( contextMode != kEJCanvasContextModeInvalid ) {
	
		// Nothing changed? - just return the already created context
		if( contextMode == newContextMode ) {
			return jsCanvasContext;
		}
		
		// New mode is different from current? - we can't do that
		else {
			NSLog(@"Warning: CanvasContext already created. Can't change 2d/webgl mode.");
			return NULL;
		}
	}
	
	
	
	// Create the requested CanvasContext
	scriptView.currentRenderingContext = nil;
	
	if( newContextMode == kEJCanvasContextMode2D ) {
		if( isScreenCanvas ) {
			EJCanvasContext2DScreen *sc = [[EJCanvasContext2DScreen alloc]
				initWithScriptView:scriptView width:width height:height style:style];
			sc.useRetinaResolution = useRetinaResolution;
			
			scriptView.screenRenderingContext = sc;
			renderingContext = sc;
		}
		else {
			EJCanvasContext2DTexture *tc = [[EJCanvasContext2DTexture alloc]
				initWithScriptView:scriptView width:width height:height];
			tc.useRetinaResolution = useRetinaResolution;
			
			renderingContext = tc;
		}
		
		// Create the JS object
		EJBindingCanvasContext2D *binding = [[EJBindingCanvasContext2D alloc]
			initWithCanvas:jsObject renderingContext:(EJCanvasContext2D *)renderingContext];
		jsCanvasContext = [EJBindingCanvasContext2D createJSObjectWithContext:ctx scriptView:scriptView instance:binding];
		[binding release];
		JSValueProtect(ctx, jsCanvasContext);
	}
	
	else if( newContextMode == kEJCanvasContextModeWebGL ) {
		EJCanvasContextWebGL *sc = [[EJCanvasContextWebGL alloc]
			initWithScriptView:scriptView width:width height:height style:style];
		sc.useRetinaResolution = useRetinaResolution;
		
		scriptView.screenRenderingContext = sc;
		renderingContext = sc;
		
		// Create the JS object
		EJBindingCanvasContextWebGL *binding = [[EJBindingCanvasContextWebGL alloc]
			initWithCanvas:jsObject renderingContext:(EJCanvasContextWebGL *)renderingContext];
		jsCanvasContext = [EJBindingCanvasContextWebGL createJSObjectWithContext:ctx scriptView:scriptView instance:binding];
		[binding release];
		JSValueProtect(ctx, jsCanvasContext);
	}
	
	
	contextMode = newContextMode;
	
	renderingContext.msaaEnabled = msaaEnabled;
	renderingContext.msaaSamples = msaaSamples;
	
	[EAGLContext setCurrentContext:renderingContext.glContext];
	[renderingContext create];
	scriptView.currentRenderingContext = renderingContext;
	
	
	return jsCanvasContext;
}

- (JSValueRef)toDataURLWithCtx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv hd:(BOOL)hd {
	if( contextMode != kEJCanvasContextMode2D ) {
		NSLog(@"Error: toDataURL() not supported for this context");
		return NSStringToJSValue(ctx, @"data:,");
	}
	
	
	EJCanvasContext2D *context = (EJCanvasContext2D *)renderingContext;
	
	// Get the ImageData from the Canvas
	float scale = hd ? context.backingStoreRatio : 1;
	float w = context.width * context.backingStoreRatio;
	float h = context.height * context.backingStoreRatio;
	
	EJImageData *imageData = (scale != 1)
		? [context getImageDataHDSx:0 sy:0 sw:w sh:h]
		: [context getImageDataSx:0 sy:0 sw:w sh:h];
			
	
	// Generate the UIImage
	UIImage *image = [EJTexture imageWithPixels:imageData.pixels width:imageData.width height:imageData.height scale:scale];
	
	char *prefix;
	int prefixLength;
	NSData *raw;
	
	// JPEG?
	if( argc > 0 && [JSValueToNSString(ctx, argv[0]) isEqualToString:@"image/jpeg"] ) {
		float quality = (argc > 1)
			? JSValueToNumberFast(ctx, argv[1])
			: EJ_CANVAS_DEFAULT_JPEG_QUALITY;
		
		prefix = EJ_CANVAS_DATA_URL_PREFIX_JPEG;
		prefixLength = sizeof(EJ_CANVAS_DATA_URL_PREFIX_JPEG)-1;
		raw = UIImageJPEGRepresentation(image, quality);
	}
	// Default to PNG
	else {
		prefix = EJ_CANVAS_DATA_URL_PREFIX_PNG;
		prefixLength = sizeof(EJ_CANVAS_DATA_URL_PREFIX_PNG)-1;
		raw = UIImagePNGRepresentation(image);
	}
	
	
	// There's a lot of heavy data lifting going on here: getting the pixel data from the canvas,
	// converting to a UIImage, converting to JPG or PNG representation and converting to Base64.
	
	// autorelease bytes our ass here, causing all the data to be only released at the end of the
	// frame. So we try to be at least conservative with the final Base64 encoded string: it's
	// created with the right prefix and the encoder writes directly into it.
	
	
	// Allocate the buffer for the encoded data + prefix
	NSMutableData *encoded = [NSMutableData dataWithLength:((raw.length * 3 + 2) / 2) + prefixLength];
	
	// Copy the prefix into the final url string
	memcpy(encoded.mutableBytes, prefix, prefixLength);
	
	// Write base64 encoded data into the url string; start after the prefix
	int len = b64_ntop(raw.bytes, raw.length, (encoded.mutableBytes + prefixLength), encoded.length - prefixLength);
	
	if( len <= 0 ) {
		return nil;
	}
	
	JSStringRef jsDataURL = JSStringCreateWithUTF8CString(encoded.bytes);
	JSValueRef ret = JSValueMakeString(ctx, jsDataURL);
	JSStringRelease(jsDataURL);
	return ret;
}

EJ_BIND_FUNCTION(toDataURL, ctx, argc, argv) {
	return [self toDataURLWithCtx:ctx argc:argc argv:argv hd:NO];
}

EJ_BIND_FUNCTION(toDataURLHD, ctx, argc, argv) {
	return [self toDataURLWithCtx:ctx argc:argc argv:argv hd:YES];
}

@end
