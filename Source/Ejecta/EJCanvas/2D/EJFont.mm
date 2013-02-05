#import "EJFont.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContext2D.h"
#include <malloc/malloc.h>
#include <ext/hash_map>

@implementation EJFontDescriptor
@synthesize identFilled, identOutlined, name, size;

+ (id)descriptorWithName:(NSString *)name size:(float)size {
	// Check if the font exists
	if( ![UIFont fontWithName:name size:size] ) {
		return NULL;
	}
	
	EJFontDescriptor * descriptor = [[EJFontDescriptor alloc] init];
	descriptor->name = [name retain];
	descriptor->size = size;
	
	descriptor->identFilled = [[NSString stringWithFormat:@"%@:F:%.2f", name, size] retain];
	descriptor->identOutlined = [[NSString stringWithFormat:@"%@:O:%.2f", name, size] retain];
	
	return [descriptor autorelease];
}

- (void)dealloc {
	[identFilled release];
	[identOutlined release];
	[name release];
	[super dealloc];
}

@end


#define PT_TO_PX(pt) ceilf((pt)*(1.0f+(1.0f/3.0f)))

typedef struct {
	float x, y, w, h;
	unsigned short textureIndex;
	float tx, ty, tw, th;
} GlyphInfo;

typedef struct {
	unsigned short textureIndex;
	CGGlyph glyph;
	float xpos;
	GlyphInfo * info;
} GlyphLayout;




@interface EJFontLayout : NSObject {
	NSData * glyphLayout;
	EJTextMetrics metrics;
	int glyphCount;
}

- (id)initWithGlyphLayout:(NSData *)layoutp glyphCount:(int)count metrics:(EJTextMetrics)metrics;
@property (readonly, nonatomic) GlyphLayout * layout;
@property (readonly, nonatomic) int glyphCount;
@property (readonly, nonatomic) EJTextMetrics metrics;
@end

@implementation EJFontLayout
@synthesize metrics, glyphCount;
- (id)initWithGlyphLayout:(NSData *)layout glyphCount:(int)count metrics:(EJTextMetrics)metricsp {
	if( self = [super init] ) {
		glyphLayout = [layout retain];
		glyphCount = count;
		metrics = metricsp;
	}
	return self;
}

- (void)dealloc {
	[glyphLayout release];
	[super dealloc];
}

- (GlyphLayout *)glyphLayout {
	return (GlyphLayout *)glyphLayout.bytes;
}
@end




int GlyphLayoutSortByTextureIndex(const void * a, const void * b) {
	return ( ((GlyphLayout*)a)->textureIndex - ((GlyphLayout*)b)->textureIndex );
}

@interface EJFont () {
	// Glyph information
	NSMutableArray * textures;
	__gnu_cxx::hash_map<int, GlyphInfo> glyphInfoMap;
	float txLineX, txLineY, txLineH;
	
	NSCache * layoutCache;
	
	// Font preferences
	float pointSize, ascent, ascentDelta, descent, leading, lineHeight, contentScale;
	BOOL fill;
	
	// Font references
	CTFontRef ctMainFont;
	CGFontRef cgMainFont;
	
	// Core text variables for line layout
	CGGlyph * glyphsBuffer;
	CGPoint * positionsBuffer;
}
@end

@implementation EJFont

- (id)initWithDescriptor:(EJFontDescriptor *)desc fill:(BOOL)fillp contentScale:(float)contentScalep {
	self = [super init];
	if(self) {
		positionsBuffer = NULL;
		glyphsBuffer = NULL;
		
		contentScale = contentScalep;
		fill = fillp;
		
		ctMainFont = CTFontCreateWithName((CFStringRef)desc.name, desc.size, NULL);
		cgMainFont = CTFontCopyGraphicsFont(ctMainFont, NULL);
		
		if( ctMainFont ) {
			pointSize = desc.size;
			leading	= CTFontGetLeading(ctMainFont);
			ascent = CTFontGetAscent(ctMainFont);
			descent = CTFontGetDescent(ctMainFont);
			lineHeight = leading + ascent + descent;
			if( leading == 0 ) {
				ascentDelta = floor (0.2 * lineHeight + 0.5);
				lineHeight += ascentDelta;
			}
			else {
				ascentDelta = 0.0f;
			}
			
			textures = [[NSMutableArray alloc] initWithCapacity:1];
			layoutCache = [[NSCache alloc] init];
			layoutCache.countLimit = 128;
		}
	}
	return self;
}

