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

typedef struct {
	char * name;
	GLenum source;
	GLenum destination;
} EJCompositeOperation;
typedef const EJCompositeOperation * EJCompositeOperationRef;

static const EJCompositeOperation kEJCompositeOperationLighter = {(char*)"lighter", GL_SRC_ALPHA, GL_ONE};
static const EJCompositeOperation kEJCompositeOperationDarker = {(char*)"darker", GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA};
static const EJCompositeOperation kEJCompositeOperationSourceOver = {(char*)"source-over", GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};

typedef struct {
	CGAffineTransform transform;
	EJCompositeOperationRef globalCompositeOperation;
	EJColorRGBA fillColor;
	EJColorRGBA strokeColor;
	float globalAlpha;
	float lineWidth;
	EJLineCap lineCap;
	EJLineJoin lineJoin;
	float miterLimit;
} EJCanvasState;



@interface EJCanvasContext : NSObject {
	GLuint frameBuffer, stencilBuffer;
	
	short width, height;
	short viewportWidth, viewportHeight;
	
	EJTexture * currentTexture;
	EJTexture * lineTexture16;
	EJTexture * lineTexture4;
	
	EJPath * path;
	
	int vertexBufferIndex;
	
	int stateIndex;
	EJCanvasState stateStack[EJ_CANVAS_STATE_STACK_SIZE];
	EJCanvasState * state;
}

- (id)initWithWidth:(short)width height:(short)height;
- (void)create;
- (void)createStencilBufferOnce;
- (void)bindVertexBuffer;
- (void)prepare;
- (void)setTexture:(EJTexture *)newTexture;
- (void)pushTris:(EJTris)tris;
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
- (void)setLineTextureForWidth:(float)projectedWidth;
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


@property (nonatomic) EJCanvasState * state;
@property (nonatomic) EJCompositeOperationRef globalCompositeOperation;

/* TODO: not yet implemented:
	createLinearGradient(x0, y0, x1, y1)
	createRadialGradient(x0, y0, r0, x1, y1, r1)
	createPattern(image, repetition)
	shadowOffsetX
	shadowOffsetY
	shadowBlur
	shadowColor
	clip()
	isPointInPath(x, y)
*/
@end
