#import <Foundation/Foundation.h>

@class EAGLContext;
@interface EJCanvasContext : NSObject {
	short width, height;
	
	BOOL msaaEnabled;
	int msaaSamples;
	EAGLContext *glContext;
}

- (void)create;
- (void)flushBuffers;
- (void)prepare;

@property (nonatomic) BOOL msaaEnabled;
@property (nonatomic) int msaaSamples;
@property (nonatomic) short width;
@property (nonatomic) short height;
@property (strong, nonatomic, readonly) EAGLContext *glContext;

@end
