#import <Foundation/Foundation.h>

#define AFTER_LOAD_FILE @"file"
#define AFTER_LOAD_JS @"js"
#define AFTER_LOAD_IMAGE @"image"
#define AFTER_LOAD_AUDIO @"audio"

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
