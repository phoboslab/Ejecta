#import "EJCanvasContext2D.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@interface EJCanvasContext2DScreen : EJCanvasContext2D <EJPresentable> {
	EAGLView *glview;
	CGRect style;
}

- (id)initWithScriptView:(EJJavaScriptView *)scriptViewp width:(short)widthp height:(short)heightp style:(CGRect)stylep;
- (void)present;
- (void)finish;

@property (nonatomic) CGRect style;
@property (readonly, nonatomic) EJTexture *texture;

@end
