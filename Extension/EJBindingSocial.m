#import "EJBindingSocial.h"

@implementation EJBindingSocial


#define InvokeAndUnprotectPostCallback(callback, statusCode, object) \
	JSGlobalContextRef ctx = scriptView.jsGlobalContext; \
	JSValueRef arg = NULL; \
	if (object == NULL) { \
		arg = scriptView->jsNull; \
	} else if ([object isKindOfClass : [NSString class]]) { \
		JSValueRef jsStr =  NSStringToJSValue(ctx, (NSString *)object); \
		arg = JSValueMakeString(ctx, (JSStringRef)jsStr); \
	} else { \
		arg = NSObjectToJSValue(scriptView.jsGlobalContext, object); \
	} \
	[scriptView invokeCallback : callback thisObject : NULL argc : 2 argv : \
					 (JSValueRef[]) { \
	     JSValueMakeNumber(scriptView.jsGlobalContext, statusCode), arg \
	 } \
	]; \
	JSValueUnprotect(scriptView.jsGlobalContext, callback);




- (void)invokeAndUnprotectPostCallback:(JSObjectRef)callback statusCode:(NSInteger)statusCode object:(NSObject *)object {
	JSGlobalContextRef ctx = scriptView.jsGlobalContext;
	JSValueRef arg = scriptView->jsNull;
	if (object == NULL) {
	}
	else if ([object isKindOfClass:[NSString class]]) {
        JSStringRef jsStr = JSStringCreateWithUTF8CString([(NSString *)object UTF8String]);
		arg = JSValueMakeString(ctx, (JSStringRef)jsStr);
	}
	else {
		arg = NSObjectToJSValue(scriptView.jsGlobalContext, object);
	}
	[scriptView invokeCallback:callback thisObject:NULL argc:2 argv:
	 (JSValueRef[]) {
	     JSValueMakeNumber(scriptView.jsGlobalContext, statusCode), arg
	 }
     ];
	JSValueUnprotect(scriptView.jsGlobalContext, callback);
}

- (id)initWithContext:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx argc:argc argv:argv]) {
		_accountStore = [[ACAccountStore alloc] init];
	}
	return self;
}

- (BOOL)addMultipartData:(NSString *)imgSrc request:(SLRequest *)request dataName:(NSString *)dataName {
	NSString *_imgSrc = [NSString stringWithFormat:@"%@%@", [scriptView appFolder], imgSrc];
	UIImage *img = [UIImage imageNamed:_imgSrc];
	if ([_imgSrc hasSuffix:@".png"]) {
		NSData *imageData = UIImagePNGRepresentation(img);
		[request addMultipartData:imageData
		                 withName:dataName
		                     type:@"image/png"
		                 filename:@"image.png"];
	}
	else if ([_imgSrc hasSuffix:@".gif"]) {
		NSData *imageData = UIImagePNGRepresentation(img);
		[request addMultipartData:imageData
		                 withName:dataName
		                     type:@"image/gif"
		                 filename:@"image.gif"];
	}
	else if ([_imgSrc hasSuffix:@".jpg"] || [_imgSrc hasSuffix:@".jpeg"]) {
		NSData *imageData = UIImageJPEGRepresentation(img, 0.9f);
		[request addMultipartData:imageData
		                 withName:dataName
		                     type:@"image/jpeg"
		                 filename:@"image.jpg"];
	}
	else {
		return FALSE;
	}
	return TRUE;
}

