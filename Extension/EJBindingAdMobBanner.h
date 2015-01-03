#import "EJBindingEventedBase.h"
#import "GADBannerViewDelegate.h"

@class GADBannerView;
@class GADRequest;

typedef enum {
	banner,             // 320x50
	mediumrectangle,    // 300x250
	fullbanner,         // 468x60
	leaderboard,        // 728x90
	skyscraper,         // 120x600
	portrait,           // portraitx32/50/90
	landscape,          // landscapex32/50/90
	invalid             //
} BannerType;

@interface EJBindingAdMobBanner : EJBindingEventedBase <GADBannerViewDelegate>
{
	NSDictionary *sizeType;
	GADBannerView *banner;
	NSString *adUnitID;
	BOOL wantsToShow, isReady;
	short x, y;
    CGFloat width;
    CGFloat height;
}

@property (readwrite, nonatomic) BannerType bannerType;

@end
