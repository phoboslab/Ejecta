#import "EJBindingCanvasContext2D.h"

#import "EJCanvasContext2DTexture.h"
#import "EJCanvasContext2DScreen.h"
#import "EJBindingImageData.h"

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

EJ_BIND_ENUM(globalCompositeOperation, renderingContext.globalCompositeOperation, EJ_ENUM_NAMES(
	[kEJCompositeOperationSourceOver] = "source-over",
	[kEJCompositeOperationLighter] = "lighter",
	[kEJCompositeOperationDarker] = "darker",
	[kEJCompositeOperationDestinationOut] = "destination-out",
	[kEJCompositeOperationDestinationOver] = "destination-over",
	[kEJCompositeOperationSourceAtop] = "source-atop",
	[kEJCompositeOperationXOR] = "xor"
));

EJ_BIND_ENUM(lineCap, renderingContext.state->lineCap, EJ_ENUM_NAMES(
	[kEJLineCapButt] = "butt",
	[kEJLineCapRound] = "round",
	[kEJLineCapSquare] = "square"
));

EJ_BIND_ENUM(lineJoin, renderingContext.state->lineJoin, EJ_ENUM_NAMES(
	[kEJLineJoinMiter] = "miter",
	[kEJLineJoinBevel] = "bevel",
	[kEJLineJoinRound] = "round"
));

EJ_BIND_ENUM(textAlign, renderingContext.state->textAlign, EJ_ENUM_NAMES(
	[kEJTextAlignStart] = "start",
	[kEJTextAlignEnd] = "end",
	[kEJTextAlignLeft] = "left",
	[kEJTextAlignCenter] = "center",
	[kEJTextAlignRight] = "right"
));

EJ_BIND_ENUM(textBaseline, renderingContext.state->textBaseline, EJ_ENUM_NAMES(
	[kEJTextBaselineAlphabetic] = "alphabetic",
	[kEJTextBaselineMiddle] = "middle",
	[kEJTextBaselineTop] = "top",
	[kEJTextBaselineHanging] = "hanging",
	[kEJTextBaselineBottom] = "bottom",
	[kEJTextBaselineIdeographic] = "ideographic"
));

EJ_BIND_GET(fillStyle, ctx ) {
	return ColorRGBAToJSValue(ctx, renderingContext.state->fillColor);
}

EJ_BIND_SET(fillStyle, ctx, value) {
	renderingContext.state->fillColor = JSValueToColorRGBA(ctx, value);
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
	if( argc < 1 ) { return NULL; }
	[renderingContext rotate:JSValueToNumberFast(ctx, argv[0])];
	return NULL;
}

EJ_BIND_FUNCTION(translate, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	[renderingContext translateX:JSValueToNumberFast(ctx, argv[0]) y:JSValueToNumberFast(ctx, argv[1])];
	return NULL;
}

EJ_BIND_FUNCTION(scale, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	[renderingContext scaleX:JSValueToNumberFast(ctx, argv[0]) y:JSValueToNumberFast(ctx, argv[1])];
	return NULL;
}

EJ_BIND_FUNCTION(transform, ctx, argc, argv) {
	if( argc < 6 ) { return NULL; }
	
	float
		m11 = JSValueToNumberFast(ctx, argv[0]),
		m12 = JSValueToNumberFast(ctx, argv[1]),
		m21 = JSValueToNumberFast(ctx, argv[2]),
		m22 = JSValueToNumberFast(ctx, argv[3]),
		dx = JSValueToNumberFast(ctx, argv[4]),
		dy = JSValueToNumberFast(ctx, argv[5]);
	[renderingContext transformM11:m11 m12:m12 m21:m21 m22:m22 dx:dx dy:dy];
	return NULL;
}

EJ_BIND_FUNCTION(setTransform, ctx, argc, argv) {
	if( argc < 6 ) { return NULL; }
	
	float
		m11 = JSValueToNumberFast(ctx, argv[0]),
		m12 = JSValueToNumberFast(ctx, argv[1]),
		m21 = JSValueToNumberFast(ctx, argv[2]),
		m22 = JSValueToNumberFast(ctx, argv[3]),
		dx = JSValueToNumberFast(ctx, argv[4]),
		dy = JSValueToNumberFast(ctx, argv[5]);
	[renderingContext setTransformM11:m11 m12:m12 m21:m21 m22:m22 dx:dx dy:dy];
	return NULL;
}

