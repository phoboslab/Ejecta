#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJConvert.h"
#import "EJCanvasContext.h"
#import "EJPresentable.h"
#import "EJGLProgram2D.h"
#import "EJGLProgram2DRadialGradient.h"
#import "EJOpenALManager.h"

@interface EJAppViewController : UIViewController {
	BOOL landscapeMode;
}

+ (EJAppViewController *)instance;

@property (nonatomic, assign) BOOL landscapeMode;

@end
