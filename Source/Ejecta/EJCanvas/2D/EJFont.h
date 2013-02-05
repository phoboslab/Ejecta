#import "EJTexture.h"

#define EJ_FONT_TEXTURE_SIZE 1024

typedef struct {
	float width;
	float ascent;
	float descent;
} EJTextMetrics;

@interface EJFontDescriptor : NSObject {
	NSString * identFilled;
	NSString * identOutlined;
	NSString * name;
	float size, contentScale;
}
+ (id)descriptorWithName:(NSString *)name size:(float)size;

@property (readonly, nonatomic) NSString * identFilled;
@property (readonly, nonatomic) NSString * identOutlined;
@property (readonly, nonatomic) NSString * name;
@property (readonly, nonatomic) float size;
@end


@class EJCanvasContext2D;

@interface EJFont : NSObject

- (id)initWithDescriptor:(EJFontDescriptor *)desc fill:(BOOL)fill contentScale:(float)contentScale;
+ (void)loadFontAtPath:(NSString *)path;
- (void)drawString:(NSString *)string toContext:(EJCanvasContext2D*)context x:(float)x y:(float)y;
- (EJTextMetrics)measureString:(NSString *)string forContext:(EJCanvasContext2D *)context;

@end
