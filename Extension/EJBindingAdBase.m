#import "EJBindingAdBase.h"

@implementation EJBindingAdBase


- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		debug = false;
		autoLoad = true;
	}

	return self;
}


- (void)dealloc {
	[super dealloc];
}


-(NSDictionary *)getOptions:(NSString *)type ctx:(JSContextRef)ctx jsOptions:(JSObjectRef)jsOptions {
	
	NSMutableDictionary* options = [[NSMutableDictionary new] autorelease];
	NSDictionary *inOptions = (NSDictionary *)JSValueToNSObject(ctx, jsOptions);

	NSEnumerator *keys = [inOptions keyEnumerator];
	id keyId;
	while ((keyId = [keys nextObject])) {
		NSString *key = (NSString *)keyId;
		NSString *value = (NSString *)[inOptions objectForKey:keyId];
		NSLog(@"key : %@, value: %@", key, value);
		JSStringRef jsKey = JSStringCreateWithUTF8CString([key UTF8String]);
		JSValueRef jsValue = JSObjectGetProperty(ctx, jsOptions, jsKey, NULL);
		
		JSObjectRef jsFunc = JSValueToObject(ctx, jsValue, NULL);
		BOOL isFunc = JSObjectIsFunction(ctx, jsFunc);
		
		if ( isFunc ){
			[self setCallbackWithType:[[type stringByAppendingString:@"_"] stringByAppendingString:key] ctx:ctx callback:jsValue];
		}else {
			[options setObject:value forKey:key];
		}
		
	}
	
	return options;
}


//////////////////////////////////
//////////////////////////////////


EJ_BIND_GET(debug, ctx)
{
	return JSValueMakeBoolean(ctx, debug);
}

EJ_BIND_SET(debug, ctx, value)
{
	debug = JSValueToBoolean(ctx, value);
}

EJ_BIND_GET(autoLoad, ctx)
{
	return JSValueMakeBoolean(ctx, autoLoad);
}


EJ_BIND_SET(autoLoad, ctx, value)
{
	autoLoad = JSValueToBoolean(ctx, value);
}


EJ_BIND_FUNCTION(hasAd, ctx, argc, argv)
{
	if (argc < 1){
		return NULL;
	}
	
	NSString *type = JSValueToNSString(ctx, argv[0]);
	
	NSDictionary* options = nil;
	if (argc > 1){
		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
		options = [self getOptions:type ctx:ctx jsOptions:jsOptions];
	}

	BOOL hasAd = [self callHasAd:type options:options ctx:ctx argc:argc argv:argv];
	
	return JSValueMakeBoolean(ctx, hasAd);
}


EJ_BIND_FUNCTION(isReady, ctx, argc, argv)
{

	if (argc < 1){
		return NULL;
	}
	
	NSString *type = JSValueToNSString(ctx, argv[0]);
	
	NSDictionary* options = nil;
	if (argc > 1){
		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
		options = [self getOptions:type ctx:ctx jsOptions:jsOptions];
	}
	
	BOOL ready = [self callIsReady:type options:options ctx:ctx argc:argc argv:argv];
	
	return JSValueMakeBoolean(ctx, ready);
}


EJ_BIND_FUNCTION(hide, ctx, argc, argv)
{
	if (argc < 1){
		return NULL;
	}
	
	NSString *type = JSValueToNSString(ctx, argv[0]);
	
	NSDictionary* options = nil;
	if (argc > 1){
		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
		options = [self getOptions:type ctx:ctx jsOptions:jsOptions];
	}

	[self callHide:type options:options ctx:ctx argc:argc argv:argv];
	return NULL;
}


EJ_BIND_FUNCTION(show, ctx, argc, argv)
{

	if (argc < 1){
		return NULL;
	}

	NSString *type = JSValueToNSString(ctx, argv[0]);
	NSDictionary* options = nil;

	if (argc > 1){
		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
		options = [self getOptions:type ctx:ctx jsOptions:jsOptions];
	}

	BOOL ok = [self callShow:type options:options ctx:ctx argc:argc argv:argv];

	return ok ? scriptView->jsTrue : scriptView->jsFalse;
}

EJ_BIND_FUNCTION(load, ctx, argc, argv)
{
	if (argc < 1){
		return NULL;
	}
	
	NSString *type = JSValueToNSString(ctx, argv[0]);
	
	NSDictionary* options = nil;
	if (argc > 1){
		JSObjectRef jsOptions = JSValueToObject(ctx, argv[1], NULL);
		options = [self getOptions:type ctx:ctx jsOptions:jsOptions];
	}
	
	[self callLoadAd:type options:options ctx:ctx argc:argc argv:argv];


	return NULL;
}

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);


//////////////////////////////////
//////////////////////////////////


-(BOOL)callShow:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {

	return false;
}


-(BOOL)callLoadAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	return false;
}

-(BOOL)callHasAd:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	return false;
}

-(BOOL)callIsReady:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	
	return false;
}

-(void)callHide:(NSString *)type options:(NSDictionary *)options ctx:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	

}

@end