EJ_BIND_FUNCTION(drawImage, ctx, argc, argv) {
	if( argc < 3 || !JSValueIsObject(ctx, argv[0]) ) return NULL;
	
	NSObject<EJDrawable> * drawable = (NSObject<EJDrawable> *)JSObjectGetPrivate((JSObjectRef)argv[0]);
	EJTexture * image = drawable.texture;
	float scale = image.contentScale;
	
	short sx = 0, sy = 0, sw = 0, sh = 0;
	float dx = 0, dy = 0, dw = sw, dh = sh;	
	
	if( argc == 3 ) {
		// drawImage(image, dx, dy)
		dx = JSValueToNumberFast(ctx, argv[1]);
		dy = JSValueToNumberFast(ctx, argv[2]);
		sw = image.width;
		sh = image.height;
		dw = sw / scale;
		dh = sh / scale;
	}
	else if( argc == 5 ) {
		// drawImage(image, dx, dy, dw, dh)
		dx = JSValueToNumberFast(ctx, argv[1]);
		dy = JSValueToNumberFast(ctx, argv[2]);
		dw = JSValueToNumberFast(ctx, argv[3]);
		dh = JSValueToNumberFast(ctx, argv[4]);
		sw = image.width;
		sh = image.height;
	}
	else if( argc >= 9 ) {
		// drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh)
		sx = JSValueToNumberFast(ctx, argv[1]) * scale;
		sy = JSValueToNumberFast(ctx, argv[2]) * scale;
		sw = JSValueToNumberFast(ctx, argv[3]) * scale;
		sh = JSValueToNumberFast(ctx, argv[4]) * scale;
		
		dx = JSValueToNumberFast(ctx, argv[5]);
		dy = JSValueToNumberFast(ctx, argv[6]);
		dw = JSValueToNumberFast(ctx, argv[7]);
		dh = JSValueToNumberFast(ctx, argv[8]);
	}
	else {
		return NULL;
	}
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext drawImage:image sx:sx sy:sy sw:sw sh:sh dx:dx dy:dy dw:dw dh:dh];
	
	return NULL;
}

