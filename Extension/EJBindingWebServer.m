#import "EJBindingWebServer.h"
#import <arpa/inet.h>
#import <netdb.h>
//#import <netinet/in.h>

@implementation EJBindingWebServer


- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctxp argc:argc argv:argv]) {
	}
	return self;
}

// Return the localized IP address - From Erica Sadun's cookbook
- (NSString *)localIPAddress {
	char baseHostName[255];
	gethostname(baseHostName, 255);

	// Adjust for iPhone -- add .local to the host name
	char hn[255];
	sprintf(hn, "%s.local", baseHostName);

	struct hostent *host = gethostbyname(hn);
	if (host == NULL) {
		herror("resolv");
		return NULL;
	}
	else {
		struct in_addr **list = (struct in_addr **)host->h_addr_list;
		return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
	}

	return NULL;
}

- (void)stop {
	mg_destroy_server(&server);
}

static int ev_handler(struct mg_connection *conn, enum mg_event ev) {
	int result = MG_FALSE;

	if (ev == MG_REQUEST) {
		mg_printf_data(conn, "Hello! Requested URI is [%s]", conn->uri);
		result = MG_TRUE;
	}
	else if (ev == MG_AUTH) {
		result = MG_TRUE;
	}

	return result;
}

EJ_BIND_FUNCTION(start, ctx, argc, argv)
{
	NSString *port = nil;
	if (argc < 1) {
		port = @"80";
	}
	else {
		port = JSValueToNSString(ctx, argv[0]);
	}

	server = mg_create_server(NULL, ev_handler);
	mg_set_option(server, "listening_port", [port cStringUsingEncoding:NSUTF8StringEncoding]);

	NSLog(@"Mongoose Server is running on http://%@:8080", [self localIPAddress]);

	for (;; ) {
		mg_poll_server(server, 1000);
	}
	return NULL;
}


EJ_BIND_FUNCTION(stop, ctx, argc, argv)
{
	[self stop];
	return NULL;
}

@end
