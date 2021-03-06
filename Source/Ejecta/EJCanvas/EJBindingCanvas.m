#import "EJBindingCanvas.h"

#import "EJCanvasContext2DScreen.h"
#import "EJCanvasContext2DTexture.h"
#import "EJBindingCanvasContext2D.h"

#import "EJCanvasContextWebGLScreen.h"
#import "EJCanvasContextWebGLTexture.h"
#import "EJBindingCanvasContextWebGL.h"

#import "EJJavaScriptView.h"


@implementation EJBindingCanvas
@synthesize styleWidth, styleHeight;
@synthesize styleLeft, styleTop;

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];
	
	// If we don't have a screen canvas yet, make it this one
	if( !scriptView.hasScreenCanvas ) {
		isScreenCanvas = YES;
		scriptView.hasScreenCanvas = YES;
	}
	
	CGSize screen = scriptView.bounds.size;
	width = screen.width;
	height = screen.height;
	
	JSContextRef ctx = scriptView.jsGlobalContext;
	styleObject = [EJBindingCanvasStyle new];
	styleObject.binding = self;
	[EJBindingCanvasStyle createJSObjectWithContext:scriptView.jsGlobalContext scriptView:scriptView instance:styleObject];
	JSValueProtect(ctx, styleObject.jsObject);
}

- (void)dealloc {
	if( isScreenCanvas ) {
		scriptView.hasScreenCanvas = NO;
	}
	[renderingContext release];
	
	JSValueUnprotectSafe(scriptView.jsGlobalContext, styleObject.jsObject);
	styleObject.binding = nil;
	[styleObject release];
	
	[super dealloc];
}

