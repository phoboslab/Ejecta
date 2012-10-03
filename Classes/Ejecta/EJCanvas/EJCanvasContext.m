#import "EJCanvasContext.h"

@implementation EJCanvasContext

EJVertex CanvasVertexBuffer[EJ_CANVAS_VERTEX_BUFFER_SIZE];


@synthesize state, backingStoreRatio;

- (id)initWithWidth:(short)widthp height:(short)heightp {
	if( self = [super init] ) {
	
		memset(stateStack, 0, sizeof(stateStack));
		stateIndex = 0;
		state = &stateStack[stateIndex];
		state->globalAlpha = 1;
		state->globalCompositeOperation = kEJCompositeOperationSourceOver;
		state->transform = CGAffineTransformIdentity;
		state->lineWidth = 1;
		state->lineCap = kEJLineCapButt;
		state->lineJoin = kEJLineJoinMiter;
		state->miterLimit = 10;
		state->textBaseline = kEJTextBaselineAlphabetic;
		state->textAlign = kEJTextAlignStart;
		state->font = [[UIFont fontWithName:@"Helvetica" size:10] retain];
		
		bufferWidth = viewportWidth = width = widthp;
		bufferHeight = viewportHeight = height = heightp;
		
		path = [[EJPath alloc] init];
		backingStoreRatio = 1;
	}
	return self;
}

- (void)dealloc {
	// Release all fonts from the stack
	for( int i = 0; i < stateIndex + 1; i++ ) {
		[stateStack[i].font release];
	}
	
	if( stencilBuffer ) {
		glDeleteRenderbuffers(1, &stencilBuffer);
	}
	if( frameBuffer ) {
		glDeleteFramebuffers( 1, &frameBuffer);
	}
	[path release];
	[lineTexture16 release];
	[lineTexture4 release];
	[super dealloc];
}

- (void)create {
	glGenFramebuffersOES(1, &frameBuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
}

- (void)createStencilBufferOnce {
	if( stencilBuffer ) { return; }
	
	glGenRenderbuffers(1, &stencilBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, stencilBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8_OES, bufferWidth, bufferHeight);
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, stencilBuffer);
}

- (void)bindVertexBuffer {
	glVertexPointer(2, GL_FLOAT, sizeof(EJVertex), &CanvasVertexBuffer[0].pos.x);
	glTexCoordPointer(2, GL_FLOAT, sizeof(EJVertex), &CanvasVertexBuffer[0].uv.x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(EJVertex), &CanvasVertexBuffer[0].color);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
}

- (void)prepare {
	// Bind the frameBuffer and vertexBuffer array
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
	
	glViewport(0, 0, viewportWidth, viewportHeight);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, width, 0, height, -1, 1);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	EJCompositeOperation op = state->globalCompositeOperation;
	glBlendFunc( EJCompositeOperationFuncs[op].source, EJCompositeOperationFuncs[op].destination );
	glDisable(GL_TEXTURE_2D);
	currentTexture = nil;
	
	[self bindVertexBuffer];
}

- (void)setTexture:(EJTexture *)newTexture {
	if( currentTexture == newTexture ) { return; }
	
	[self flushBuffers];
		
	if( !newTexture && currentTexture ) {
		// Was enabled; should be disabled
		glDisable(GL_TEXTURE_2D);
	}
	else if( newTexture && !currentTexture ) {
		// Was disabled; should be enabled
		glEnable(GL_TEXTURE_2D);
	}
	
	currentTexture = newTexture;
	[currentTexture bind];
}

- (void)pushQuadV1:(EJVector2)v1 v2:(EJVector2)v2 v3:(EJVector2)v3 v4:(EJVector2)v4
	t1:(EJVector2)t1 t2:(EJVector2)t2 t3:(EJVector2)t3 t4:(EJVector2)t4
	color:(EJColorRGBA)color
	withTransform:(CGAffineTransform)transform
{
	if( vertexBufferIndex >= EJ_CANVAS_VERTEX_BUFFER_SIZE - 6 ) {
		[self flushBuffers];
	}
	
	if( !CGAffineTransformIsIdentity(transform) ) {
		v1 = EJVector2ApplyTransform( v1, transform );
		v2 = EJVector2ApplyTransform( v2, transform );
		v3 = EJVector2ApplyTransform( v3, transform );
		v4 = EJVector2ApplyTransform( v4, transform );
	}
	
	EJVertex * vb = &CanvasVertexBuffer[vertexBufferIndex];
	vb[0] = (EJVertex) { v1, t1, color };
	vb[1] = (EJVertex) { v2, t2, color };
	vb[2] = (EJVertex) { v3, t3, color };
	vb[3] = (EJVertex) { v2, t2, color };
	vb[4] = (EJVertex) { v3, t3, color };
	vb[5] = (EJVertex) { v4, t4, color };
	
	vertexBufferIndex += 6;
}

