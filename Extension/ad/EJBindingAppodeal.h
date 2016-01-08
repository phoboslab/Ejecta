#import<Appodeal/Appodeal.h>

#import "EJBindingBase.h"


@interface EJBindingAppodeal : EJBindingBase <AppodealInterstitialDelegate, AppodealBannerDelegate, AppodealVideoDelegate, AppodealRewardedVideoDelegate>
{

	NSString *appKey;
    NSDictionary *adStyle;

    BOOL loading;
    
    JSObjectRef hookBeforeShow;
    JSObjectRef hookAfterClose;
    JSObjectRef hookAfterClick;
    JSObjectRef hookAfterFinish;
}

@end