- (EJTexture *)texture {
	if( [renderingContext respondsToSelector:@selector(texture)] ) {
		return (EJTexture *)[(id)renderingContext texture];
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

- (EJCanvasImageRendering)imageRendering {
	return imageRendering;
}

- (void)setImageRendering:(EJCanvasImageRendering)imageRenderingp {
	imageRendering = imageRenderingp;
	if( renderingContext && [renderingContext conformsToProtocol:@protocol(EJPresentable)] ) {
		CALayer *layer = ((NSObject<EJPresentable> *)renderingContext).view.layer;
		NSString *filter = imageRendering == kEJCanvasImageRenderingAuto
			? kCAFilterLinear
			: kCAFilterNearest;
		
		layer.magnificationFilter = filter;
		layer.minificationFilter = filter;
	}
}


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

EJ_BIND_FUNCTION(getContext, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; };
	
	NSString *type = JSValueToNSString(ctx, argv[0]);
	EJCanvasContextMode newContextMode = kEJCanvasContextModeInvalid;
	id contextClass, bindingClass;
	
	if( [type isEqualToString:@"2d"] ) {
		newContextMode = kEJCanvasContextMode2D;
		bindingClass = EJBindingCanvasContext2D.class;
		contextClass = isScreenCanvas
			? EJCanvasContext2DScreen.class
			: EJCanvasContext2DTexture.class;
	}
	else if( [type rangeOfString:@"webgl"].location != NSNotFound ) {
		newContextMode = kEJCanvasContextModeWebGL;
		bindingClass = EJBindingCanvasContextWebGL.class;
		contextClass = isScreenCanvas
			? EJCanvasContextWebGLScreen.class
			: EJCanvasContextWebGLTexture.class;
	}
	else {
		NSLog(@"Warning: Invalid argument %@ for getContext()", type);
		return NULL;
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
	
	contextMode = newContextMode;
	scriptView.currentRenderingContext = nil;
	
	// Configure and create the Canvas Context
	renderingContext = [[contextClass alloc] initWithScriptView:scriptView width:width height:height];
	
	// Parse the options object, if present.
	// E.g.: {antialias: true, antialiasSamples: 4, preserveDrawingBuffer: true}
	if( argc > 1 ) {
		NSObject *optionsObj = JSValueToNSObject(ctx, argv[1]);
		if( [optionsObj isKindOfClass:NSDictionary.class] ) {
			
			NSDictionary *options = (NSDictionary *)optionsObj;
			
			// Only override the default for preserveDrawingBuffer if this options is not undefined.
			// For Canvas2D this defaults to true, for WebGL it defaults to false.
			if( options[@"preserveDrawingBuffer"] ) {
				renderingContext.preserveDrawingBuffer = [options[@"preserveDrawingBuffer"] boolValue];
			}
			
			// If antialias is enabled, figure out the max samples this hardware supports and
			// clamp the antialiasSamples to it, if present. Otherwise default to 2 samples.
			if( [options[@"antialias"] boolValue] ) {
				int msaaSamples = (int)[options[@"antialiasSamples"] integerValue];
				int maxSamples = 2;
				glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamples);
			
				renderingContext.msaaEnabled = maxSamples > 1;
				renderingContext.msaaSamples = MAX(2, MIN(maxSamples, msaaSamples));
			}
           
			if ( !([options[@"alpha"] boolValue]) ) {
					renderingContext.alphaShouldLock = YES;
			}
		}
	}
	
	if( isScreenCanvas ) {
		scriptView.screenRenderingContext = (EJCanvasContext<EJPresentable> *)renderingContext;
		scriptView.screenRenderingContext.style = style;
	}
	
	[EAGLContext setCurrentContext:renderingContext.glContext];
	[renderingContext create];
	scriptView.currentRenderingContext = renderingContext;
	
	// Execute the imageRendering setter again, now that we have a full created
	// rendering context
	self.imageRendering = imageRendering;
	
	
	// Create the JS object
	EJBindingBase *binding = [[bindingClass alloc] initWithRenderingContext:(id)renderingContext];
	jsCanvasContext = [bindingClass createJSObjectWithContext:ctx scriptView:scriptView instance:binding];
	[binding release];
	
	// Attach the canvas to the context and the context to the canvas. We do this directly with the js object's
	// properties instead of using a JS_GET function, because we can't resolve the cyclic reference.
	JSStringRef canvasName = JSStringCreateWithUTF8CString("canvas");
 	JSObjectSetProperty(ctx, jsCanvasContext, canvasName, jsObject, kJSPropertyAttributeReadOnly, NULL);
 	JSStringRelease(canvasName);
	
	JSStringRef contextName = JSStringCreateWithUTF8CString("__currentContext");
	JSObjectSetProperty(ctx, jsObject, contextName, jsCanvasContext, kJSPropertyAttributeDontEnum, NULL);
	JSStringRelease(contextName);
	
	return jsCanvasContext;
}

- (JSValueRef)toDataURLWithCtx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( contextMode != kEJCanvasContextMode2D ) {
		NSLog(@"Error: toDataURL() not supported for this context");
		return NSStringToJSValue(ctx, @"data:,");
	}
	
	
	EJCanvasContext2D *context = (EJCanvasContext2D *)renderingContext;
	
	// Get the ImageData from the Canvas and generate the UIImage
	EJImageData *imageData = [context getImageDataSx:0 sy:0 sw:context.width sh:context.height];
	UIImage *image = [EJTexture imageWithPixels:imageData.pixels width:imageData.width height:imageData.height];
	
	NSString *prefix;
	NSData *raw;
	
	// JPEG?
	if( argc > 0 && [JSValueToNSString(ctx, argv[0]) isEqualToString:@"image/jpeg"] ) {
		float quality = (argc > 1)
			? JSValueToNumberFast(ctx, argv[1])
			: EJ_CANVAS_DEFAULT_JPEG_QUALITY;
		
		prefix = EJ_CANVAS_DATA_URL_PREFIX_JPEG;
		raw = UIImageJPEGRepresentation(image, quality);
	}
	// Default to PNG
	else {
		prefix = EJ_CANVAS_DATA_URL_PREFIX_PNG;
		raw = UIImagePNGRepresentation(image);
	}
	
	NSString *encoded = [prefix stringByAppendingString:[raw base64EncodedStringWithOptions:0]];
	return NSStringToJSValue(ctx, encoded);
}

EJ_BIND_FUNCTION(toDataURL, ctx, argc, argv) {
	return [self toDataURLWithCtx:ctx argc:argc argv:argv];
}

EJ_BIND_CONST(nodeName, "CANVAS");
EJ_BIND_CONST(tagName, "CANVAS");

@end
