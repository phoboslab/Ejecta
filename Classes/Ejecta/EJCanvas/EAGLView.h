#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface EAGLView : UIView {
    EAGLContext * context;
}

- (id)initWithFrame:(CGRect)frame contentScale:(float)contentScale;
- (void)resetContext;

@property (nonatomic, retain) EAGLContext *context;

@end
