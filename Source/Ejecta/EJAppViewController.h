#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EJConvert.h"
#import "EJCanvasContext.h"
#import "EJPresentable.h"
#import "EJGLProgram2D.h"
#import "EJGLProgram2DRadialGradient.h"
#import "EJOpenALManager.h"

#import "EJUtils.h"

#define EJECTA_VERSION @"1.2"
#define EJECTA_APP_FOLDER @"App/"

#define EJECTA_BOOT_JS @"../Ejecta.js"
#define EJECTA_MAIN_JS @"index.js"

@interface EJAppViewController : UIViewController {

}

+ (EJAppViewController *)instance;

@property (nonatomic, assign) BOOL landscapeMode;

@end
