#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"

#import "iAd/iAd.h"


@interface EJBindingAdBanner : EJBindingEventedBase <ADBannerViewDelegate> {
	ADBannerView *banner;
	BOOL isAtBottom, wantsToShow, isReady;
}

@end
