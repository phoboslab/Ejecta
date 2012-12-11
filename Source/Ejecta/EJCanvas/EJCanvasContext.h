#import <Foundation/Foundation.h>

@interface EJCanvasContext : NSObject {
	short width, height;
	
	BOOL msaaEnabled;
	int msaaSamples;
}

- (void)create;
- (void)flushBuffers;
- (void)prepare;

@property (nonatomic) BOOL msaaEnabled;
@property (nonatomic) int msaaSamples;

@end
