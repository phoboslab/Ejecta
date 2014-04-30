
#import "EJInterceptorManager.h"

@implementation EJInterceptorManager

static EJInterceptorManager *interceptorManager;

+ (EJInterceptorManager *)instance {
	if( !interceptorManager ) {
		interceptorManager = [[[EJInterceptorManager alloc] init] autorelease];
	}
    return interceptorManager;
}

- (id)init {
	if( self = [super init] ) {
        interceptors = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	interceptorManager = nil;
	[interceptors release];
	[super dealloc];
}


-(void)setInterceptor:(NSString *)name interceptor:(id)interceptor {
    interceptors[name] = interceptor;
}

-(id)getInterceptor:(NSString *)name {
    return interceptors[name];
}


-(void)interceptData:(NSString *)interceptorName data:(NSMutableData *)data {
    id interceptor=interceptors[interceptorName];
    if( interceptor && [interceptor conformsToProtocol:@protocol(EJInterceptor)] ) {
        [interceptor interceptData:data];
    }
}

-(void)interceptString:(NSString *)interceptorName data:(NSString *)str {
    id interceptor=interceptors[interceptorName];
    if( interceptor && [interceptor conformsToProtocol:@protocol(EJInterceptor)] ) {
        [interceptor interceptString:str];
    }
}


@end
