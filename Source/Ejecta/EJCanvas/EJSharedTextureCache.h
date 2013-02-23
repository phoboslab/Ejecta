#import <Foundation/Foundation.h>

@interface EJSharedTextureCache : NSObject {
	NSMutableDictionary *textures;
	NSMutableData *premultiplyTable;
	NSMutableData *unPremultiplyTable;
}

+ (EJSharedTextureCache *)instance;

@property (nonatomic, readonly) NSMutableDictionary *textures;
@property (nonatomic, readonly) NSData *premultiplyTable;
@property (nonatomic, readonly) NSData *unPremultiplyTable;

@end