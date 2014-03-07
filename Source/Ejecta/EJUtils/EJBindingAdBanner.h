#import <Foundation/Foundation.h>
#import "iAd/iAd.h"
#import "EJBindingEventedBase.h"


@interface EJBindingAdBanner : EJBindingEventedBase <ADBannerViewDelegate> {
	ADBannerView *banner;
	BOOL wantsToShow, isReady;
	BOOL isAtBottom, isAtRight, alwaysPortrait;
	short x, y;
	BOOL isRectangle;
	NSString *type;
}

@end
