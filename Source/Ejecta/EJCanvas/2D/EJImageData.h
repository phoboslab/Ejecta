// EJImageData contains the actual pixel data bytes in an NSMutableData.
// Accessing the .texture property will create a texture with those bytes.

#import <Foundation/Foundation.h>
#import "EJTexture.h"

@interface EJImageData : NSObject {
	int width, height;
	NSMutableData *pixels;
}

- (id)initWithWidth:(int)width height:(int)height pixels:(NSMutableData *)pixels;

@property (readonly, nonatomic) EJTexture *texture;
@property (readonly, nonatomic) int width;
@property (readonly, nonatomic) int height;
@property (readonly, nonatomic) NSMutableData *pixels;

@end
