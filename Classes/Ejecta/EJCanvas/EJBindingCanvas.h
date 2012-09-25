#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContextTexture.h"
#import "EJCanvasContextScreen.h"
#import "EJTexture.h"
#import "EJDrawable.h"

@interface EJBindingCanvas : EJBindingBase <EJDrawable> {
	EJCanvasContext * renderingContext;
	EJApp * ejectaInstance;
	short width, height;
	
	BOOL isScreenCanvas;
	BOOL useRetinaResolution;
	EJScalingMode scalingMode;
	
	JSValueRef jsValueSourceOver, jsValueDarker, jsValueLighter;
	JSValueRef jsValueLineCapButt, jsValueLineCapSquare, jsValueLineCapRound;
	JSValueRef jsValueLineJoinMiter, jsValueLineJoinBevel, jsValueLineJoinRound;
}
	
@property (readonly, nonatomic) EJTexture * texture;

@end
