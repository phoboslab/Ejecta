// This class exposes WebSockets to JavaScript. It's a wrapper around the
// excellent SocketRocket library, whose API is closely modeled after the w3c JS
// API. So this wrapper is pretty thin.


#import "EJBindingEventedBase.h"
#import "SRWebSocket.h"

typedef enum {
	kEJWebSocketBinaryTypeBlob,
	kEJWebSocketBinaryTypeArrayBuffer
} EJWebSocketBinaryType;

typedef enum {
	kEJWebSocketReadyStateConnecting = 0,
	kEJWebSocketReadyStateOpen = 1,
	kEJWebSocketReadyStateClosing = 2,
	kEJWebSocketReadyStateClosed = 3
} EJWebSocketReadyState;

@interface EJBindingWebSocket : EJBindingEventedBase <SRWebSocketDelegate> {
	EJWebSocketBinaryType binaryType;
	EJWebSocketReadyState readyState;
	NSString *url;
	SRWebSocket *socket;
}

@end