+ (void)loadFontAtPath:(NSString*)path{
	NSData *inData = [[NSFileManager defaultManager] contentsAtPath:path];
	if(inData == nil){
		NSLog(@"Failed to load font. Data at path is null");
		return;
	}
	CFErrorRef error;
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
	CGFontRef font = CGFontCreateWithDataProvider(provider);
	if( !CTFontManagerRegisterGraphicsFont(font, &error) ){
		CFStringRef errorDescription = CFErrorCopyDescription(error);
		NSLog(@"Failed to load font: %@", errorDescription);
		CFRelease(errorDescription);
	}
	CFRelease(font);
	CFRelease(provider);
}

- (void)dealloc {
	CGFontRelease(cgMainFont);
	CFRelease(ctMainFont);
	
	[textures release];
	[layoutCache release];
	
	free(glyphsBuffer);
	free(positionsBuffer);
	
	[super dealloc];
}

- (unsigned short)createGlyph:(CGGlyph)glyph withFont:(CTFontRef)font {
	// Get glyph information
	GlyphInfo * glyphInfo = &glyphInfoMap[glyph];
	
	CGRect bbRect;
	CTFontGetBoundingRectsForGlyphs(font, kCTFontDefaultOrientation, &glyph, &bbRect, 1);
	
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
	
	NSMutableData * pixels = [NSMutableData dataWithLength:pxWidth * pxHeight];
	
	CGContextRef context = CGBitmapContextCreate(pixels.mutableBytes, pxWidth, pxHeight, 8, pxWidth, NULL, kCGImageAlphaOnly);
	
	CGFontRef graphicsFont = cgMainFont;
	if( font != ctMainFont ) {
		// Not the main font? Create the CGFont from the given ctFont.
		graphicsFont = CTFontCopyGraphicsFont(font, NULL);
	}
	
	
	CGContextSetFont(context, graphicsFont);
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
	[texture updateWithPixels:pixels atX:txLineX y:txLineY width:pxWidth height:pxHeight];
	
	// Update texture coordinates
	txLineX += pxWidth;
	txLineH = MAX( txLineH, pxHeight );
	
	
	if( font != ctMainFont ) {
		CGFontRelease(graphicsFont);
	}
	
	CGContextRelease(context);
	
	return glyphInfo->textureIndex;
}

- (EJFontLayout *)getLayoutForString:(NSString *)string {

	// Try Cache first
	EJFontLayout * cached = [layoutCache objectForKey:string];
	if( cached ) {
		return cached;
	}

	
	// Create attributed line
	NSAttributedString * attributes = [[NSAttributedString alloc]
		initWithString:string
		attributes:@{ (id)kCTFontAttributeName: (id)ctMainFont }];
	
	CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributes);
	
	[attributes release];
	
	// Get line metrics; sadly, ascent and descent are broken: 'ascent' equals
	// the total height (i.e. what should be ascent + descent) and 'descent'
	// is always the maximum descent of the font - no matter if you have
	// descending characters or not.
	// So, we have to collect those infos ourselfs from the glyphs.
	EJTextMetrics metrics = {
		.width = PT_TO_PX(CTLineGetTypographicBounds(line, NULL, NULL, NULL)),
		.ascent = 0,
		.descent = 0,
	};
	
	
	// Create a layout buffer large enough to hold all glyphs for this line
	int lineGlyphCount = CTLineGetGlyphCount(line);
	int layoutBufferSize = sizeof(GlyphLayout) * lineGlyphCount;
	NSMutableData * layoutData = [NSMutableData dataWithLength:layoutBufferSize];
	GlyphLayout * layoutBuffer = (GlyphLayout *)layoutData.mutableBytes;
		
	
	// Go through all runs for this line
	CFArrayRef runs = CTLineGetGlyphRuns(line);
	int runCount = CFArrayGetCount(runs);
	
	int layoutIndex = 0;
	for( int i = 0; i < runCount; i++ ) {
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
		int runGlyphCount = CTRunGetGlyphCount(run);
		CTFontRef runFont = (CTFontRef)CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
	
		// Fetch glyphs buffer
		const CGGlyph * glyphs = CTRunGetGlyphsPtr(run);
		if( !glyphs ) {
			size_t glyphsBufferSize = sizeof(CGGlyph) * runGlyphCount;
			if( malloc_size(glyphsBuffer) < glyphsBufferSize ) {
				glyphsBuffer = (CGGlyph *)realloc(glyphsBuffer, glyphsBufferSize);
			}
			CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphsBuffer);
			glyphs = glyphsBuffer;
		}
		
		// Fetch Positions buffer
		CGPoint * positions = (CGPoint*)CTRunGetPositionsPtr(run);
		if( !positions ) {
			size_t positionsBufferSize = sizeof(CGPoint) * runGlyphCount;
			if( malloc_size(positionsBuffer) < positionsBufferSize ) {
				positionsBuffer = (CGPoint *)realloc(positionsBuffer, positionsBufferSize);
			}
			CTRunGetPositions(run, CFRangeMake(0, 0), positionsBuffer);
			positions = positionsBuffer;
		}
		
		
		// Go through all glyphs for this run, create the textures and collect the glyph
		// info and positions as well as the max ascent and descent
		for( int g = 0; g < runGlyphCount; g++ ) {
			GlyphLayout * gl = &layoutBuffer[layoutIndex];
			gl->glyph = glyphs[g];
			gl->xpos = positions[g].x;
			gl->info = &glyphInfoMap[gl->glyph];
			
			gl->textureIndex = gl->info->textureIndex;
			if( !gl->textureIndex ) {
				gl->textureIndex = [self createGlyph:gl->glyph withFont:runFont];
			}
			
			metrics.ascent = MAX(metrics.ascent, (gl->info->h-6) + (gl->info->y+3));
			metrics.descent = MAX(metrics.descent, -(gl->info->y+3) );
			layoutIndex++;
		}		
	}	
	
	// Sort glyphs by texture index. This way we can loop through the all glyphs while
	// minimizing the amount of texture binds needed. Skip this if we only have
	// one texture anyway
	if( textures.count > 1 ) {
		qsort( layoutBuffer, lineGlyphCount, sizeof(GlyphLayout), GlyphLayoutSortByTextureIndex);
	}
	
	
	// Create the layout object and add it to the cache	
	EJFontLayout * layout = [[EJFontLayout alloc] initWithGlyphLayout:layoutData
		glyphCount:lineGlyphCount metrics:metrics];
		
	[layoutCache setObject:layout forKey:string];
	
	CFRelease(line);
	
	return [layout autorelease];
}

