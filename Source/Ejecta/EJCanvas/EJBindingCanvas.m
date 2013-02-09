#import "EJBindingCanvas.h"

#import "EJCanvasContext2DScreen.h"
#import "EJCanvasContext2DTexture.h"
#import "EJBindingCanvasContext2D.h"

#import "EJCanvasContextWebGL.h"
#import "EJBindingCanvasContextWebGL.h"

#import "EJJavaScriptView.h"

@implementation EJBindingCanvas

static BOOL HasScreenCanvas = NO;

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	
	if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
				
		scalingMode = kEJScalingModeFitWidth;
		useRetinaResolution = true;
		msaaEnabled = false;
		msaaSamples = 2;
		
		// If we don't have a screen canvas yet, make it this one
		if( !HasScreenCanvas ) {
			isScreenCanvas = YES;
			HasScreenCanvas = YES;
		}
		
		if( argc == 2 ) {
			width = JSValueToNumberFast(ctx, argv[0]);
			height = JSValueToNumberFast(ctx, argv[1]);
		}
		else {
			CGSize screen = [EJJavaScriptView sharedView].bounds.size;
			width = screen.width;
			height = screen.height;
		}
	}
	return self;
}

- (void)dealloc {
	if( isScreenCanvas ) {
		HasScreenCanvas	= NO;
	}
	[renderingContext release];
	if( jsCanvasContext ) {
		JSValueUnprotect([EJJavaScriptView sharedView].jsGlobalContext, jsCanvasContext);
	}
	[super dealloc];
}

- (EJTexture *)texture {
	if( [renderingContext isKindOfClass:[EJCanvasContext2DTexture class]] ) {
		return ((EJCanvasContext2DTexture *)renderingContext).texture;
	}
	else {
		return nil;
	}
}

EJ_BIND_ENUM(scalingMode, scalingMode,
	"none",			// kEJScalingModeNone
	"fit-width",	// kEJScalingModeFitWidth
	"fit-height"	// FitHeight
);

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_SET(width, ctx, value) {
	short newWidth = JSValueToNumberFast(ctx, value);
	if( renderingContext ) {
		[EJJavaScriptView sharedView].currentRenderingContext = renderingContext;
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
		[EJJavaScriptView sharedView].currentRenderingContext = renderingContext;
		renderingContext.height = newHeight;
		height = renderingContext.height;
	}
	else {
		height = newHeight;
	}
}

EJ_BIND_GET(offsetLeft, ctx) {
	return JSValueMakeNumber(ctx, 0);
}

EJ_BIND_GET(offsetTop, ctx) {
	return JSValueMakeNumber(ctx, 0);
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
	[EJJavaScriptView sharedView].currentRenderingContext = nil;
	
	if( newContextMode == kEJCanvasContextMode2D ) {
		if( isScreenCanvas ) {
			EJCanvasContext2DScreen *sc = [[EJCanvasContext2DScreen alloc] initWithWidth:width height:height];
			sc.useRetinaResolution = useRetinaResolution;
			sc.scalingMode = scalingMode;
			
			[EJJavaScriptView sharedView].screenRenderingContext = sc;
			renderingContext = sc;
		}
		else {
			EJCanvasContext2DTexture *tc = [[EJCanvasContext2DTexture alloc] initWithWidth:width height:height];
			tc.useRetinaResolution = useRetinaResolution;
			
			renderingContext = tc;
		}
		
		// Create the JS object
		EJBindingCanvasContext2D *binding = [[EJBindingCanvasContext2D alloc]
			initWithCanvas:jsObject renderingContext:(EJCanvasContext2D *)renderingContext];
		jsCanvasContext = [EJBindingCanvasContext2D createJSObjectWithContext:ctx instance:binding];
		JSValueProtect(ctx, jsCanvasContext);
	}
	
	else if( newContextMode == kEJCanvasContextModeWebGL ) {
		EJCanvasContextWebGL *sc = [[EJCanvasContextWebGL alloc] initWithWidth:width height:height];
		sc.useRetinaResolution = useRetinaResolution;
		sc.scalingMode = scalingMode;
		
		[EJJavaScriptView sharedView].screenRenderingContext = sc;
		renderingContext = sc;
		
		// Create the JS object
		EJBindingCanvasContextWebGL *binding = [[EJBindingCanvasContextWebGL alloc]
			initWithCanvas:jsObject renderingContext:(EJCanvasContextWebGL *)renderingContext];
		jsCanvasContext = [EJBindingCanvasContextWebGL createJSObjectWithContext:ctx instance:binding];
		JSValueProtect(ctx, jsCanvasContext);
	}
	
	
	contextMode = newContextMode;
	
	renderingContext.msaaEnabled = msaaEnabled;
	renderingContext.msaaSamples = msaaSamples;
	
	[EAGLContext setCurrentContext:renderingContext.glContext];
	[renderingContext create];
	[EJJavaScriptView sharedView].currentRenderingContext = renderingContext;
	
	
	return jsCanvasContext;
}

@end
