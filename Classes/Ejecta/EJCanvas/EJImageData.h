#import <Foundation/Foundation.h>
#import "EJTexture.h"

@interface EJImageData : NSObject {
	int width, height;
	GLubyte * pixels;
}

- (id)initWithWidth:(int)width height:(int)height pixels:(GLubyte *)pixels;

@property (readonly, nonatomic) EJTexture * texture;
@property (readonly, nonatomic) int width;
@property (readonly, nonatomic) int height;
@property (readonly, nonatomic) GLubyte * pixels;

@end
