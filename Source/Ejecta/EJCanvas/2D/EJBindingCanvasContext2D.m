#import "EJBindingCanvasContext2D.h"

#import "EJCanvasContext2DTexture.h"
#import "EJCanvasContext2DScreen.h"
#import "EJBindingImageData.h"
#import "EJBindingCanvasPattern.h"

#import "EJDrawable.h"
#import "EJConvertColorRGBA.h"


@implementation EJBindingCanvasContext2D

- (id)initWithCanvas:(JSObjectRef)canvas renderingContext:(EJCanvasContext2D *)renderingContextp {
	if( self = [super initWithContext:NULL argc:0 argv:NULL] ) {
		ejectaInstance = [EJApp instance]; // Keep a local copy - may be faster?
		renderingContext = [renderingContextp retain];
		jsCanvas = canvas;
	}
	return self;
}

- (void)dealloc {	
	[renderingContext release];
	[super dealloc];
}

EJ_BIND_GET(canvas, ctx) {
	return jsCanvas;
}

EJ_BIND_ENUM(globalCompositeOperation, renderingContext.globalCompositeOperation,
	"source-over",		// kEJCompositeOperationSourceOver
	"lighter",			// kEJCompositeOperationLighter
	"darker",			// kEJCompositeOperationDarker
	"destination-out",	// kEJCompositeOperationDestinationOut
	"destination-over",	// kEJCompositeOperationDestinationOver
	"source-atop",		// kEJCompositeOperationSourceAtop
	"xor"				// kEJCompositeOperationXOR
);

EJ_BIND_ENUM(lineCap, renderingContext.state->lineCap,
	"butt",		// kEJLineCapButt
	"round",	// kEJLineCapRound
	"square"	// kEJLineCapSquare
);

EJ_BIND_ENUM(lineJoin, renderingContext.state->lineJoin,
	"miter",	// kEJLineJoinMiter
	"bevel",	// kEJLineJoinBevel
	"round"		// kEJLineJoinRound
);

EJ_BIND_ENUM(textAlign, renderingContext.state->textAlign,
	"start",	// kEJTextAlignStart
	"end",		// kEJTextAlignEnd
	"left",		// kEJTextAlignLeft
	"center",	// kEJTextAlignCenter
	"right"		// kEJTextAlignRight
);

EJ_BIND_ENUM(textBaseline, renderingContext.state->textBaseline,
	"alphabetic",	// kEJTextBaselineAlphabetic
	"middle",		// kEJTextBaselineMiddle
	"top",			// kEJTextBaselineTop
	"hanging",		// kEJTextBaselineHanging
	"bottom",		// kEJTextBaselineBottom
	"ideographic"	// kEJTextBaselineIdeographic
);

EJ_BIND_GET(fillStyle, ctx ) {
	if( renderingContext.fillPattern ) {
		return [EJBindingCanvasPattern createJSObjectWithContext:ctx pattern:renderingContext.fillPattern];
	}
	else {
		return ColorRGBAToJSValue(ctx, renderingContext.state->fillColor);
	}
}

EJ_BIND_SET(fillStyle, ctx, value) {
	if( JSValueIsObject(ctx, value) ) {
		renderingContext.fillPattern = [EJBindingCanvasPattern patternFromJSValue:value];
	}
	else {
		renderingContext.state->fillColor = JSValueToColorRGBA(ctx, value);
		renderingContext.fillPattern = NULL;
	}
}

EJ_BIND_GET(strokeStyle, ctx ) {
	return ColorRGBAToJSValue(ctx, renderingContext.state->strokeColor);
}

EJ_BIND_SET(strokeStyle, ctx, value) {
	renderingContext.state->strokeColor = JSValueToColorRGBA(ctx, value);
}

EJ_BIND_GET(globalAlpha, ctx ) {
	return JSValueMakeNumber(ctx, renderingContext.state->globalAlpha );
}

EJ_BIND_SET(globalAlpha, ctx, value) {
	renderingContext.state->globalAlpha = MIN(1,MAX(JSValueToNumberFast(ctx, value),0));
}

EJ_BIND_GET(lineWidth, ctx) {
	return JSValueMakeNumber(ctx, renderingContext.state->lineWidth);
}

