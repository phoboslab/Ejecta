#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJInterceptorManager.h"
#import "EJInterceptor.h"

@interface EJBindingBaseInterceptor : EJBindingBase<EJInterceptor> {
	EJInterceptorManager *interceptorManager;
    NSString *name;
}



@end
