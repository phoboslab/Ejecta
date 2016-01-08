#import <VungleSDK/VungleSDK.h>

#import "EJBindingAdBase.h"


@interface EJBindingVungle : EJBindingAdBase <VungleSDKDelegate>
{

	NSString *appId;
    VungleSDK* sdk;

}

@end
