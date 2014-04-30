#import <Foundation/Foundation.h>
#import "EJInterceptor.h"


#define BEFORE_RUN_JS_FILE @"beforeRunJSFile"
#define BEFORE_CREATE_IMAGE @"beforeCreateImage"

@interface EJInterceptorManager : NSObject {
	NSMutableDictionary *interceptors;
}

+ (EJInterceptorManager *)instance;

- (void)setInterceptor:(NSString *)name interceptor:(id)interceptor;
- (id)getInterceptor:(NSString *)name;

-(void)interceptData:(NSString *)interceptorName data:(NSMutableData *)data;
-(void)interceptString:(NSString *)interceptorName data:(NSString *)str;


@end
