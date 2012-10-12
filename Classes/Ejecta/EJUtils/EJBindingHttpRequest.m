#import "EJBindingHttpRequest.h"

@implementation EJBindingHttpRequest

- (id)initWithContext:(JSContextRef)ctxp object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self  = [super initWithContext:ctxp object:obj argc:argc argv:argv] ) {
		requestHeaders = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[requestHeaders release];
	[self clearRequest];
	[self clearConnection];
	
	[super dealloc];
}

- (void)clearConnection {
	[connection cancel];
	[connection release]; connection = NULL;
	[responseBody release]; responseBody = NULL;
	[response release]; response = NULL;
}

- (void)clearRequest {
	[method release]; method = NULL;
	[url release]; url = NULL;
	[user release]; user = NULL;
	[password release]; password = NULL;
}

- (NSString *)getResponseText {
	if( !response || !responseBody ) { return NULL; }
	
	NSStringEncoding encoding = NSASCIIStringEncoding;
	CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef) [response textEncodingName]);
	if( cfEncoding != kCFStringEncodingInvalidId ) {
		encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
	}

	return [[[NSString alloc] initWithData:responseBody encoding:encoding] autorelease];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if( user && password && [challenge previousFailureCount] == 0 ) {
        NSURLCredential * credentials = [NSURLCredential
			credentialWithUser:user
			password:password
			persistence:NSURLCredentialPersistenceNone];
		[[challenge sender] useCredential:credentials forAuthenticationChallenge:challenge];
    }
	else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
		state = kEJHttpRequestStateDone;
		[self triggerEvent:@"abort" argc:0 argv:NULL];
		NSLog(@"XHR: Aborting Request %@ - wrong or no credentials", url);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connectionp {
	state = kEJHttpRequestStateDone;
	
	[connection release]; connection = NULL;
	[self triggerEvent:@"load" argc:0 argv:NULL];
	[self triggerEvent:@"loadend" argc:0 argv:NULL];
	[self triggerEvent:@"readystatechange" argc:0 argv:NULL];
}

- (void)connection:(NSURLConnection *)connectionp didFailWithError:(NSError *)error {
	state = kEJHttpRequestStateDone;
	
	[connection release]; connection = NULL;
	if( error.code == kCFURLErrorTimedOut ) {
		[self triggerEvent:@"timeout" argc:0 argv:NULL];
	}
	else {
		[self triggerEvent:@"error" argc:0 argv:NULL];
	}
	[self triggerEvent:@"loadend" argc:0 argv:NULL];
	[self triggerEvent:@"readystatechange" argc:0 argv:NULL];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)responsep {
	state = kEJHttpRequestStateHeadersReceived;
	
	[response release];
	response = (NSHTTPURLResponse *)[responsep retain];
	[self triggerEvent:@"progress" argc:0 argv:NULL];
	[self triggerEvent:@"readystatechange" argc:0 argv:NULL];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	state = kEJHttpRequestStateLoading;
	
	if( !responseBody ) {
		responseBody = [[NSMutableData alloc] initWithCapacity:1024 * 10]; // 10kb
	}
	[responseBody appendData:data];
	[self triggerEvent:@"progress" argc:0 argv:NULL];
	[self triggerEvent:@"readystatechange" argc:0 argv:NULL];
}



EJ_BIND_FUNCTION(open, ctx, argc, argv) {	
	if( argc < 2 ) { return NULL; }
	
	// Cleanup previous request, if any
	[self clearConnection];
	[self clearRequest];
	
	method = [JSValueToNSString( ctx, argv[0] ) retain];
	url = [JSValueToNSString( ctx, argv[1] ) retain];
	async = argc > 2 ? JSValueToBoolean( ctx, argv[2] ) : true;
	
	if( argc > 4 ) {
		user = [JSValueToNSString( ctx, argv[3] ) retain];
		password = [JSValueToNSString( ctx, argv[4] ) retain];
	}
	
	state = kEJHttpRequestStateOpened;
	return NULL;
}

EJ_BIND_FUNCTION(setRequestHeader, ctx, argc, argv) {
	if( argc < 2 ) { return NULL; }
	
	NSString * header = JSValueToNSString( ctx, argv[0] );
	NSString * value = JSValueToNSString( ctx, argv[1] );
	
	[requestHeaders setObject:value forKey:header];
	return NULL;
}

EJ_BIND_FUNCTION(abort, ctx, argc, argv) {
	if( connection ) {
		[self clearConnection];
		[self triggerEvent:@"abort" argc:0 argv:NULL];
	}
	return NULL;
}

EJ_BIND_FUNCTION(getAllResponseHeaders, ctx, argc, argv) {
	if( !response ) { return NULL; }
	
	NSMutableString * headers = [NSMutableString string];
	for( NSString * key in [response allHeaderFields] ) {
		id value = [[response allHeaderFields] objectForKey:key];
		[headers appendFormat:@"%@: %@\n", key, value];
	}
	
	return NSStringToJSValue(ctx, headers);
}

