#import "EJBindingEventedBase.h"

typedef enum {
	kEJHttpRequestTypeString,
	kEJHttpRequestTypeArrayBuffer,
	kEJHttpRequestTypeBlob,
	kEJHttpRequestTypeDocument,
	kEJHttpRequestTypeJSON,
	kEJHttpRequestTypeText
} EJHttpRequestType;

typedef enum {
	kEJHttpRequestStateUnsent = 0,
	kEJHttpRequestStateOpened = 1,
	kEJHttpRequestStateHeadersReceived = 2,
	kEJHttpRequestStateLoading = 3,
	kEJHttpRequestStateDone = 4,
} EJHttpRequestState;

@interface EJBindingHttpRequest : EJBindingEventedBase <NSURLSessionDelegate> {
	EJHttpRequestType type;
	NSString *method;
	NSString *url;
	BOOL async;
	NSString *user;
	NSString *password;
	int timeout;
	NSMutableDictionary *requestHeaders;
	NSStringEncoding defaultEncoding;
	
	EJHttpRequestState state;	
	NSURLSession *session;
	NSURLResponse *response;
	NSMutableData *responseBody;
}

- (void)clearConnection;
- (void)clearRequest;
- (NSString *)getResponseText;

@end
