#import <Foundation/Foundation.h>

#define AFTER_LOAD_JS @"afterLoadJS"
#define AFTER_LOAD_IMAGE @"afterLoadImage"
#define AFTER_LOAD_AUDIO @"afterLoadAudio"

@interface EJInterceptorManager : NSObject {
	NSMutableDictionary *interceptors;
}

+ (EJInterceptorManager *)instance;

- (void)setInterceptor:(NSString *)name interceptor:(id)interceptor;
- (id)getInterceptor:(NSString *)name;
- (void)removeInterceptor:(NSString *)name;
- (BOOL)hasInterceptor:(NSString *)name;
- (NSArray *)getAllInterceptorNames;


- (void)interceptData:(NSString *)interceptorName data:(NSMutableData *)data;


@end
