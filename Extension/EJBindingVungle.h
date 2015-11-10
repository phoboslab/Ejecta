#import <VungleSDK/VungleSDK.h>

#import "EJBindingEventedBase.h"


@interface EJBindingVungle : EJBindingEventedBase <VungleSDKDelegate>
{

	NSString *appID;
    VungleSDK* sdk;
    BOOL loading;
    
    JSObjectRef hookBeforeShow;
    JSObjectRef hookAfterClose;
}

@end