EJ_BIND_SET(lineWidth, ctx, value) {
	renderingContext.state->lineWidth = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(miterLimit, ctx) {
	return JSValueMakeNumber(ctx, renderingContext.state->miterLimit);
}

EJ_BIND_SET(miterLimit, ctx, value) {
	renderingContext.state->miterLimit = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(font, ctx) {
	UIFont * font = renderingContext.state->font;
	NSString * name = [NSString stringWithFormat:@"%dpt %@", (int)font.pointSize, font.fontName];
	return NSStringToJSValue(ctx, name);
}

EJ_BIND_SET(font, ctx, value) {
	char string[64]; // Long font names are long
	JSStringRef jsString = JSValueToStringCopy( ctx, value, NULL );
	JSStringGetUTF8CString(jsString, string, 64);
	
	// Yeah, oldschool!
	float size = 0;
	char name[64];
	sscanf( string, "%fp%*[tx] %63s", &size, name); // matches: 10.5p[tx] helvetica
	UIFont * newFont = [UIFont fontWithName:[NSString stringWithUTF8String:name] size:size];
	
	if( newFont ) {
		renderingContext.font = newFont;
	}
	
	JSStringRelease(jsString);
}

EJ_BIND_SET(imageSmoothingEnabled, ctx, value) {
	ejectaInstance.currentRenderingContext = renderingContext;
	renderingContext.imageSmoothingEnabled = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(imageSmoothingEnabled, ctx) {
	return JSValueMakeBoolean(ctx, renderingContext.imageSmoothingEnabled);
}

EJ_BIND_GET(backingStorePixelRatio, ctx) {
	return JSValueMakeNumber(ctx, renderingContext.backingStoreRatio);
}

EJ_BIND_FUNCTION(save, ctx, argc, argv) {
	[renderingContext save];
	return NULL;
}

EJ_BIND_FUNCTION(restore, ctx, argc, argv) {
	[renderingContext restore];
	return NULL;
}

EJ_BIND_FUNCTION(rotate, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float angle);
	[renderingContext rotate:angle];
	return NULL;
}

EJ_BIND_FUNCTION(translate, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float x, float y);
	[renderingContext translateX:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION(scale, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float x, float y);
	[renderingContext scaleX:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION(transform, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float m11, float m12, float m21, float m22, float dx, float dy);
	[renderingContext transformM11:m11 m12:m12 m21:m21 m22:m22 dx:dx dy:dy];
	return NULL;
}

EJ_BIND_FUNCTION(setTransform, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float m11, float m12, float m21, float m22, float dx, float dy);
	[renderingContext setTransformM11:m11 m12:m12 m21:m21 m22:m22 dx:dx dy:dy];
	return NULL;
}

EJ_BIND_FUNCTION(drawImage, ctx, argc, argv) {
	if( argc < 3 || !JSValueIsObject(ctx, argv[0]) ) return NULL;
	
	NSObject<EJDrawable> * drawable = (NSObject<EJDrawable> *)JSObjectGetPrivate((JSObjectRef)argv[0]);
	EJTexture * image = drawable.texture;
	float scale = image.contentScale;
	
	short sx = 0, sy = 0, sw, sh;
	float dx, dy, dw, dh;
	
	if( argc == 3 ) {
		// drawImage(image, dx, dy)
		EJ_UNPACK_ARGV_OFFSET(1, dx, dy);
		sw = image.width;
		sh = image.height;
		dw = sw / scale;
		dh = sh / scale;
	}
	else if( argc == 5 ) {
		// drawImage(image, dx, dy, dw, dh)
		EJ_UNPACK_ARGV_OFFSET(1, dx, dy, dw, dh);
		sw = image.width;
		sh = image.height;
	}
	else if( argc >= 9 ) {
		// drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh)
		EJ_UNPACK_ARGV_OFFSET(1, sx, sy, sw, sh, dx, dy, dw, dh);
	}
	else {
		return NULL;
	}
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext drawImage:image sx:sx sy:sy sw:sw sh:sh dx:dx dy:dy dw:dw dh:dh];
	
	return NULL;
}

EJ_BIND_FUNCTION(fillRect, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float dx, float dy, float w, float h);
			
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext fillRectX:dx y:dy w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION(strokeRect, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float dx, float dy, float w, float h);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext strokeRectX:dx y:dy w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION(clearRect, ctx, argc, argv) {
	EJ_UNPACK_ARGV(float dx, float dy, float w, float h);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext clearRectX:dx y:dy w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION(getImageData, ctx, argc, argv) {
	EJ_UNPACK_ARGV(short sx, short sy, short sw, short sh);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	
	EJImageData * imageData = [renderingContext getImageDataSx:sx sy:sy sw:sw sh:sh];
	
	EJBindingImageData * binding = [[EJBindingImageData alloc] initWithImageData:imageData];
	return [EJBindingImageData createJSObjectWithContext:ctx instance:binding];
}

EJ_BIND_FUNCTION(createImageData, ctx, argc, argv) {
	EJ_UNPACK_ARGV(short sw, short sh);
		
	NSMutableData * pixels = [NSMutableData dataWithLength:sw * sh * 4];
	EJImageData * imageData = [[[EJImageData alloc] initWithWidth:sw height:sh pixels:pixels] autorelease];
	
	EJBindingImageData * binding = [[EJBindingImageData alloc] initWithImageData:imageData];
	return [EJBindingImageData createJSObjectWithContext:ctx instance:binding];
}

EJ_BIND_FUNCTION(putImageData, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	EJBindingImageData * jsImageData = (EJBindingImageData *)JSObjectGetPrivate((JSObjectRef)argv[0]);
	EJ_UNPACK_ARGV_OFFSET(1, float dx, float dy);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext putImageData:jsImageData.imageData dx:dx dy:dy];
	return NULL;
}

EJ_BIND_FUNCTION(createPattern, ctx, argc, argv) {
	if( argc < 1 ) { return NULL; }
	NSObject<EJDrawable> * drawable = (NSObject<EJDrawable> *)JSObjectGetPrivate((JSObjectRef)argv[0]);
	EJTexture * image = drawable.texture;
	
	if( !image ) { return NULL; }
	
	EJCanvasPatternRepeat repeat = kEJCanvasPatternRepeat;
	if( argc > 1 ) {
		NSString * repeatString = JSValueToNSString(ctx, argv[1]);
		if( [repeatString isEqualToString:@"repeat-x"] ) {
			repeat = kEJCanvasPatternRepeatX;
		}
		else if( [repeatString isEqualToString:@"repeat-y"] ) {
			repeat = kEJCanvasPatternRepeatY;
		}
		else if( [repeatString isEqualToString:@"no-repeat"] ) {
			repeat = kEJCanvasPatternNoRepeat;
		}
	}
	EJCanvasPattern * pattern = [[[EJCanvasPattern alloc] initWithTexture:image repeat:repeat] autorelease];
	return [EJBindingCanvasPattern createJSObjectWithContext:ctx pattern:pattern];
}

EJ_BIND_FUNCTION( beginPath, ctx, argc, argv ) {
	[renderingContext beginPath];
	return NULL;
}

EJ_BIND_FUNCTION( closePath, ctx, argc, argv ) {
	[renderingContext closePath];
	return NULL;
}

EJ_BIND_FUNCTION( fill, ctx, argc, argv ) {
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext fill];
	return NULL;
}

