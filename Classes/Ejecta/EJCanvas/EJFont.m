#import "EJFont.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContext.h"
#include <malloc/malloc.h>

#define PT_TO_PX(pt) ceilf((pt)*(1.0f+(1.0f/3.0f)))


typedef struct {
	float x, y, w, h;
	unsigned short textureIndex;
	float tx, ty, tw, th;
} GlyphInfo;

typedef struct {
	const CGGlyph * glyphs;
	unsigned short glyphCount;
	CGPoint *positions;
} StringLayout;

typedef struct {
	unsigned short textureIndex;
	unsigned short layoutIndex;
} TextureToGlyph;

int TextureToGlyphSort(const void * a, const void * b) {
	return ( ((TextureToGlyph*)a)->textureIndex - ((TextureToGlyph*)b)->textureIndex );
}

@interface EJFont () {
	// Glyph information
	NSMutableArray * textures;
	GlyphInfo * glyphInfoMap;
	float txLineX, txLineY, txLineH;
	
	// Font preferences
	float pointSize, ascent, ascentDelta, descent, leading, lineHeight, contentScale;
	BOOL fill;
	
	// Font references
	CTFontRef ctFont;
	CGFontRef cgFont;
	
	// Core text variables for line layout
	CGGlyph * _glyphsBuffer;
	CGPoint * _positionsBuffer;
	CTLineRef _ctLine;
}
@end

@implementation EJFont

- (id)initWithFont:(NSString *)font size:(NSInteger)ptSize fill:(BOOL)useFill contentScale:(float)cs {
	self = [super init];
	if(self) {
		_positionsBuffer = NULL;
		_glyphsBuffer = NULL;
		
		contentScale = cs;
		fill = useFill;
		
		ctFont = CTFontCreateWithName((CFStringRef)font, ptSize, NULL);
		cgFont = CTFontCopyGraphicsFont(ctFont, NULL);
		
		if( ctFont ) {
			pointSize = ptSize;
			leading	= CTFontGetLeading(ctFont);
			ascent = CTFontGetAscent(ctFont);
			descent = CTFontGetDescent(ctFont);
			lineHeight = leading + ascent + descent;
			if( leading == 0 ) {
				ascentDelta = floor (0.2 * lineHeight + 0.5);
				lineHeight += ascentDelta;
			}
			else {
				ascentDelta = 0.0f;
			}
			
			textures = [[NSMutableArray alloc] initWithCapacity:1];
			
			int glyphCount = CTFontGetGlyphCount(ctFont);
			glyphInfoMap = (GlyphInfo*) malloc( sizeof(GlyphInfo) * glyphCount );
			memset(glyphInfoMap, 0, sizeof(GlyphInfo) * glyphCount);
		}
	}
	return self;
}

- (void)dealloc {
	CGFontRelease(cgFont);
	CFRelease(ctFont);
	
	[textures release];
	
	free(_glyphsBuffer);
	free(_positionsBuffer);
	
	free(glyphInfoMap);
	
	[super dealloc];
}

