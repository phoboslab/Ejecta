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
    GLuint viewFrameBuffer, viewRenderBuffer;
    short width, height;
	EAGLView * glview;
	BOOL useRetinaResolution;
}

- (id)initWithWidth:(short)width height:(short)height;
- (void)create;
- (void)finish;
- (void)present;

@property (nonatomic) BOOL useRetinaResolution;

@end
