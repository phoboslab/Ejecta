#import "EJBindingEventedBase.h"
#import "SocketRocket/SRWebSocket.h"

//Wrap the SocketRocket websocket with a Javascript binding

@interface EJBindingSocketRocket : EJBindingEventedBase <SRWebSocketDelegate>
{
    
}
@end