- (StringLayout)layoutForString:(NSString*)string {
	StringLayout layout;
	
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { ctFont };
	
	CFDictionaryRef attributes = CFDictionaryCreate(
		kCFAllocatorDefault, (const void**)&keys,
		(const void**)&values, sizeof(keys) / sizeof(keys[0]),
		&kCFTypeDictionaryKeyCallBacks,
		&kCFTypeDictionaryValueCallBacks );
	
	CFAttributedStringRef attrString =
    CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)string, attributes);
	CFRelease(attributes);
	
	_ctLine = CTLineCreateWithAttributedString(attrString);
	
	CFRelease(attrString);
	
	CFArrayRef glyphRuns = CTLineGetGlyphRuns(_ctLine);
	CFIndex runCount = CFArrayGetCount(glyphRuns);
	
	assert(runCount==1); // line should only require one run, because we use one font and no attributes
	
	CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, 0);
	CFIndex glyphCount = CTRunGetGlyphCount(run);
	
	// fetch glyph index buffer
	const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
	if( glyphs == NULL ) {
		size_t glyphsBufferSize = sizeof(CGGlyph) * glyphCount;
		if( malloc_size(_glyphsBuffer) < glyphsBufferSize ) {
			_glyphsBuffer = realloc(_glyphsBuffer, glyphsBufferSize);
		}
		CTRunGetGlyphs(run, CFRangeMake(0, 0), (CGGlyph*)glyphs);
		glyphs = _glyphsBuffer;
	}
	
	// fetch glyph position buffer
	CGPoint * positions = (CGPoint*)CTRunGetPositionsPtr(run);
	if( positions == NULL ) {
		size_t positionsBufferSize = sizeof(CGPoint) * glyphCount;
		if( malloc_size(_positionsBuffer) < positionsBufferSize ) {
			_positionsBuffer = realloc(_positionsBuffer, positionsBufferSize);
		}
		CTRunGetPositions(run, CFRangeMake(0, 0), _positionsBuffer);
		positions = _positionsBuffer;
	}
	
	layout.glyphCount = glyphCount;
	layout.glyphs = glyphs;
	layout.positions = positions;
	
	return layout;
}

- (double)widthForLayout {
	return PT_TO_PX(CTLineGetTypographicBounds(_ctLine, NULL, NULL, NULL));
}

- (void)releaseLayout {
	CFRelease(_ctLine);
}

