#import "EJBindingLocalStorage.h"


@implementation EJBindingLocalStorage

EJ_BIND_FUNCTION(getItem, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSString * key = JSValueToNSString( ctx, argv[0] );
	NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	return value ? NSStringToJSValue( ctx, value ) : NULL;
}

EJ_BIND_FUNCTION(setItem, ctx, argc, argv ) {
	if( argc < 2 ) return NULL;
	
	NSString * key = JSValueToNSString( ctx, argv[0] );
	NSString * value = JSValueToNSString( ctx, argv[1] );
	
	if( !key || !value ) return NULL;
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return NULL;
}

EJ_BIND_FUNCTION(removeItem, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSString * key = JSValueToNSString( ctx, argv[0] );
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	
	return NULL;
}

EJ_BIND_FUNCTION(clear, ctx, argc, argv ) {
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
	return NULL;
}


@end
