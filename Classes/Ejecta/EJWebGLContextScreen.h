//
//  EJWebGLContext.h
//  EjectaGL
//
//  Created by vikram on 11/24/12.
//
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"

@interface EJWebGLContextScreen : NSObject {
    GLuint viewFrameBuffer, viewRenderBuffer, depthRenderBuffer;
    short width, height;
    GLint bufferWidth, bufferHeight;
    float contentScale;
	EAGLView * glview;
}

- (id)initWithWidth:(short)width height:(short)height contentScale:(float)contentScale;
- (void)create;
- (void)prepare;
- (void)finish;
- (void)present;

@end
