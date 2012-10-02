#import "EJFont.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContext.h"

#define ASSERT_ASCII(i) assert(i>=0&&i<=255);

#define PT_TO_PX(pt) ceilf((pt)*(1.0f+(1.0f/3.0f)))
#define PT_TO_PX_ROUND(pt) roundf((pt)*(1.0f+(1.0f/3.0f)))

typedef struct _tagGlypInfo {
	float x,y,w,h,a;
} GlyphInfo;

@interface EJFont () {
	GlyphInfo *glyphInfo;
	float contentScale;
	
	float pointSize,ascent,ascentDelta,descent,leading,lineHeight;
}
@end

@implementation EJFont

- (void)dealloc
{
	free(glyphInfo);
	[super dealloc];
}

- (id)initWithFont:(NSString *)font size:(NSInteger)ptSize fill:(BOOL)fill contentScale:(float)cs
{
	self = [super init];
	if(self) {
		contentScale = cs;
				
		CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font, ptSize, NULL);
		
		CGFontRef cgFont = CTFontCopyGraphicsFont(ctFont, NULL);
		
		if(ctFont) {
			pointSize	= ptSize;
			leading		= CTFontGetLeading(ctFont);
			ascent		= CTFontGetAscent(ctFont);
			descent		= CTFontGetDescent(ctFont);
			lineHeight	= leading + ascent + descent;
			if (leading == 0) {
				ascentDelta = floor (0.2 * lineHeight + 0.5);
				lineHeight += ascentDelta;
			} else {
				ascentDelta = 0.0f;
			}
			
			CGRect bbRect;
			CGSize size;
			
			CGRect boundingBox = CGRectMake(0, 0, PT_TO_PX(ptSize)*16, PT_TO_PX(ptSize)*16);
			[self setWidth:boundingBox.size.width*contentScale height:boundingBox.size.height*contentScale];
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
			GLubyte * pixels = (GLubyte *) malloc( realWidth * realHeight);
			memset( pixels, 0, realWidth * realHeight);
			CGContextRef context = CGBitmapContextCreate(pixels, realWidth, realHeight, 8, realWidth, colorSpace, kCGImageAlphaNone);
			CGColorSpaceRelease(colorSpace);
			
			CGContextSetFont(context, cgFont);
			CGContextSetFontSize(context, PT_TO_PX(ptSize));
			
			UIGraphicsPushContext(context);
			CGContextTranslateCTM(context, 0.0, realHeight);
			CGContextScaleCTM(context, contentScale, -1.0*contentScale);
			
			int gridW = realWidth/16/contentScale,gridH=realHeight/16/contentScale;
			CGGlyph glyph;
			
			// Fill or stroke?
			if( fill ) {
				CGContextSetTextDrawingMode(context, kCGTextFill);
				CGContextSetGrayFillColor(context, 1.0, 1.0);
			} else {
				CGContextSetTextDrawingMode(context, kCGTextStroke);
				CGContextSetGrayStrokeColor(context, 1.0, 1.0);
				CGContextSetLineWidth(context, 1);
			}
			
			glyphInfo = (GlyphInfo*)malloc(sizeof(GlyphInfo)*255);
			
			for(unichar i=0;i<255;i++) {
				CTFontGetGlyphsForCharacters(ctFont, &i, &glyph, 1);
				CTFontGetBoundingRectsForGlyphs(ctFont, kCTFontDefaultOrientation, &glyph, &bbRect, 1);
				CGContextShowGlyphsAtPoint(context,(i%16)*gridW,(i/16)*gridH, &glyph, 1);
				glyphInfo[i].y = PT_TO_PX(bbRect.origin.y) - 1;
				glyphInfo[i].x = PT_TO_PX(bbRect.origin.x) - 1;
				glyphInfo[i].w = PT_TO_PX(bbRect.size.width) + 1;
				glyphInfo[i].h = PT_TO_PX(bbRect.size.height) + 1;
				CTFontGetAdvancesForGlyphs(ctFont, kCTFontDefaultOrientation, &glyph, &size, 1);
				glyphInfo[i].a = PT_TO_PX(size.width);
			}
			
			[self createTextureWithPixels:pixels format:GL_ALPHA];
			
			CGContextRelease(context);
			free(pixels);				
		}
		CGFontRelease(cgFont);
		CFRelease(ctFont);
	}
	return self;
}

- (void)drawString:(NSString*)string toContext:(EJCanvasContext*)context x:(float)x y:(float)y {
	unichar glyphIndex;
	GlyphInfo info;
	
	x = roundf(x);
	y = roundf(y);
	
	// Figure out the x position with the current textAlign.
	if(context.state->textAlign != kEJTextAlignLeft) {
		float w = 0;
		for(int i=0;i<[string length];i++) {
			glyphIndex = [string characterAtIndex:i];
			ASSERT_ASCII(glyphIndex);
			w += glyphInfo[glyphIndex].a;
		}
		if( context.state->textAlign == kEJTextAlignRight || context.state->textAlign == kEJTextAlignEnd ) {
			x -= w;
		} else if( context.state->textAlign == kEJTextAlignCenter ) {
			x -= roundf(w/2.0f);
		}
	}

	// Figure out the y position with the current textBaseline
	switch( context.state->textBaseline ) {
		case kEJTextBaselineAlphabetic:
		case kEJTextBaselineIdeographic:
			break;
		case kEJTextBaselineTop:
		case kEJTextBaselineHanging:
			y += PT_TO_PX(ascent+ascentDelta);
			break;
		case kEJTextBaselineMiddle:
			y += PT_TO_PX(ascent-0.5*pointSize);
			break;
		case kEJTextBaselineBottom:
			y -= PT_TO_PX(descent);
			break;
	}
	
	// draw glyphs
	[context setTexture:self];
	
	for(int i=0;i<[string length];i++) {
		glyphIndex = [string characterAtIndex:i];
		ASSERT_ASCII(glyphIndex);
		
		info = glyphInfo[glyphIndex];

		float	tx = (glyphIndex%16) * (1.0f/16.0f) + (info.x/realWidth) * contentScale,
				ty = (glyphIndex/16) * (1.0f/16.0f) + (info.y/realHeight) * contentScale,
				tw = (info.w / realWidth) * contentScale,
				th = (info.h / realHeight) * contentScale;
		
		[context pushRectX:x+info.x y:y-info.h-info.y w:info.w h:info.h tx:tx ty:ty+th tw:tw th:-th color:context.state->fillColor withTransform:context.state->transform];
		
		x += info.a;
	}
	
	// We need to flush buffers now, otherwise the texture may already be autoreleased
	[context flushBuffers];
	[context setTexture:NULL];
}

- (float)measureString:(NSString*)string
{
	unichar glyphIndex;
	float w = 0;
	for(int i=0;i<[string length];i++) {
		glyphIndex = [string characterAtIndex:i];
		ASSERT_ASCII(glyphIndex);
		w += glyphInfo[glyphIndex].a;
	}
	return w;
}

@end
