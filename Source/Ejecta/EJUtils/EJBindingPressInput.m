#import "EJBindingPressInput.h"

@implementation EJBindingPressInput

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
    [super createWithJSObject:obj scriptView:view];
    
    JSContextRef ctx = scriptView.jsGlobalContext;
    
    // Create the JavaScript arrays that will be passed to the callback
    jsPresses = JSObjectMakeArray(ctx, 0, NULL, NULL);
    JSValueProtect(ctx, jsPresses);
    
    // Create some JSStrings for property access
    jsLengthName = JSStringCreateWithUTF8CString("length");
    jsPressTypeName = JSStringCreateWithUTF8CString("type");
    
    scriptView.pressDelegate = self;
}

- (void)dealloc {
    JSContextRef ctx = scriptView.jsGlobalContext;
    
    JSValueUnprotectSafe( ctx, jsPresses );
    JSStringRelease( jsLengthName );
    JSStringRelease( jsPressTypeName );

    
    for( int i = 0; i < pressesInPool; i++ ) {
        JSValueUnprotectSafe( ctx, jsPressesPool[i] );
    }
    
    [super dealloc];
}

- (void)triggerEvent:(NSString *)name presses:(NSSet *)presses {
    JSContextRef ctx = scriptView.jsGlobalContext;
    
    NSUInteger count = presses.count;
    
    JSObjectSetProperty(ctx, jsPresses, jsLengthName, JSValueMakeNumber(ctx, count), kJSPropertyAttributeNone, NULL);
    
    // More touches than we have in our pool? Create some!
    if( pressesInPool < count ) {
        for( NSUInteger i = pressesInPool; i < count; i++ ) {
            jsPressesPool[i] = JSObjectMake( ctx, NULL, NULL );
            JSValueProtect( ctx, jsPressesPool[i] );
        }
        pressesInPool = count;
    }
    
    int poolIndex = 0;
    
    for( UIPress *press in presses ) {
        JSValueRef pressType = JSValueMakeNumber(ctx, press.type);
        
        JSObjectRef jsPress = jsPressesPool[poolIndex];
        JSObjectSetProperty( ctx, jsPress, jsPressTypeName, pressType, kJSPropertyAttributeNone, NULL );
        
        JSObjectSetPropertyAtIndex(ctx, jsPresses, poolIndex, jsPress, NULL);
        
        poolIndex++;
        
        if( poolIndex >= pressesInPool ) { break; }
    }
    
    [self triggerEvent:name argc:1 argv:(JSValueRef[]){ jsPresses }];
}

EJ_BIND_EVENT(pressstart);
EJ_BIND_EVENT(pressend);

@end
