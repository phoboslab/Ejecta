#import "EJBindingEventedBase.h"
#import "GADBannerViewDelegate.h"

@class GADBannerView;
@class GADRequest;


typedef enum {
	banner,
	mediumrectangle,
	fullbanner,
	leaderboard,
	skyscraper,
	portrait,
	landscape,
	invalid
} BannerType;

@interface EJBindingAdMobBanner : EJBindingEventedBase <GADBannerViewDelegate>
{
	NSDictionary *sizeType;
	GADBannerView *banner;
	NSString *adUnitID;
	BOOL wantsToShow, isReady;
	short x, y;
}

@property (readwrite, nonatomic) BannerType bannerType;

@end
