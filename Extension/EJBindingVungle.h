#import <VungleSDK/VungleSDK.h>

#import "EJBindingAdBase.h"


@interface EJBindingVungle : EJBindingAdBase <VungleSDKDelegate>
{

	NSString *appID;
    VungleSDK* sdk;

}

@end
