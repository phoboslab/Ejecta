#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJCanvasContext2D.h"

@interface EJBindingCanvasContext2D : EJBindingBase {
	EJCanvasContext2D * renderingContext;
	EJApp * ejectaInstance;
}

@end
