#import "EJBindingEventedBase.h"


@interface EJBindingAdBase : EJBindingEventedBase
{
	BOOL debug;
	BOOL autoLoad;

}

-(NSDictionary *)getOptions:(NSString *)type ctx:(JSContextRef)ctx jsOptions:(JSObjectRef)jsOptions;
-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv;
-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv;
-(BOOL)callHasAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv;
-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv;
-(void)callHide:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv;

@end