- (SLRequest *)createSLRequest:(NSString *)snsName message:(NSString *)message imgSrc:(NSString *)imgSrc {
	SLRequest *request = NULL;
	snsName = [snsName lowercaseString];
	if ([snsName isEqualToString:@"twitter"]) {
		NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
		NSDictionary *params = @{ @"status" : message };
		request = [SLRequest requestForServiceType:SLServiceTypeTwitter
		                             requestMethod:SLRequestMethodPOST
		                                       URL:url
		                                parameters:params];

		if (imgSrc) {
			[self addMultipartData:imgSrc request:request dataName:@"media[]"];
		}
	}
	if ([snsName isEqualToString:@"facebook"]) {
		NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
		NSDictionary *params = @{ @"message" : message };
		request = [SLRequest requestForServiceType:SLServiceTypeTwitter
		                             requestMethod:SLRequestMethodPOST
		                                       URL:url
		                                parameters:params];

		if (imgSrc) {
			[self addMultipartData:imgSrc request:request dataName:@"source"];
		}
	}

	if ([snsName isEqualToString:@"sinaweibo"]) {
		NSURL *url = [NSURL URLWithString:@"http://api.t.sina.com.cn/statuses/upload.json"];

		NSDictionary *params = @{ @"status" : message };
		request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo
		                             requestMethod:SLRequestMethodPOST
		                                       URL:url
		                                parameters:params];
		if (imgSrc) {
			[self addMultipartData:imgSrc request:request dataName:@"pic"];
		}
	}

	return request;
}

- (NSDictionary *)createRequestOption:(NSString *)snsName appKey:(NSString *)appKey{
    NSDictionary *options = NULL ;
    
    if ([snsName isEqualToString:@"facebook"] && appKey!=nil){
        options = @{ ACFacebookAppIdKey: appKey,
                     ACFacebookPermissionsKey: @[@"email", @"publish_stream", @"publish_actions"],
                     ACFacebookAudienceKey: ACFacebookAudienceEveryone
                     };
    }
    
    return options;
}


- (void)post:(NSString *)snsName message:(NSString *)message imgSrc:(NSString *)imgSrc appKey:(NSString *)appKey callback:(JSObjectRef)callback {
	ACAccountType *accountType = NULL;

	snsName = [snsName lowercaseString];
	if ([snsName isEqualToString:@"twitter"]) {
		accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	}
	if ([snsName isEqualToString:@"facebook"]) {
		accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
	}
	if ([snsName isEqualToString:@"sinaweibo"]) {
		accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
	}
	if (!accountType) {
		NSLog(@"No SNS named %@", snsName);
		return;
	}

	SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		NSInteger statusCode = urlResponse.statusCode;
		if (responseData) {
			if (statusCode >= 200 && statusCode < 300) {
				NSDictionary *postResponseData = [NSJSONSerialization JSONObjectWithData:responseData
				                                                                 options:NSJSONReadingMutableContainers
				                                                                   error:NULL];
				NSLog(@"[SUCCESS] %@ Server responded: status code %d", snsName, statusCode);
//				InvokeAndUnprotectPostCallback(callback, statusCode, postResponseData);
				[self invokeAndUnprotectPostCallback:callback statusCode:statusCode object:postResponseData];
			}
			else {
				NSLog(@"[ERROR] %@ Server responded: status code %d %@", snsName, statusCode,
				      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
				NSString *responseText = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

//				InvokeAndUnprotectPostCallback(callback, statusCode, responseText);
				[self invokeAndUnprotectPostCallback:callback statusCode:statusCode object:responseText];
			}
		}
		else {
			NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
			responseData = NULL;
//			InvokeAndUnprotectPostCallback(callback, statusCode, [error localizedDescription]);
			[self invokeAndUnprotectPostCallback:callback statusCode:statusCode object:[error localizedDescription]];
		}
	};

	ACAccountStoreRequestAccessCompletionHandler accountStoreHandler = ^(BOOL granted, NSError *error) {
		if (granted) {
			NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
			if ([accounts count] > 0) {
				SLRequest *request = [self createSLRequest:snsName message:message imgSrc:imgSrc];
				[request setAccount:[accounts lastObject]];
				[request performRequestWithHandler:requestHandler];
			}
			else {
				NSLog(@"Not granted by SNS");
//				InvokeAndUnprotectPostCallback(callback, 0, @"Not granted by SNS");
				[self invokeAndUnprotectPostCallback:callback statusCode:0 object:@"Not granted by SNS"];
			}
		}
		else {
			NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
			      [error localizedDescription]);
//			InvokeAndUnprotectPostCallback(callback, 0, [error localizedDescription]);
			[self invokeAndUnprotectPostCallback:callback statusCode:0 object:[error localizedDescription]];
		}
	};


	NSDictionary *options = [self createRequestOption:snsName appKey:appKey];
    
	[self.accountStore requestAccessToAccountsWithType:accountType
	                                           options:options
	                                        completion:accountStoreHandler];
}

