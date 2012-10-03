#import "EJFont.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "EJCanvasContext.h"
#include <malloc/malloc.h>

#define PT_TO_PX(pt) ceilf((pt)*(1.0f+(1.0f/3.0f)))
#define TEXTURE_SIZE 1024

typedef struct _tagGlypInfo {
	float x,y,w,h;
	CFIndex ti;
	float tx,ty,tw,th;
} GlyphInfo;

typedef struct _tagStringLayout {
	const CGGlyph *glyphs;
	CFIndex glyphCount;
	CGPoint *positions;
} StringLayout;

@interface EJFont () {
	// glyph information
	NSMutableArray *textures;
	GlyphInfo *glyphInfo;
	float txLineX,txLineY,txLineH;
	GLubyte *txPixels;
	
	// font preferences
	float pointSize,ascent,ascentDelta,descent,leading,lineHeight,contentScale;
	BOOL fill;
	
	// font references
	CTFontRef ctFont;
	CGFontRef cgFont;
	
	// core text variables for line layout
	CGGlyph* _glyphsBuffer;
	CGPoint *_positionsBuffer;
	CTLineRef _ctLine;
}
@end

@implementation EJFont

- (void)dealloc
{
	free(txPixels);
	
	CGFontRelease(cgFont);
	CFRelease(ctFont);
	
	[textures release];
	
	free(_glyphsBuffer);
	free(_positionsBuffer);
	
	free(glyphInfo);
	
	[super dealloc];
}

- (StringLayout)layoutString:(NSString*)string
{
	StringLayout layout;
	
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { ctFont };
	
	CFDictionaryRef attributes =
    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
					   (const void**)&values, sizeof(keys) / sizeof(keys[0]),
					   &kCFTypeDictionaryKeyCallBacks,
					   &kCFTypeDictionaryValueCallBacks);
	
	CFAttributedStringRef attrString =
    CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)string, attributes);
	CFRelease(attributes);
	
	_ctLine = CTLineCreateWithAttributedString(attrString);
	
	CFRelease(attrString);
	
	CFArrayRef glyphRuns	= CTLineGetGlyphRuns(_ctLine);
	CFIndex runCount		= CFArrayGetCount(glyphRuns);
	
	assert(runCount==1); // line should only require one run, because we use one font and no attributes
	
	CTRunRef run		= CFArrayGetValueAtIndex(glyphRuns, 0);
	CFIndex glyphCount	= CTRunGetGlyphCount(run);
	
	// fetch glyph index buffer
	const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
	if (glyphs == NULL) {
		size_t glyphsBufferSize = sizeof(CGGlyph) * glyphCount;
		if (malloc_size(_glyphsBuffer) < glyphsBufferSize) {
			_glyphsBuffer = realloc(_glyphsBuffer, glyphsBufferSize);
		}
		CTRunGetGlyphs(run, CFRangeMake(0, 0), (CGGlyph*)glyphs);
		glyphs = _glyphsBuffer;
	}
	
	// fetch glyph position buffer
	CGPoint *positions = (CGPoint*)CTRunGetPositionsPtr(run);
	if (positions == NULL) {
		size_t positionsBufferSize = sizeof(CGPoint) * glyphCount;
		if (malloc_size(_positionsBuffer) < positionsBufferSize) {
			_positionsBuffer = realloc(_positionsBuffer, positionsBufferSize);
		}
		CTRunGetPositions(run, CFRangeMake(0, 0), _positionsBuffer);
		positions = _positionsBuffer;
	}
	
	layout.glyphCount	= glyphCount;
	layout.glyphs		= glyphs;
	layout.positions	= positions;
	
	return layout;
}

- (double)widthForLayout {
	return CTLineGetTypographicBounds(_ctLine, NULL, NULL, NULL);
}

- (void)releaseLayout
{
	CFRelease(_ctLine);
}