EJ_BIND_FUNCTION( stroke, ctx, argc, argv ) {
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext stroke];
	return NULL;
}

EJ_BIND_FUNCTION( moveTo, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float x, float y);
	[renderingContext moveToX:x y:y];
	
	return NULL;
}

EJ_BIND_FUNCTION( lineTo, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float x, float y);
	[renderingContext lineToX:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( rect, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float x, float y, float w, float h);
	[renderingContext rectX:x y:y w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION( bezierCurveTo, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float cpx1, float cpy1, float cpx2, float cpy2, float x, float y);
	[renderingContext bezierCurveToCpx1:cpx1 cpy1:cpy1 cpx2:cpx2 cpy2:cpy2 x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( quadraticCurveTo, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float cpx, float cpy, float x, float y);
	[renderingContext quadraticCurveToCpx:cpx cpy:cpy x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( arcTo, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float x1, float y1, float x2, float y2, float radius);
	[renderingContext arcToX1:x1 y1:y1 x2:x2 y2:y2 radius:radius];
	return NULL;
}

EJ_BIND_FUNCTION( arc, ctx, argc, argv ) {
	EJ_UNPACK_ARGV(float x, float y, float radius, float startAngle, float endAngle, BOOL antiClockwise);
	[renderingContext arcX:x y:y radius:radius startAngle:startAngle endAngle:endAngle antiClockwise:antiClockwise];
	return NULL;
}

EJ_BIND_FUNCTION( measureText, ctx, argc, argv ) {
	if( argc < 1 ) { return NULL; }
	
	NSString * string = JSValueToNSString(ctx, argv[0]);
	float stringWidth = [renderingContext measureText:string];
	
	JSObjectRef objRef = JSObjectMake(ctx, NULL, NULL);
	JSStringRef stringRef = JSStringCreateWithUTF8CString("width");
	JSObjectSetProperty(ctx, objRef, stringRef, JSValueMakeNumber(ctx, stringWidth), kJSPropertyAttributeNone, nil);
	JSStringRelease(stringRef);
	
	return objRef;
}

EJ_BIND_FUNCTION( fillText, ctx, argc, argv ) {
	if( argc < 3 ) { return NULL; }
	
	NSString * string = JSValueToNSString(ctx, argv[0]);
	EJ_UNPACK_ARGV_OFFSET(1, float x, float y);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext fillText:string x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( strokeText, ctx, argc, argv ) {
	if( argc < 3 ) { return NULL; }
	
	NSString * string = JSValueToNSString(ctx, argv[0]);
	EJ_UNPACK_ARGV_OFFSET(1, float x, float y);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext strokeText:string x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( clip, ctx, argc, argv ) {
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext clip];
	return NULL;
}

EJ_BIND_FUNCTION( resetClip, ctx, argc, argv ) {
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext resetClip];
	return NULL;
}

EJ_BIND_FUNCTION_NOT_IMPLEMENTED( createRadialGradient );
EJ_BIND_FUNCTION_NOT_IMPLEMENTED( createLinearGradient );
EJ_BIND_FUNCTION_NOT_IMPLEMENTED( isPointInPath );

@end