- (void)pushRectX:(float)x y:(float)y w:(float)w h:(float)h
	tx:(float)tx ty:(float)ty tw:(float)tw th:(float)th
	color:(EJColorRGBA)color
	withTransform:(CGAffineTransform)transform
{
	if( vertexBufferIndex >= EJ_CANVAS_VERTEX_BUFFER_SIZE - 6 ) {
		[self flushBuffers];
	}
	
	EJVector2 d11 = { x, y };
	EJVector2 d21 = { x+w, y };
	EJVector2 d12 = { x, y+h };
	EJVector2 d22 = { x+w, y+h };
	
	if( !CGAffineTransformIsIdentity(transform) ) {
		d11 = EJVector2ApplyTransform( d11, transform );
		d21 = EJVector2ApplyTransform( d21, transform );
		d12 = EJVector2ApplyTransform( d12, transform );
		d22 = EJVector2ApplyTransform( d22, transform );
	}
	
	EJVertex * vb = &CanvasVertexBuffer[vertexBufferIndex];
	vb[0] = (EJVertex) { d11, {tx, ty}, color };	// top left
	vb[1] = (EJVertex) { d21, {tx+tw, ty}, color };	// top right
	vb[2] = (EJVertex) { d12, {tx, ty+th}, color };	// bottom left
		
	vb[3] = (EJVertex) { d21, {tx+tw, ty}, color };	// top right
	vb[4] = (EJVertex) { d12, {tx, ty+th}, color };	// bottom left
	vb[5] = (EJVertex) { d22, {tx+tw, ty+th}, color };// bottom right
	
	vertexBufferIndex += 6;
}

- (void)flushBuffers {
	if( vertexBufferIndex == 0 ) { return; }
	
	glDrawArrays(GL_TRIANGLES, 0, vertexBufferIndex);
	vertexBufferIndex = 0;
}

- (void)setGlobalCompositeOperation:(EJCompositeOperation)op {
	[self flushBuffers];
	glBlendFunc( EJCompositeOperationFuncs[op].source, EJCompositeOperationFuncs[op].destination );
	state->globalCompositeOperation = op;
}

- (EJCompositeOperation)globalCompositeOperation {
	return state->globalCompositeOperation;
}

- (void)setFont:(UIFont *)font {
	[state->font release];
	state->font = [font retain];
}

- (UIFont *)font {
	return state->font;
}


- (void)save {
	if( stateIndex == EJ_CANVAS_STATE_STACK_SIZE-1 ) {
		NSLog(@"Warning: EJ_CANVAS_STATE_STACK_SIZE (%d) reached", EJ_CANVAS_STATE_STACK_SIZE);
		return;
	}
	stateStack[stateIndex+1] = stateStack[stateIndex];
	stateIndex++;
	state = &stateStack[stateIndex];
	[state->font retain];
}

- (void)restore {
	if( stateIndex == 0 ) {
		NSLog(@"Warning: Can't pop stack at index 0");
		return;
	}
	EJCompositeOperation oldCompositeOp = state->globalCompositeOperation;
	
	[state->font release];
	
	stateIndex--;
	state = &stateStack[stateIndex];
	
    path.transform = state->transform;
    
	if( state->globalCompositeOperation != oldCompositeOp ) {
		self.globalCompositeOperation = state->globalCompositeOperation;
	}
}

- (void)rotate:(float)angle {
	state->transform = CGAffineTransformRotate( state->transform, angle );
    path.transform = state->transform;
}

- (void)translateX:(float)x y:(float)y {
	state->transform = CGAffineTransformTranslate( state->transform, x, y );
    path.transform = state->transform;
}