- (void)showPostDialog:(NSString *)snsName message:(NSString *)message url:(NSString *)url imgSrc:(NSString *)imgSrc callback:(JSObjectRef)callback {
	SLComposeViewController *sns = NULL;
	snsName = [snsName lowercaseString];
	if ([snsName isEqualToString:@"twitter"] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		sns = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	}
	if ([snsName isEqualToString:@"facebook"] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		sns = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
	}
	if (([snsName isEqualToString:@"sinaweibo"] || [snsName isEqualToString:@"weibo"]) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
		sns = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
	}
	if ([snsName isEqualToString:@"tencentweibo"] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo]) {
		sns = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTencentWeibo];
	}
	NSLog(@"sns %@", sns);
	if (sns) {
		[sns setInitialText:message];
		if (imgSrc) {
			imgSrc = [NSString stringWithFormat:@"%@%@", [scriptView appFolder], imgSrc];
			UIImage *img = [UIImage imageNamed:imgSrc];
			if (img) {
				bool ok = [sns addImage:img];
				NSLog(@"addImage %d", ok);
			}
		}
		if (url) {
			[sns addURL:[[NSURL alloc] initWithString:url]];
		}

		[sns setCompletionHandler: ^(SLComposeViewControllerResult result) {
		    NSInteger statusCode = 0;
		    switch (result) {
				case SLComposeViewControllerResultDone:
					statusCode = 200;
					NSLog(@"Done");
					break;

				case SLComposeViewControllerResultCancelled:
					statusCode = 0;
					NSLog(@"Cancelled");
					break;

				default:
					statusCode = 500;
					NSLog(@"Other Exception");
					break;
			}
		    [sns dismissViewControllerAnimated:YES completion:nil];
		    NSString *responseText = NULL;
		    InvokeAndUnprotectPostCallback(callback, statusCode, responseText);
		}];

		[scriptView.window.rootViewController presentViewController:sns animated:YES completion: ^{
		}];
	}
}

EJ_BIND_FUNCTION(post, ctx, argc, argv)
{
	if (![SLComposeViewController class]) {
		NSLog(@"This iOS does NOT include Social.framework.");
		return JSValueMakeBoolean(ctx, false);
	}
	NSString *snsName = JSValueToNSString(ctx, argv[0]);
	NSString *message = JSValueToNSString(ctx, argv[1]);
	NSString *imgSrc = JSValueToNSString(ctx, argv[2]);
    NSString *appKey;
    JSObjectRef callback;
    if (argc>4){
        appKey= JSValueToNSString(ctx, argv[3]);
        callback = JSValueToObject(ctx, argv[4], NULL);
    }else{
        appKey = NULL;
        callback = JSValueToObject(ctx, argv[3], NULL);
    }

	if (callback) {
		JSValueProtect(ctx, callback);
	}

	snsName = [snsName lowercaseString];
	[self post:snsName message:message imgSrc:imgSrc appKey:appKey callback:callback];

	return JSValueMakeBoolean(ctx, true);
}

EJ_BIND_FUNCTION(showPostDialog, ctx, argc, argv)
{
	if (![SLComposeViewController class]) {
		NSLog(@"This iOS does NOT include Social.framework.");
		return JSValueMakeBoolean(ctx, false);
	}
	NSString *snsName = JSValueToNSString(ctx, argv[0]);
	NSString *message = JSValueToNSString(ctx, argv[1]);
	NSString *url = JSValueToNSString(ctx, argv[2]);
	NSString *imgSrc = JSValueToNSString(ctx, argv[3]);
	JSObjectRef callback = JSValueToObject(ctx, argv[4], NULL);
	if (callback) {
		JSValueProtect(ctx, callback);
	}

	snsName = [snsName lowercaseString];
	[self showPostDialog:snsName message:message url:url imgSrc:imgSrc callback:callback];

	return JSValueMakeBoolean(ctx, true);
}
@end
