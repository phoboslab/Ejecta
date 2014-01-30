#import "EJBindingLocalStorage.h"



@implementation EJBindingLocalStorage{
    BOOL useiCloud;
    JSObjectRef callback;
}



EJ_BIND_FUNCTION(getItem, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSString *key = JSValueToNSString( ctx, argv[0] );
    NSString *value;
    
    if(!useiCloud)
        value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    else
        value = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];
    
    
	return value ? NSStringToJSValue( ctx, value ) : JSValueMakeNull(ctx);
}

EJ_BIND_FUNCTION(setItem, ctx, argc, argv ) {
	if( argc < 2 ) return NULL;
	
	NSString *key = JSValueToNSString( ctx, argv[0] );
	NSString *value = JSValueToNSString( ctx, argv[1] );
	
	if( !key || !value ) return NULL;
    if(!useiCloud)
    {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUbiquitousKeyValueStore defaultStore] setObject:value forKey:key];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    
	
	return NULL;
}

EJ_BIND_FUNCTION(removeItem, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
	NSString *key = JSValueToNSString( ctx, argv[0] );
    
    if(!useiCloud)
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    else
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:key];
	
	return NULL;
}

EJ_BIND_FUNCTION(clear, ctx, argc, argv ) {
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:@{} forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSDictionary *allValues = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
    
    [allValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:key];
    }];
    
    
	return NULL;
}

EJ_BIND_FUNCTION(useiCloud, ctx, argc, argv){
    
    
    if(
       argc < 1 ||
       !JSValueIsObject(ctx, argv[0])
       ) {
        return NULL;
    }
    
    callback = JSValueToObject(ctx, argv[0], NULL);
    JSValueProtect(ctx, callback);
    
    useiCloud = YES;
    

    NSLog(@"iCloud access ");
    return JSValueMakeBoolean(ctx, YES);
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];      
        
    
}


#pragma mark - Observer

- (void)storeDidChange:(NSNotification *)notification
{
    if( !callback ) {
        NSLog(@"iCloud Error: No Callback");
        return;
    }
    
    NSLog(@"iCloud Callback Set");
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSArray* changedKeys =  [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
    JSGlobalContextRef ctx = scriptView.jsGlobalContext;
    
    for (NSString* key in changedKeys) {
        
        NSString *object = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];
        
        JSValueRef params[] = {NSStringToJSValue( ctx, key ),NSStringToJSValue( ctx, object )};
        [scriptView invokeCallback:callback thisObject:jsObject argc:2 argv:params];
       
    }
    
    

}


@end
