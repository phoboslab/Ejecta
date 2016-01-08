
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBInPlay.h>
//#import <Chartboost/CBNewsfeed.h>
#import "EJBindingAdBase.h"



@interface EJBindingChartboost : EJBindingAdBase <ChartboostDelegate>
{
    NSString *appId;
    NSString *appSignature;

}

@end
