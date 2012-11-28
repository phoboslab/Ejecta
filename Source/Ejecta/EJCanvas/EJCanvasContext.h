#import <Foundation/Foundation.h>
#import "EJTexture.h"
#import "EJImageData.h"
#import "EJPath.h"
#import "EJCanvasTypes.h"

#define EJ_CANVAS_STATE_STACK_SIZE 16
#define EJ_CANVAS_VERTEX_BUFFER_SIZE 2048

extern EJVertex CanvasVertexBuffer[EJ_CANVAS_VERTEX_BUFFER_SIZE];

typedef enum {
	kEJLineCapButt,
	kEJLineCapRound,
	kEJLineCapSquare
} EJLineCap;

typedef enum {
	kEJLineJoinMiter,
	kEJLineJoinBevel,
	kEJLineJoinRound
} EJLineJoin;

typedef enum {
	kEJTextBaselineAlphabetic,
	kEJTextBaselineMiddle,
	kEJTextBaselineTop,
	kEJTextBaselineHanging,
	kEJTextBaselineBottom,
	kEJTextBaselineIdeographic
} EJTextBaseline;

typedef enum {
	kEJTextAlignStart,
	kEJTextAlignEnd,
	kEJTextAlignLeft,
	kEJTextAlignCenter,
	kEJTextAlignRight
} EJTextAlign;

typedef enum {
	kEJCompositeOperationSourceOver,
	kEJCompositeOperationLighter,
	kEJCompositeOperationDarker,
	kEJCompositeOperationDestinationOut,
	kEJCompositeOperationDestinationOver,
	kEJCompositeOperationSourceAtop,
	kEJCompositeOperationXOR
} EJCompositeOperation;

static const struct { GLenum source; GLenum destination; } EJCompositeOperationFuncs[] = {
	[kEJCompositeOperationSourceOver] = {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA},
	[kEJCompositeOperationLighter] = {GL_SRC_ALPHA, GL_ONE},
	[kEJCompositeOperationDarker] = {GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA},
	[kEJCompositeOperationDestinationOut] = {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA},
	[kEJCompositeOperationDestinationOver] = {GL_ONE_MINUS_DST_ALPHA, GL_ONE},
	[kEJCompositeOperationSourceAtop] = {GL_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA},
	[kEJCompositeOperationXOR] = {GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA}
};


typedef struct {
	CGAffineTransform transform;
	
	EJCompositeOperation globalCompositeOperation;
	EJColorRGBA fillColor;
	EJColorRGBA strokeColor;
	float globalAlpha;
	
	float lineWidth;
	EJLineCap lineCap;
	EJLineJoin lineJoin;
	float miterLimit;
	
	EJTextAlign textAlign;
	EJTextBaseline textBaseline;
	UIFont * font;
	
	EJPath * clipPath;
} EJCanvasState;


@interface EJCanvasContext : NSObject {
	GLuint viewFrameBuffer, viewRenderBuffer;
	GLuint msaaFrameBuffer, msaaRenderBuffer;
	GLuint stencilBuffer;
	
	short width, height;
	short viewportWidth, viewportHeight;
	short bufferWidth, bufferHeight;
	
	BOOL imageSmoothingEnabled;
	BOOL msaaEnabled;
	int msaaSamples;
	
	EJTexture * currentTexture;
	
	EJPath * path;
	
	int vertexBufferIndex;
	
	int stateIndex;
	EJCanvasState stateStack[EJ_CANVAS_STATE_STACK_SIZE];
	EJCanvasState * state;
    
	float backingStoreRatio;
	
	NSCache * fontCache;
}

- (id)initWithWidth:(short)width height:(short)height;
- (void)create;
- (void)createStencilBufferOnce;
- (void)bindVertexBuffer;
- (void)prepare;
- (void)setTexture:(EJTexture *)newTexture;
- (void)pushTriX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2
			   x3:(float)x3 y3:(float)y3
			 color:(EJColorRGBA)color
	 withTransform:(CGAffineTransform)transform;
- (void)pushQuadV1:(EJVector2)v1 v2:(EJVector2)v2 v3:(EJVector2)v3 v4:(EJVector2)v4
	t1:(EJVector2)t1 t2:(EJVector2)t2 t3:(EJVector2)t3 t4:(EJVector2)t4
	color:(EJColorRGBA)color
	withTransform:(CGAffineTransform)transform;
- (void)pushRectX:(float)x y:(float)y w:(float)w h:(float)h
	tx:(float)tx ty:(float)ty tw:(float)tw th:(float)th
	color:(EJColorRGBA)color
	withTransform:(CGAffineTransform)transform;
- (void)flushBuffers;

- (void)save;
- (void)restore;
- (void)rotate:(float)angle;
- (void)translateX:(float)x y:(float)y;
- (void)scaleX:(float)x y:(float)y;
- (void)transformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m2 dx:(float)dx dy:(float)dy;
- (void)setTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m2 dx:(float)dx dy:(float)dy;
- (void)drawImage:(EJTexture *)image sx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh dx:(float)dx dy:(float)dy dw:(float)dw dh:(float)dh;
- (void)fillRectX:(float)x y:(float)y w:(float)w h:(float)h;
- (void)strokeRectX:(float)x y:(float)y w:(float)w h:(float)h;
- (void)clearRectX:(float)x y:(float)y w:(float)w h:(float)h;
- (EJImageData*)getImageDataSx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh;
- (void)putImageData:(EJImageData*)imageData dx:(float)dx dy:(float)dy;
- (void)beginPath;
- (void)closePath;
- (void)fill;
- (void)stroke;
- (void)moveToX:(float)x y:(float)y;
- (void)lineToX:(float)x y:(float)y;
- (void)rectX:(float)x y:(float)y w:(float)w h:(float)h;
- (void)bezierCurveToCpx1:(float)cpx1 cpy1:(float)cpy1 cpx2:(float)cpx2 cpy2:(float)cpy2 x:(float)x y:(float)y;
- (void)quadraticCurveToCpx:(float)cpx cpy:(float)cpy x:(float)x y:(float)y;
- (void)arcToX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 radius:(float)radius;
- (void)arcX:(float)x y:(float)y radius:(float)radius startAngle:(float)startAngle endAngle:(float)endAngle antiClockwise:(BOOL)antiClockwise;

- (void)fillText:(NSString *)text x:(float)x y:(float)y;
- (void)strokeText:(NSString *)text x:(float)x y:(float)y;
- (float)measureText:(NSString *)text;

- (void)clip;
- (void)resetClip;

@property (nonatomic) EJCanvasState * state;
@property (nonatomic) EJCompositeOperation globalCompositeOperation;
@property (nonatomic, retain) UIFont * font;
@property (nonatomic, assign) float backingStoreRatio;
@property (nonatomic) BOOL msaaEnabled;
@property (nonatomic) int msaaSamples;
@property (nonatomic) BOOL imageSmoothingEnabled;

/* TODO: not yet implemented:
	createLinearGradient(x0, y0, x1, y1)
	createRadialGradient(x0, y0, r0, x1, y1, r1)
	createPattern(image, repetition)
	shadowOffsetX
	shadowOffsetY
	shadowBlur
	shadowColor
	isPointInPath(x, y)
*/
@end
