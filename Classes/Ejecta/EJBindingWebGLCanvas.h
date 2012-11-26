//
//  EJBindingWebGLCanvas.h
//  EjectaGL
//
//  Created by vikram on 11/24/12.
//
//

#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJWebGLContextScreen.h"

#define EJ_DEFINE_NUMBER_CONST(name, value) \
    EJ_BIND_GET(name, ctx) { \
        return JSValueMakeNumber(ctx, value); \
    }

@interface EJBindingWebGLCanvas : EJBindingBase {
    EJWebGLContextScreen * webGLContext;
    EJApp * ejectaInstance;
	short width, height;
    BOOL useRetinaResolution;
}

@end
