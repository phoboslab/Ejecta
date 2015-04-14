
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBInPlay.h>
//#import <Chartboost/CBNewsfeed.h>
#import "EJBindingEventedBase.h"



@interface EJBindingChartboost : EJBindingEventedBase <ChartboostDelegate>
{
    NSString *appId;
    NSString *appSignature;
}

@end
