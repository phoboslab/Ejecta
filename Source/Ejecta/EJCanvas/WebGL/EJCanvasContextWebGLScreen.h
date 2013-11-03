#import "EJCanvasContextWebGL.h"
#import "EAGLView.h"
#import "EJPresentable.h"

@interface EJCanvasContextWebGLScreen : EJCanvasContextWebGL <EJPresentable> {
	EAGLView *glview;
	CGRect style;
}

- (id)initWithScriptView:(EJJavaScriptView *)scriptViewp width:(short)widthp height:(short)heightp style:(CGRect)stylep;
- (void)present;
- (void)finish;

@property (nonatomic) CGRect style;

@end