- (void)scaleX:(float)x y:(float)y {
	state->transform = CGAffineTransformScale( state->transform, x, y );
	path.transform = state->transform;
}

- (void)transformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 dx:(float)dx dy:(float)dy {
	CGAffineTransform t = CGAffineTransformMake( m11, m12, m21, m22, dx, dy );
	state->transform = CGAffineTransformConcat( state->transform, t );
	path.transform = state->transform;
}

- (void)setTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 dx:(float)dx dy:(float)dy {
	state->transform = CGAffineTransformMake( m11, m12, m21, m22, dx, dy );
	path.transform = state->transform;
}

- (void)drawImage:(EJTexture *)texture sx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh dx:(float)dx dy:(float)dy dw:(float)dw dh:(float)dh {
	
	float tw = texture.realWidth;
	float th = texture.realHeight;
	
	EJColorRGBA color = {.rgba = {255, 255, 255, 255 * state->globalAlpha}};
	[self setTexture:texture];
	[self pushRectX:dx y:dy w:dw h:dh tx:sx/tw ty:sy/th tw:sw/tw th:sh/th color:color withTransform:state->transform];
}

- (void)fillRectX:(float)x y:(float)y w:(float)w h:(float)h {
	[self setTexture:NULL];
	
	EJColorRGBA color = state->fillColor;
	color.rgba.a = (float)color.rgba.a * state->globalAlpha;
	[self pushRectX:x y:y w:w h:h tx:0 ty:0 tw:0 th:0 color:color withTransform:state->transform];
}

- (void)strokeRectX:(float)x y:(float)y w:(float)w h:(float)h {
	// strokeRect should not affect the current path, so we create
	// a new, tempPath instead.
	EJPath * tempPath = [[EJPath alloc] init];
	tempPath.transform = state->transform;
	
	[tempPath moveToX:x y:y];
	[tempPath lineToX:x+w y:y];
	[tempPath lineToX:x+w y:y+h];
	[tempPath lineToX:x y:y+h];
	[tempPath close];
	
	[tempPath drawLinesToContext:self];
	[tempPath release];
}

- (void)clearRectX:(float)x y:(float)y w:(float)w h:(float)h {
	[self setTexture:NULL];
	
	EJCompositeOperation oldOp = state->globalCompositeOperation;
	self.globalCompositeOperation = kEJCompositeOperationDestinationOut;
	
	static EJColorRGBA white = {.hex = 0xffffffff};
	[self pushRectX:x y:y w:w h:h tx:0 ty:0 tw:0 th:0 color:white withTransform:state->transform];
	
	self.globalCompositeOperation = oldOp;
}