EJ_BIND_FUNCTION(getResponseHeader, ctx, argc, argv) {
	if( argc < 1 || !response ) { return NULL; }
	
	NSString * header = JSValueToNSString( ctx, argv[0] );
	NSString * value = [[response allHeaderFields] objectForKey:header];
	
	return value ? NSStringToJSValue(ctx, value) : NULL;
}

EJ_BIND_FUNCTION(overrideMimeType, ctx, argc, argv) {
	// TODO?
	return NULL;
}

EJ_BIND_FUNCTION(send, ctx, argc, argv) {
	if( !method || !url ) { return NULL; }
	
	[self clearConnection];
	
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:method];
	
	for( NSString * header in requestHeaders ) {
		[request setValue:[requestHeaders objectForKey:header] forHTTPHeaderField:header];
	}
	
	if( argc > 0 ) {
		NSString * requestBody = JSValueToNSString( ctx, argv[0] );
		NSData * requestData = [NSData dataWithBytes:[requestBody UTF8String] length:[requestBody length]];
		[request setHTTPBody:requestData];
	}
	
	if( timeout ) {
		NSTimeInterval timeoutSeconds = (float)timeout/1000.0f;
		[request setTimeoutInterval:timeoutSeconds];
	}	
	
	NSLog(@"XHR: %@ %@", method, url);
	[self triggerEvent:@"loadstart" argc:0 argv:NULL];
	
	if( async ) {
		state = kEJHttpRequestStateLoading;
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connection setDelegateQueue:[EJApp instance].opQueue];
		[connection start];
	}
	else {	
		NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		responseBody = [[NSMutableData alloc] initWithData:data];
		[response retain];
		
		state = kEJHttpRequestStateDone;
		if( response.statusCode == 200 ) {
			[self triggerEvent:@"load" argc:0 argv:NULL];
		}
		[self triggerEvent:@"loadend" argc:0 argv:NULL];
		[self triggerEvent:@"readystatechange" argc:0 argv:NULL];
	}
	[request release];
	
	return NULL;
}

EJ_BIND_GET(readyState, ctx) {
	return JSValueMakeNumber( ctx, state );
}

EJ_BIND_GET(response, ctx) {
	NSString * responseText = [self getResponseText];
	if( !responseText ) { return NULL; }
	
	if( type == kEJHttpRequestTypeJSON ) {
		JSStringRef jsText = JSStringCreateWithCFString((CFStringRef)responseText);
		JSObjectRef jsonObject = (JSObjectRef)JSValueMakeFromJSONString(ctx, jsText);
		JSStringRelease(jsText);
		return jsonObject;
	}
	else {
		return NSStringToJSValue( ctx, responseText );
	}
}

EJ_BIND_GET(responseText, ctx) {
	NSString * responseText = [self getResponseText];	
	return responseText ? NSStringToJSValue( ctx, responseText ) : NULL;
}

EJ_BIND_GET(status, ctx) {
	return JSValueMakeNumber( ctx, response ? response.statusCode : 0 );
}

EJ_BIND_GET(statusText, ctx) {
	if( !response ) { return NULL; }
	
	// FIXME: should be "200 OK" instead of just "200"
	NSString * code = [NSString stringWithFormat:@"%d", response.statusCode];
	return NSStringToJSValue(ctx, code);
}

EJ_BIND_GET(timeout, ctx) {
	return JSValueMakeNumber( ctx, timeout );
}

EJ_BIND_SET(timeout, ctx, value) {
	timeout = JSValueToNumberFast( ctx, value );
}

EJ_BIND_ENUM(responseType, EJHttpRequestTypeNames, type);

EJ_BIND_GET(UNSENT, ctx) { return JSValueMakeNumber(ctx, kEJHttpRequestStateUnsent); }
EJ_BIND_GET(OPENED, ctx) { return JSValueMakeNumber(ctx, kEJHttpRequestStateOpened); }
EJ_BIND_GET(HEADERS_RECEIVED, ctx) { return JSValueMakeNumber(ctx, kEJHttpRequestStateHeadersReceived); }
EJ_BIND_GET(LOADING, ctx) { return JSValueMakeNumber(ctx, kEJHttpRequestStateLoading); }
EJ_BIND_GET(DONE, ctx) { return JSValueMakeNumber(ctx, kEJHttpRequestStateDone); }

EJ_BIND_EVENT(readystatechange);
EJ_BIND_EVENT(loadend);
EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);
EJ_BIND_EVENT(abort);
EJ_BIND_EVENT(progress);
EJ_BIND_EVENT(loadstart);
EJ_BIND_EVENT(timeout);

@end
