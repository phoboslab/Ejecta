#import "EJBindingBaseInterceptor.h"

@implementation EJBindingBaseInterceptor


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
        
        interceptorManager = [[EJInterceptorManager instance] retain];

		if (argc > 0) {
			name = [JSValueToNSString(ctx, argv[0]) retain];
            if ([interceptorManager hasInterceptor:name]){
                NSLog(@"Error: Duplicate interceptor name: %@",name);
            }
		}
		else {
			NSLog(@"Error: Must set interceptor name.");
		}
	}

	return self;
}


- (void)dealloc {
    [self disable];
	[interceptorManager release];
	[super dealloc];
}

- (void)enable {
    [interceptorManager setInterceptor:name interceptor:self];
}

- (void)disable {
    [interceptorManager removeInterceptor:name];
}


- (void)interceptData:(NSMutableData *)data {
    
    NSLog(@"Please impletment interceptor.interceptData(data) .");
    
}

EJ_BIND_GET(name, ctx)
{
    return NSStringToJSValue(ctx, name);
}

EJ_BIND_FUNCTION(enable, ctx, argc, argv)
{
    [self enable];
	return NULL;
}

EJ_BIND_FUNCTION(disable, ctx, argc, argv)
{
    [self disable];
	return NULL;
}


@end
