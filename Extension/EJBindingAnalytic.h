#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"


@interface EJBindingAnalytic : EJBindingEventedBase
{
	NSString *appKey;
	NSString *appVersion;

	BOOL logEnabled;
	BOOL crashReportEnabled;
}
@end
