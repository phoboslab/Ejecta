#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContextTexture.h"
#import "EJCanvasContextScreen.h"
#import "EJTexture.h"
#import "EJDrawable.h"

static const char * EJLineCapNames[] = {
	[kEJLineCapButt] = "butt",
	[kEJLineCapRound] = "round",
	[kEJLineCapSquare] = "square"
};

static const char * EJLineJoinNames[] = {
	[kEJLineJoinMiter] = "miter",
	[kEJLineJoinBevel] = "bevel",
	[kEJLineJoinRound] = "round"
};

static const char * EJTextBaselineNames[] = {
	[kEJTextBaselineAlphabetic] = "alphabetic",
	[kEJTextBaselineMiddle] = "middle",
	[kEJTextBaselineTop] = "top",
	[kEJTextBaselineHanging] = "hanging",
	[kEJTextBaselineBottom] = "bottom",
	[kEJTextBaselineIdeographic] = "ideographic"
};

static const char * EJTextAlignNames[] = {
	[kEJTextAlignStart] = "start",
	[kEJTextAlignEnd] = "end",
	[kEJTextAlignLeft] = "left",
	[kEJTextAlignCenter] = "center",
	[kEJTextAlignRight] = "right"
};

static const char * EJCompositeOperationNames[] = {
	[kEJCompositeOperationSourceOver] = "source-over",
	[kEJCompositeOperationLighter] = "lighter",
	[kEJCompositeOperationDarker] = "darker",
	[kEJCompositeOperationDestinationOut] = "destination-out",
	[kEJCompositeOperationDestinationOver] = "destination-over",
	[kEJCompositeOperationSourceAtop] = "source-atop",
	[kEJCompositeOperationXOR] = "xor"
};

static const char * EJScalingModeNames[] = {
	[kEJScalingModeNone] = "none",
	[kEJScalingModeFitWidth] = "fit-width",
	[kEJScalingModeFitHeight] = "fit-height"
};

// ------------------------------------------------------------------------------------
// Shorthand to bind enums with name tables as defined above

#define EJ_BIND_ENUM(name, enumNames, target) \
	EJ_BIND_GET(name, ctx) { \
		JSStringRef src = JSStringCreateWithUTF8CString( enumNames[target] ); \
		JSValueRef ret = JSValueMakeString(ctx, src); \
		JSStringRelease(src); \
		return ret; \
	} \
	\
	EJ_BIND_SET(name, ctx, value) { \
		JSStringRef str = JSValueToStringCopy(ctx, value, NULL); \
		const JSChar * strptr = JSStringGetCharactersPtr( str ); \
		int length = JSStringGetLength(str)-1; \
		for( int i = 0; i < sizeof(enumNames)/sizeof(enumNames[0]); i++ ) { \
			if( JSStrIsEqualToStr( strptr, enumNames[i], length) ) { \
				target = i; \
				break; \
			} \
		} \
		JSStringRelease( str );\
	}

static inline bool JSStrIsEqualToStr( const JSChar * s1, const char * s2, int length ) {
	for( int i = 0; i < length && *s1 != '\0' && *s1 == *s2; i++ ) {
		s1++;
		s2++;
	}
	return (*s1 == *s2);
}



@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
	EJCanvasContext * renderingContext;
	EJApp * ejectaInstance;
	short width, height;
	
	BOOL isScreenCanvas;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
	
	BOOL msaaEnabled;
	int msaaSamples;
}
	
@property (readonly, nonatomic) EJTexture * texture;

@end
