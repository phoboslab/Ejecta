#import <Foundation/Foundation.h>

@class EAGLContext;
@interface EJCanvasContext : NSObject {
	short width, height;
	
	BOOL msaaEnabled;
	BOOL needsPresenting;
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
@property (nonatomic, readonly) EAGLContext *glContext;

@end
