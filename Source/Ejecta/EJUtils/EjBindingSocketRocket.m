#import "EjBindingSocketRocket.h"

@implementation EJBindingSocketRocket
{
    SRWebSocket *_webSocket;
}

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {

    self = [super initWithContext:ctx argc:argc argv:argv];
    _webSocket = nil;
	return self;
}

- (void)dealloc {
    
    [self _close];
	[super dealloc];
}

- (void)_close {
    
    if(_webSocket != nil)
    {
        _webSocket.delegate = nil;
        [_webSocket close];
        [_webSocket release];
        _webSocket = nil;
    }
}

- (void)_connect:(NSString *)url;
{
    [self _close];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    _webSocket.delegate = self;
   [_webSocket open];
}

- (void)_send:(NSString *)message;
{
    if(_webSocket != nil)
        [_webSocket send:message];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    [self triggerEvent:@"connect" argc:0 argv:NULL];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"webSocket: Failed. Error: %d - %@", error.code, error.localizedDescription);
    [self _close];
    [self triggerEvent:@"error" argc:0 argv:NULL];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    //Package the message string to send to client
    JSContextRef ctx = scriptView.jsGlobalContext;
    NSString *msgString = message;
    JSStringRef jss = JSStringCreateWithUTF8CString(msgString.UTF8String);
	JSValueRef ret = JSValueMakeString(ctx, jss);
	JSStringRelease(jss);
    
    [self triggerEvent:@"message" argc:1 argv:(JSValueRef[]){ ret }];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    [self _close];
    
    //send the reason string with the closed event
    JSContextRef ctx = scriptView.jsGlobalContext;
    JSStringRef jss = JSStringCreateWithUTF8CString(reason.UTF8String);
	JSValueRef ret = JSValueMakeString(ctx, jss);
	JSStringRelease(jss);
    
    [self triggerEvent:@"closed" argc:1 argv:(JSValueRef[]){ ret }];
}

EJ_BIND_FUNCTION(connect, ctx, argc, argv )
{
	if( argc < 1 ) return NULL;
	
	NSString *url = JSValueToNSString( ctx, argv[0] );
	
    if( !url ) return NULL;
	
    [self _connect:url];
    
	return NULL;
}

EJ_BIND_FUNCTION(send, ctx, argc, argv )
{
	if( argc < 1 ) return NULL;
	
	NSString *to_send = JSValueToNSString( ctx, argv[0] );
	
    if( !to_send ) return NULL;
	
    [_webSocket send:to_send];
    
	return NULL;
}

EJ_BIND_EVENT(connect);
EJ_BIND_EVENT(message);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(closed);

@end
