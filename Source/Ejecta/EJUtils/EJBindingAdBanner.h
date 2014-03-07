#import <Foundation/Foundation.h>
#import "iAd/iAd.h"
#import "EJBindingEventedBase.h"


@interface EJBindingAdBanner : EJBindingEventedBase <ADBannerViewDelegate> {
	ADBannerView *banner;
	BOOL isAtBottom, isAtRight, wantsToShow, isReady, alwaysPortrait;
    short x, y;
}

@end
