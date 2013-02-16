#import <Foundation/Foundation.h>

@interface EJSharedTextureCache : NSObject {
	NSMutableDictionary *textures;
}

+ (EJSharedTextureCache *)instance;

@property (nonatomic, readonly) NSMutableDictionary *textures;

@end