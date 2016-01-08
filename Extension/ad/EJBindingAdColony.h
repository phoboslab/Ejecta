#import <AdColony/AdColony.h>

#import "EJBindingAdBase.h"


@interface EJBindingAdColony : EJBindingAdBase <AdColonyDelegate, AdColonyAdDelegate>
{

	NSString *appId;
	NSArray<NSString *> *zones;
	NSMutableDictionary *availabilityState;

}

@end
