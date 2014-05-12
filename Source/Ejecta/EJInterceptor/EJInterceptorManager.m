#import "EJInterceptorManager.h"
#import "EJInterceptor.h"

@implementation EJInterceptorManager

static EJInterceptorManager *interceptorManager;

+ (EJInterceptorManager *)instance {
	if (!interceptorManager) {
		interceptorManager = [[[EJInterceptorManager alloc] init] autorelease];
	}
	return interceptorManager;
}

- (id)init {
	if (self = [super init]) {
		interceptors = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	interceptorManager = nil;
	[interceptors release];
	[super dealloc];
}

- (void)setInterceptor:(NSString *)name interceptor:(id)interceptor {
	[interceptors setObject:interceptor forKey:name];
}

- (id)getInterceptor:(NSString *)name {
	return [interceptors objectForKey:name];
}

- (void)removeInterceptor:(NSString *)name {
	[interceptors removeObjectForKey:name];
}

- (BOOL)hasInterceptor:(NSString *)name {
	return [self getInterceptor:name] != nil;
}

- (NSArray *)getAllInterceptorNames {
	return [interceptors allKeys];
}

- (void)interceptData:(NSString *)interceptorName data:(NSMutableData *)data {
	id interceptor = [self getInterceptor:interceptorName];
	if (interceptor && [interceptor conformsToProtocol:@protocol(EJInterceptor)]) {
		[interceptor interceptData:data];
	}
}

@end
