
#import "EJBindingWebView.h"
#import "AppDelegate.h"
#import "EJConvertColorRGBA.h"

@implementation EJBindingWebView

@synthesize loaded;

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		evalProtocol = @"eval";
        backgroundColor = @"transparent";
		/*
		   {
		   backgroundColor: "transparent",
		   left:
		   top:
		   width:
		   height:
		   src:
		   visible:
		   }
		 */
	}
	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj scriptView:(EJJavaScriptView *)view {
	[super createWithJSObject:obj scriptView:view];

	CGSize screen = scriptView.bounds.size;
	width = screen.width;
	height = screen.height;
	left = 0;
	top =0;
	CGRect webViewBounds=CGRectMake(left,top,width,height);
	webView=[[UIWebView alloc] initWithFrame:webViewBounds];
	webView.delegate=self;
	webView.mediaPlaybackRequiresUserAction=NO;

	webView.opaque=NO;

	webView.backgroundColor=[UIColor clearColor];

	[scriptView addSubview: webView];


}


-(NSString *)evalScriptInWeb:(NSString *)script {
	NSString *result=[webView stringByEvaluatingJavaScriptFromString:script];
	return result;
}

-(JSValueRef)evalScriptInNative:(NSString *)script {

	JSValueRef result=[scriptView evaluateScript:script];

	//  JSGlobalContextRef jsGlobalContext=[scriptView jsGlobalContext];
	//  JSType type=JSValueGetType(jsGlobalContext,result);

	return result;

}

//
//- (void)logException:(JSValueRef)exception ctx:(JSContextRef)ctxp {
//	if( !exception ) return;
//
//	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
//	JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
//
//	JSObjectRef exObject = JSValueToObject( ctxp, exception, NULL );
//	JSValueRef line = JSObjectGetProperty( ctxp, exObject, jsLinePropertyName, NULL );
//	JSValueRef file = JSObjectGetProperty( ctxp, exObject, jsFilePropertyName, NULL );
//
//	NSLog(
//          @"%@ at line %@ in %@",
//          JSValueToNSString( ctxp, exception ),
//          JSValueToNSString( ctxp, line ),
//          JSValueToNSString( ctxp, file )
//          );
//
//	JSStringRelease( jsLinePropertyName );
//	JSStringRelease( jsFilePropertyName );
//}

- (void)loadRequest:(NSURLRequest *)request {
	loaded=NO;
	[webView loadRequest:request];
}

- (BOOL)load:(NSString *)path {

	NSURL* appURL;
	NSString *queryString;
	NSString *fragment;

	if ([path hasPrefix:@"http:"] || [path hasPrefix:@"https:"]) {
		appURL=[NSURL URLWithString:path];
		NSLog(@"webview load remote url : %@",appURL);
	}else{
		appURL = [NSURL URLWithString:path];
		NSString *filePath=[appURL path];

		//TODO
		queryString=[appURL query];
		fragment=[appURL fragment];


		NSString* startFilePath = [scriptView pathForResource: filePath];
		appURL = [NSURL fileURLWithPath:startFilePath];
		NSString *urlString = appURL.absoluteString;
		if(queryString.length) {
			urlString = [[[NSString alloc] initWithFormat:@"%@?%@", urlString, queryString]autorelease];
		}
		if(fragment.length) {
			urlString = [[[NSString alloc] initWithFormat:@"%@#%@", urlString, fragment]autorelease];
		}
		appURL = [NSURL URLWithString:urlString];
		NSLog(@"webview load local url : %@", urlString);
	}

	NSURLRequest *appReq = [NSURLRequest requestWithURL:appURL];

	[webView loadRequest:appReq];
	return YES;
}


-(NSString *) dictionaryToJSONString:(NSDictionary *)dictionary {
	NSError *error;
	NSString *jsonString;

	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];

	if (!jsonData) {
		NSLog(@"Got an error: %@", error);
		jsonString = NULL;
	} else {
		jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
	}
	return jsonString;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	self.loaded = YES;
	[self triggerEvent:@"load"];
}

- (BOOL) webView:(UIWebView*)_webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;

	if ([[url scheme] isEqualToString:evalProtocol]) {

		NSString *script = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		NSLog(@"evalScriptInNative : %@",script);

		[self evalScriptInNative:script];
		return NO;
	} else {
		if ([[url absoluteString] isEqualToString:@"about:blank"]) {
			return NO;
		}
//        NSLog(@"url: %@",[url absoluteURL]);
		return YES;
	}

}



- (void)dealloc {
	// TODO
	[src release];
	[webView release];

	[super dealloc];

}

EJ_BIND_EVENT(load);

EJ_BIND_FUNCTION( eval, ctx, argc, argv ) {
	NSString *script = JSValueToNSString(ctx, argv[0]);

	NSLog(@"evalScriptInWeb : %@", script);
	NSString *result = [self evalScriptInWeb:script];

	JSStringRef _result = JSStringCreateWithUTF8CString( [result UTF8String] );

	return JSValueMakeString(ctx, _result);

}

EJ_BIND_FUNCTION( hide, ctx, argc, argv ) {
	[webView setHidden:YES];
	return NULL;
}
EJ_BIND_FUNCTION( show, ctx, argc, argv ) {
	[webView setHidden:NO];
	return NULL;
}

EJ_BIND_FUNCTION( reload, ctx, argc, argv ) {
	[self load:src];
	return NULL;
}

EJ_BIND_GET(loaded, ctx) {
	return JSValueMakeBoolean(ctx, [self loaded]);
}

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_SET(width, ctx, value) {
	width = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, height);
}

EJ_BIND_SET(height, ctx, value) {
	height = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(left, ctx) {
	return JSValueMakeNumber(ctx, left);
}

EJ_BIND_SET(left, ctx, value) {
	left = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(backgroundColor, ctx) {
    return NSStringToJSValue(ctx, backgroundColor);
}

EJ_BIND_SET(backgroundColor, ctx, value) {
    backgroundColor = JSValueToNSString(ctx, value);
    if ([backgroundColor isEqualToString:@"transparent"] ){
        webView.backgroundColor = [UIColor clearColor];
    }else{
        webView.backgroundColor = JSValueToUIColor(ctx, value);
    }

}


EJ_BIND_GET(evalProtocol, ctx ) {
	JSStringRef _evalProtocol = JSStringCreateWithUTF8CString( [evalProtocol UTF8String] );
	JSValueRef ret = JSValueMakeString(ctx, _evalProtocol);
	JSStringRelease(_evalProtocol);
	return ret;
}
EJ_BIND_SET(evalProtocol, ctx, value) {
	evalProtocol = JSValueToNSString(ctx, value);
}

EJ_BIND_GET(top, ctx) {
	return JSValueMakeNumber(ctx, top);
}

EJ_BIND_SET(top, ctx, value) {
	top = JSValueToNumberFast(ctx, value);
}

EJ_BIND_GET(src, ctx ) {
	JSStringRef _src = JSStringCreateWithUTF8CString( [src UTF8String] );
	JSValueRef ret = JSValueMakeString(ctx, _src);
	JSStringRelease(_src);
	return ret;
}

EJ_BIND_SET(src, ctx, value) {

	NSString *newSrc = JSValueToNSString( ctx, value );

	if ([src isEqualToString:newSrc] ) {
		return;
	}

	// Release the old path
	if( src ) {
		[src release];
	}

	if( [newSrc length] ) {
		src = [newSrc retain];
	}else{
		src = @"about:blank";
	}
	[newSrc release];
	[self load:src];

}


@end