EJ_BIND_FUNCTION(fillRect, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	float
		dx = JSValueToNumberFast(ctx, argv[0]),
		dy = JSValueToNumberFast(ctx, argv[1]),
		w = JSValueToNumberFast(ctx, argv[2]),
		h = JSValueToNumberFast(ctx, argv[3]);
		
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext fillRectX:dx y:dy w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION(strokeRect, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	float
		dx = JSValueToNumberFast(ctx, argv[0]),
		dy = JSValueToNumberFast(ctx, argv[1]),
		w = JSValueToNumberFast(ctx, argv[2]),
		h = JSValueToNumberFast(ctx, argv[3]);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext strokeRectX:dx y:dy w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION(clearRect, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	float
		dx = JSValueToNumberFast(ctx, argv[0]),
		dy = JSValueToNumberFast(ctx, argv[1]),
		w = JSValueToNumberFast(ctx, argv[2]),
		h = JSValueToNumberFast(ctx, argv[3]);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext clearRectX:dx y:dy w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION(getImageData, ctx, argc, argv) {
	if( argc < 4 ) { return NULL; }
	
	float
		sx = JSValueToNumberFast(ctx, argv[0]),
		sy = JSValueToNumberFast(ctx, argv[1]),
		sw = JSValueToNumberFast(ctx, argv[2]),
		sh = JSValueToNumberFast(ctx, argv[3]);
	
	// Get the image data
	ejectaInstance.currentRenderingContext = renderingContext;
	EJImageData * imageData = [renderingContext getImageDataSx:sx sy:sy sw:sw sh:sh];
	
	EJBindingImageData * binding = [[EJBindingImageData alloc] initWithImageData:imageData];
	return [EJBindingImageData createJSObjectWithContext:ctx instance:binding];
}

EJ_BIND_FUNCTION(createImageData, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	float
		sw = JSValueToNumberFast(ctx, argv[0]),
		sh = JSValueToNumberFast(ctx, argv[1]);
		
	GLubyte * pixels = calloc( sw * sh * 4, sizeof(GLubyte) );
	EJImageData * imageData = [[[EJImageData alloc] initWithWidth:sw height:sh pixels:pixels] autorelease];
	
	EJBindingImageData * binding = [[EJBindingImageData alloc] initWithImageData:imageData];
	return [EJBindingImageData createJSObjectWithContext:ctx instance:binding];
}

EJ_BIND_FUNCTION(putImageData, ctx, argc, argv) {
	if( argc < 3 ) { return NULL; }
	
	EJBindingImageData * jsImageData = (EJBindingImageData *)JSObjectGetPrivate((JSObjectRef)argv[0]);
	float
		dx = JSValueToNumberFast(ctx, argv[1]),
		dy = JSValueToNumberFast(ctx, argv[2]);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext putImageData:jsImageData.imageData dx:dx dy:dy];
	return NULL;
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
	if( argc < 2 ) { return NULL; }
	
	float
		x = JSValueToNumberFast(ctx, argv[0]),
		y = JSValueToNumberFast(ctx, argv[1]);
	[renderingContext moveToX:x y:y];
	
	return NULL;
}

EJ_BIND_FUNCTION( lineTo, ctx, argc, argv ) {
	if( argc < 2 ) { return NULL; }
	
	float
		x = JSValueToNumberFast(ctx, argv[0]),
		y = JSValueToNumberFast(ctx, argv[1]);
	[renderingContext lineToX:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( rect, ctx, argc, argv ) {
	if( argc < 4 ) { return NULL; }
	
	float
		x = JSValueToNumberFast(ctx, argv[0]),
		y = JSValueToNumberFast(ctx, argv[1]),
		w = JSValueToNumberFast(ctx, argv[2]),
		h = JSValueToNumberFast(ctx, argv[3]);
	[renderingContext rectX:x y:y w:w h:h];
	return NULL;
}

EJ_BIND_FUNCTION( bezierCurveTo, ctx, argc, argv ) {
	if( argc < 6 ) { return NULL; }
	
	float
		cpx1 = JSValueToNumberFast(ctx, argv[0]),
		cpy1 = JSValueToNumberFast(ctx, argv[1]),
		cpx2 = JSValueToNumberFast(ctx, argv[2]),
		cpy2 = JSValueToNumberFast(ctx, argv[3]),
		x = JSValueToNumberFast(ctx, argv[4]),
		y = JSValueToNumberFast(ctx, argv[5]);
	[renderingContext bezierCurveToCpx1:cpx1 cpy1:cpy1 cpx2:cpx2 cpy2:cpy2 x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( quadraticCurveTo, ctx, argc, argv ) {
	if( argc < 4 ) { return NULL; }
	
	float
		cpx = JSValueToNumberFast(ctx, argv[0]),
		cpy = JSValueToNumberFast(ctx, argv[1]),
		x = JSValueToNumberFast(ctx, argv[2]),
		y = JSValueToNumberFast(ctx, argv[3]);
	[renderingContext quadraticCurveToCpx:cpx cpy:cpy x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( arcTo, ctx, argc, argv ) {
	if( argc < 5 ) { return NULL; }
	
	float
		x1 = JSValueToNumberFast(ctx, argv[0]),
		y1 = JSValueToNumberFast(ctx, argv[1]),
		x2 = JSValueToNumberFast(ctx, argv[2]),
		y2 = JSValueToNumberFast(ctx, argv[3]),
		radius = JSValueToNumberFast(ctx, argv[4]);
	[renderingContext arcToX1:x1 y1:y1 x2:x2 y2:y2 radius:radius];
	return NULL;
}

EJ_BIND_FUNCTION( arc, ctx, argc, argv ) {
	if( argc < 5 ) { return NULL; }
	
	float
		x = JSValueToNumberFast(ctx, argv[0]),
		y = JSValueToNumberFast(ctx, argv[1]),
		radius = JSValueToNumberFast(ctx, argv[2]),
		startAngle = JSValueToNumberFast(ctx, argv[3]),
		endAngle = JSValueToNumberFast(ctx, argv[4]);
	BOOL antiClockwise = argc < 6 ? false : JSValueToBoolean(ctx, argv[5]);
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
	float
		x = JSValueToNumberFast(ctx, argv[1]),
		y = JSValueToNumberFast(ctx, argv[2]);
	
	ejectaInstance.currentRenderingContext = renderingContext;
	[renderingContext fillText:string x:x y:y];
	return NULL;
}

EJ_BIND_FUNCTION( strokeText, ctx, argc, argv ) {
	if( argc < 3 ) { return NULL; }
	
	NSString * string = JSValueToNSString(ctx, argv[0]);
	float
		x = JSValueToNumberFast(ctx, argv[1]),
		y = JSValueToNumberFast(ctx, argv[2]);
	
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
EJ_BIND_FUNCTION_NOT_IMPLEMENTED( createPattern );
EJ_BIND_FUNCTION_NOT_IMPLEMENTED( isPointInPath );

@end