- (void)layoutGlyphs:(const CGGlyph*)glyphs amount:(CFIndex)amount {
	GlyphInfo *info;
	
	CGRect bbRect;
	CGContextRef context;
	
	EJTexture *texture = NULL;
	
	for(CFIndex index=0;index<amount;index++) {
		// get glyph information
		info = &glyphInfo[glyphs[index]];
		if(info->ti) {
			continue;
		}
		
		// get bounding box
		CTFontGetBoundingRectsForGlyphs(ctFont, kCTFontDefaultOrientation, &glyphs[index], &bbRect, 1);
		
		// add some padding around the glyphs because PT_TO_PX is just an approximization
		info->y = PT_TO_PX(bbRect.origin.y) - 2;
		info->x = PT_TO_PX(bbRect.origin.x) - 2;
		info->w = PT_TO_PX(bbRect.size.width) + 4;
		info->h = PT_TO_PX(bbRect.size.height) + 4;
		
		// check if current texture is full
		BOOL isFull = NO, switchedTexture = (index==0);
		
		// texture coordinates
		if(txLineX+((info->w+2)*contentScale)>TEXTURE_SIZE) {
			txLineX = 0.0f;
			txLineY += txLineH;
			txLineH = 0.0f;
			if(txLineY+((info->h+2)*contentScale)>TEXTURE_SIZE) {
				isFull = YES;
			}
		}
		
		// create rendering context
		if(index==0) {
			// create and clear pixel buffer
			if(!txPixels) {
				txPixels = (GLubyte *) malloc( TEXTURE_SIZE * TEXTURE_SIZE);
			}
			
			// create context
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
			context = CGBitmapContextCreate(txPixels, TEXTURE_SIZE, TEXTURE_SIZE, 8, TEXTURE_SIZE, colorSpace, kCGImageAlphaNone);
			CGColorSpaceRelease(colorSpace);
			
			CGContextSetFont(context, cgFont);
			CGContextSetFontSize(context, PT_TO_PX(pointSize));
			
			CGContextTranslateCTM(context, 0.0, TEXTURE_SIZE);
			CGContextScaleCTM(context, contentScale, -1.0*contentScale);
			
			// select text rendering mode
			if( fill ) {
				CGContextSetTextDrawingMode(context, kCGTextFill);
				CGContextSetGrayFillColor(context, 1.0, 1.0);
			} else {
				CGContextSetTextDrawingMode(context, kCGTextStroke);
				CGContextSetGrayStrokeColor(context, 1.0, 1.0);
				CGContextSetLineWidth(context, 1);
			}
		}
		
		// create a new texture if neccessary
		if([textures count] == 0 || isFull) {
			// if there was a previous texture, send updated content to opengl
			if(texture) {
				[texture createTextureWithPixels:txPixels format:GL_ALPHA];
			}
			
			// clear pixel buffer
			memset( txPixels, 0, TEXTURE_SIZE*TEXTURE_SIZE);
			
			// now start new texture
			txLineX = txLineY = txLineH = 0;
			
			texture = [[EJTexture alloc] init];
			[texture setWidth:TEXTURE_SIZE height:TEXTURE_SIZE];
			
			[textures addObject:texture];
			[texture release];
			
			switchedTexture = YES;
		
		// just use existing texture
		} else if(!texture) {
			texture = [textures lastObject];
		}
		
		// calculate texture coordinates
		info->ti = [textures count]; // 0 is reserved, index starts at 1
		info->tx = ((txLineX+1) / TEXTURE_SIZE);
		info->ty = ((txLineY+1) / TEXTURE_SIZE);
		info->tw = (info->w / TEXTURE_SIZE) * contentScale,
		info->th = (info->h / TEXTURE_SIZE) * contentScale;
		
		// render glyph
		CGContextShowGlyphsAtPoint(context,((txLineX+1)/contentScale) - info->x,((txLineY+1)/contentScale) - info->y, glyphs+index, 1);
		
		// update texture coordinates
		txLineX += info->w*contentScale + 2;
		if(info->h*contentScale + 2 > txLineH) {
			txLineH = info->h*contentScale + 2;
		}
	}
	
	// if any texture was modified, send the updated content to opengl
	if(texture) {
		[texture createTextureWithPixels:txPixels format:GL_ALPHA];
		CGContextRelease(context);
	}
}

- (id)initWithFont:(NSString *)font size:(NSInteger)ptSize fill:(BOOL)useFill contentScale:(float)cs
{
	self = [super init];
	if(self) {
		_positionsBuffer = NULL;
		_glyphsBuffer = NULL;
		
		txPixels = NULL;
		
		contentScale = cs;
		fill = useFill;
		
		ctFont = CTFontCreateWithName((CFStringRef)font, ptSize, NULL);
		cgFont = CTFontCopyGraphicsFont(ctFont, NULL);
		
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
			
			textures = [[NSMutableArray alloc] initWithCapacity:1];
			
			CFIndex glyphCount = CTFontGetGlyphCount(ctFont);
		
			glyphInfo = (GlyphInfo*)malloc(sizeof(GlyphInfo)*glyphCount);
			memset(glyphInfo,0,sizeof(GlyphInfo)*glyphCount);
		}
	}
	return self;
}

- (void)drawString:(NSString*)string toContext:(EJCanvasContext*)context x:(float)x y:(float)y {
	StringLayout layout = [self layoutString:string];
	
	GlyphInfo *info;
	
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
	
	// layout missing glyphs
	[self layoutGlyphs:layout.glyphs amount:layout.glyphCount];
	
	// flag required textures
	CFIndex index, numTextures = textures.count;
	BOOL textureSet[[textures count]];
	memset(textureSet,0,numTextures*sizeof(BOOL));
	
	for(index=0;index<layout.glyphCount;index++) {
		textureSet[glyphInfo[layout.glyphs[index]].ti-1] = 1;
	}
		
	// draw glyphs
	for(index=0;index<numTextures;index++) {
		if(!textureSet[index]){
			continue;
		}
	
		EJTexture *texture = [textures objectAtIndex:index];
		[context setTexture:texture];
		
		float gx,gy;
		for(int i=0;i<layout.glyphCount;i++) {
			info = &glyphInfo[layout.glyphs[i]];
			
			if(info->ti-1 != index) {
				continue;
			}
			
			gx = x + PT_TO_PX(layout.positions[i].x) + info->x;
			gy = y - (info->h + info->y);
			
			[context pushRectX:gx y:gy w:info->w h:info->h tx:info->tx ty:info->ty+info->th tw:info->tw th:-info->th color:context.state->fillColor withTransform:context.state->transform];
		}
	}
	
	// unbind texture
	[context setTexture:NULL];
	
	[self releaseLayout];
}

- (float)measureString:(NSString*)string
{
	float width;
	
	[self layoutString:string];
	width = [self widthForLayout];
	[self releaseLayout];
	
	return width;
}

@end