- (unsigned short)createGlyph:(CGGlyph)glyph {
	
	// Get glyph information
	GlyphInfo * glyphInfo = &glyphInfoMap[glyph];
	
	CGRect bbRect;
	CTFontGetBoundingRectsForGlyphs(ctFont, kCTFontDefaultOrientation, &glyph, &bbRect, 1);
	
	// Add some padding around the glyphs because PT_TO_PX is just an approximization
	glyphInfo->y = PT_TO_PX(bbRect.origin.y) - 3;
	glyphInfo->x = PT_TO_PX(bbRect.origin.x) - 3;
	glyphInfo->w = PT_TO_PX(bbRect.size.width) + 6;
	glyphInfo->h = PT_TO_PX(bbRect.size.height) + 6;
	
	// Size needed for this glyph in pixels; must be a multiple of 8 for CG
	int pxWidth = floorf((glyphInfo->w * contentScale) / 8 + 1) * 8;
	int pxHeight = floorf((glyphInfo->h * contentScale) / 8 + 1) * 8;
		
	// Do we need to create a new texture to hold this glyph?
	BOOL createNewTexture = (textures.count == 0);
	
	if( txLineX + pxWidth > EJ_FONT_TEXTURE_SIZE ) {
		// New line
		txLineX = 0.0f;
		txLineY += txLineH;
		txLineH = 0.0f;
		
		// Line exceeds texture height? -> new texture
		if( txLineY + pxHeight > EJ_FONT_TEXTURE_SIZE) {
			createNewTexture = YES;
		}
	}
	
	EJTexture * texture;
	if( createNewTexture ) {
		txLineX = txLineY = txLineH = 0;		
		texture = [[EJTexture alloc] initWithWidth:EJ_FONT_TEXTURE_SIZE height:EJ_FONT_TEXTURE_SIZE format:GL_ALPHA];
		[textures addObject:texture];
		[texture release];	
	}
	else {
		texture = [textures lastObject];
	}
	
	glyphInfo->textureIndex = textures.count; // 0 is reserved, index starts at 1
	glyphInfo->tx = ((txLineX+1) / EJ_FONT_TEXTURE_SIZE);
	glyphInfo->ty = ((txLineY+1) / EJ_FONT_TEXTURE_SIZE);
	glyphInfo->tw = (glyphInfo->w / EJ_FONT_TEXTURE_SIZE) * contentScale,
	glyphInfo->th = (glyphInfo->h / EJ_FONT_TEXTURE_SIZE) * contentScale;
	
	
	GLubyte * pixels = (GLubyte *) malloc( pxWidth * pxHeight);
	memset( pixels, 0, pxWidth * pxHeight );
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(pixels, pxWidth, pxHeight, 8, pxWidth, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	CGContextSetFont(context, cgFont);
	CGContextSetFontSize(context, PT_TO_PX(pointSize));
	
	CGContextTranslateCTM(context, 0.0, pxHeight);
	CGContextScaleCTM(context, contentScale, -1.0*contentScale);
	
	// Fill or stroke?
	if( fill ) {
		CGContextSetTextDrawingMode(context, kCGTextFill);
		CGContextSetGrayFillColor(context, 1.0, 1.0);
	}
	else {
		CGContextSetTextDrawingMode(context, kCGTextStroke);
		CGContextSetGrayStrokeColor(context, 1.0, 1.0);
		CGContextSetLineWidth(context, 1);
	}
	
	// Render glyph and update the texture
	CGContextShowGlyphsAtPoint(context, -glyphInfo->x, -glyphInfo->y, &glyph, 1);
	[texture updateTextureWithPixels:pixels	atX:txLineX y:txLineY width:pxWidth height:pxHeight];
	
	// Update texture coordinates
	txLineX += pxWidth;
	txLineH = MAX( txLineH, pxHeight );
	
	free(pixels);
	CGContextRelease(context);
	
	return glyphInfo->textureIndex;
}

- (void)drawString:(NSString*)string toContext:(EJCanvasContext*)context x:(float)x y:(float)y {

	StringLayout layout = [self layoutForString:string];
	
	x = roundf(x);
	y = roundf(y);
	
	// Figure out the x position with the current textAlign.
	if(context.state->textAlign != kEJTextAlignLeft) {
		float w = [self widthForLayout];
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
	
	// Fill or stroke color?
	EJCanvasState * state = context.state;
	EJColorRGBA color = fill ? state->fillColor : state->strokeColor;
	color.rgba.a = (float)color.rgba.a * state->globalAlpha;
	
	// Create all glyphs that are not yet loaded and collect texture indicies
	// along the way
	TextureToGlyph texturesToGlyphs[layout.glyphCount];
	for( int i = 0; i < layout.glyphCount; i++ ) {
		int textureIndex = glyphInfoMap[layout.glyphs[i]].textureIndex;
		if( !textureIndex ) {
			textureIndex = [self createGlyph:layout.glyphs[i]];
		}
		texturesToGlyphs[i].textureIndex = textureIndex;
		texturesToGlyphs[i].layoutIndex = i;
	}
	
	
	// Sort glyphs by texture index. This way we can loop through the all glyphs while
	// minimizing the amount of texture binds needed. Skip this if we only have
	// one texture anyway
	if( textures.count > 1 ) {
		qsort( texturesToGlyphs, layout.glyphCount, sizeof(TextureToGlyph), TextureToGlyphSort);
	}
	
	// Go through all glyphs - bind textures if needed - and draw
	int i = 0;
	while( i < layout.glyphCount ) {
		int textureIndex = texturesToGlyphs[i].textureIndex;
		[context setTexture:[textures objectAtIndex:textureIndex-1]];
		
		// Go through glyphs while the texture stays the same
		while( i < layout.glyphCount && textureIndex == texturesToGlyphs[i].textureIndex ) {
			int layoutIndex = texturesToGlyphs[i].layoutIndex;
			GlyphInfo * glyphInfo = &glyphInfoMap[layout.glyphs[layoutIndex]];
			
			float gx = x + PT_TO_PX(layout.positions[layoutIndex].x) + glyphInfo->x;
			float gy = y - (glyphInfo->h + glyphInfo->y);
			
			[context pushRectX:gx y:gy w:glyphInfo->w h:glyphInfo->h
				tx:glyphInfo->tx ty:glyphInfo->ty+glyphInfo->th tw:glyphInfo->tw th:-glyphInfo->th
				color:color withTransform:state->transform];
			
			i++;
		}
	}
	
	[self releaseLayout];
}

- (float)measureString:(NSString*)string {
	float width;
	
	[self layoutForString:string];
	width = [self widthForLayout];
	[self releaseLayout];
	
	return width;
}

@end