- (float)getYOffsetForBaseline:(EJTextBaseline)baseline {
	// Figure out the y position with the given textBaseline
	switch( baseline ) {
		case kEJTextBaselineAlphabetic:
		case kEJTextBaselineIdeographic:
			return 0;
		case kEJTextBaselineTop:
		case kEJTextBaselineHanging:
			return PT_TO_PX(ascent+ascentDelta);
		case kEJTextBaselineMiddle:
			return PT_TO_PX(ascent-0.5*pointSize);
		case kEJTextBaselineBottom:
			return -PT_TO_PX(descent);
	}
	return 0;
}

- (void)drawString:(NSString *)string toContext:(EJCanvasContext2D *)context x:(float)x y:(float)y {
	if( string.length == 0 ) { return; }
	
	EJFontLayout * layout = [self getLayoutForString:string];
	
	// Figure out the x position with the current textAlign.
	if(context.state->textAlign != kEJTextAlignLeft) {
		if( context.state->textAlign == kEJTextAlignRight || context.state->textAlign == kEJTextAlignEnd ) {
			x -= layout.metrics.width;
		}
		else if( context.state->textAlign == kEJTextAlignCenter ) {
			x -= layout.metrics.width/2.0f;
		}
	}

	y += [self getYOffsetForBaseline:context.state->textBaseline];
	
	x = roundf(x);
	y = roundf(y);
	
	
	// Fill or stroke color?
	EJCanvasState * state = context.state;
	EJColorRGBA color = fill ? state->fillColor : state->strokeColor;
	color.rgba.a = (float)color.rgba.a * state->globalAlpha;
	
	// Go through all glyphs - bind textures as needed - and draw
	GlyphLayout * layoutBuffer = layout.glyphLayout;
	int glyphCount = layout.glyphCount;
	int i = 0;
	while( i < glyphCount ) {
		int textureIndex = layoutBuffer[i].textureIndex;
		[context setTexture:[textures objectAtIndex:textureIndex-1]];
		
		// Go through glyphs while the texture stays the same
		while( i < glyphCount && textureIndex == layoutBuffer[i].textureIndex ) {
			GlyphInfo * glyphInfo = layoutBuffer[i].info;
			
			float gx = x + PT_TO_PX(layoutBuffer[i].xpos) + glyphInfo->x;
			float gy = y - (glyphInfo->h + glyphInfo->y);
			
			[context pushTexturedRectX:gx y:gy w:glyphInfo->w h:glyphInfo->h
				tx:glyphInfo->tx ty:glyphInfo->ty+glyphInfo->th tw:glyphInfo->tw th:-glyphInfo->th
				color:color withTransform:state->transform];
			
			i++;
		}
	}
}

- (EJTextMetrics)measureString:(NSString*)string forContext:(EJCanvasContext2D *)context {
	if( string.length == 0 ) { return {0}; }
	
	float yOffset = [self getYOffsetForBaseline:context.state->textBaseline];
	EJTextMetrics metrics = [self getLayoutForString:string].metrics;
	
	metrics.ascent += yOffset;
	metrics.descent += yOffset;
	
	return metrics;
}

@end
