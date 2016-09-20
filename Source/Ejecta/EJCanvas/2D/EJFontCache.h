// EJFontCache is a singleton and can be shared between 2D Contexts. Fonts and
// their atlas textures are cached until the App receives a memory warning.

#import <Foundation/Foundation.h>
#import "EJFont.h"

#define EJ_FONT_CACHE_MAX_CONTENT_SCALE 32

@interface EJFontCache : NSObject {
	NSMutableDictionary *fonts;
}

+ (EJFontCache *)instance;

- (void)clear;
- (EJFont *)fontWithDescriptor:(EJFontDescriptor *)desc contentScale:(float)contentScale;
- (EJFont *)outlineFontWithDescriptor:(EJFontDescriptor *)desc lineWidth:(float)lineWidth contentScale:(float)contentScale;


@end
