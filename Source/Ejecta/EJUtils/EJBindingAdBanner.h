#if !TARGET_OS_TV

#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"

#import "iAd/iAd.h"


@interface EJBindingAdBanner : EJBindingEventedBase <ADBannerViewDelegate> {
	ADBannerView *banner;
	BOOL wantsToShow, isReady;
	BOOL isAtBottom, isAtRight, alwaysPortrait;
	short x, y;
	BOOL isRectangle;
	NSString *type;
}

@end
#endif