- (EJImageData*)getImageDataSx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh {
	[self flushBuffers];
	GLubyte * pixels = malloc( sw * sh * 4 * sizeof(GLubyte));
	glReadPixels(sx, sy, sw, sh, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	return [[[EJImageData alloc] initWithWidth:sw height:sh pixels:pixels] autorelease];
}

- (void)putImageData:(EJImageData*)imageData dx:(float)dx dy:(float)dy {
	EJTexture * texture = imageData.texture;
	[self setTexture:texture];
	
	short tw = texture.realWidth;
	short th = texture.realHeight;
	
	static EJColorRGBA white = {.hex = 0xffffffff};
	
	[self pushRectX:dx y:dy w:tw h:th tx:0 ty:0 tw:1 th:1 color:white withTransform:CGAffineTransformIdentity];
	[self flushBuffers];
}


- (void)setLineTextureForWidth:(float)projectedWidth {

	// Load the line textures if we don't have them already
	if( projectedWidth >= 1 && (!lineTexture16 || !lineTexture4) ) {
		NSString * texturePath16 = [[NSBundle mainBundle] pathForResource:@"line16px" ofType:@"png"];
		lineTexture16 = [[EJTexture alloc] initWithPath:texturePath16];
		
		NSString * texturePath4 = [[NSBundle mainBundle] pathForResource:@"line4px" ofType:@"png"];
		lineTexture4 = [[EJTexture alloc] initWithPath:texturePath4];
	}
	
	if( projectedWidth > 4 ) {
		[self setTexture:lineTexture16];
	}
	else if( projectedWidth >= 1 ) {
		[self setTexture:lineTexture4];
	}
	else {
		// Nothing we can do to make < 1px lines look non-crappy; disable texturing
		[self setTexture:NULL];
	}
}

- (void)beginPath {
	[path reset];
}

- (void)closePath {
	[path close];
}

- (void)fill {	
	[path drawPolygonsToContext:self];
}

- (void)stroke {
	[path drawLinesToContext:self];
}

- (void)moveToX:(float)x y:(float)y {
	[path moveToX:x y:y];
}

- (void)lineToX:(float)x y:(float)y {
	[path lineToX:x y:y];
}

- (void)bezierCurveToCpx1:(float)cpx1 cpy1:(float)cpy1 cpx2:(float)cpx2 cpy2:(float)cpy2 x:(float)x y:(float)y {
	float scale = CGAffineTransformGetScale( state->transform );
	[path bezierCurveToCpx1:cpx1 cpy1:cpy1 cpx2:cpx2 cpy2:cpy2 x:x y:y scale:scale];
}

- (void)quadraticCurveToCpx:(float)cpx cpy:(float)cpy x:(float)x y:(float)y {
	float scale = CGAffineTransformGetScale( state->transform );
	[path quadraticCurveToCpx:cpx cpy:cpy x:x y:y scale:scale];
}

- (void)rectX:(float)x y:(float)y w:(float)w h:(float)h {
	[path moveToX:x y:y];
	[path lineToX:x+w y:y];
	[path lineToX:x+w y:y+h];
	[path lineToX:x y:y+h];
	[path close];
}

- (void)arcToX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 radius:(float)radius {
	[path arcToX1:x1 y1:y1 x2:x2 y2:y2 radius:radius];
}

- (void)arcX:(float)x y:(float)y radius:(float)radius
	startAngle:(float)startAngle endAngle:(float)endAngle
	antiClockwise:(BOOL)antiClockwise
{
	[path arcX:x y:y radius:radius startAngle:startAngle endAngle:endAngle antiClockwise:antiClockwise];
}

- (void)drawText:(NSString *)text x:(float)x y:(float)y fill:(BOOL)fill {
	// TODO: cache the textures somewhere?
	EJTexture * texture = [[[EJTexture alloc] initWithString:text font:state->font fill:fill lineWidth:state->lineWidth contentScale: backingStoreRatio] autorelease];
	float tw = texture.realWidth/backingStoreRatio;
	float th = texture.realHeight/backingStoreRatio;
	
	// Figure out the x position with the current textAlign.
	if( state->textAlign == kEJTextAlignRight || state->textAlign == kEJTextAlignEnd ) {
		x -= texture.width/backingStoreRatio;
	}
	else if( state->textAlign == kEJTextAlignCenter ) {
		x -= texture.width/(2*backingStoreRatio);
	}
	
	// Figure out the y position with the current textBaseline
	switch( state->textBaseline ) {
		case kEJTextBaselineAlphabetic:
		case kEJTextBaselineIdeographic:
			y -= state->font.ascender; break;
			
		case kEJTextBaselineTop:
		case kEJTextBaselineHanging:
			y -= (state->font.ascender - state->font.capHeight); break;
				
		case kEJTextBaselineMiddle:
			y -= (state->font.ascender - state->font.xHeight/2); break;
		
		case kEJTextBaselineBottom:
			y -= (state->font.ascender - state->font.descender); break;
	}
	
	EJColorRGBA color = fill ? state->fillColor : state->strokeColor;
	color.rgba.a = (float)color.rgba.a * state->globalAlpha;
	[self setTexture:texture];
	[self pushRectX:x y:y w:tw h:th tx:0 ty:0 tw:1 th:1 color:color withTransform:state->transform];
	
	// We need to flush buffers now, otherwise the texture may already be autoreleased
	[self flushBuffers];
	[self setTexture:NULL];
}

- (void)fillText:(NSString *)text x:(float)x y:(float)y {
	[self drawText:text x:x y:y fill:YES];
}

- (void)strokeText:(NSString *)text x:(float)x y:(float)y {
	[self drawText:text x:x y:y fill:NO];
}

@end
