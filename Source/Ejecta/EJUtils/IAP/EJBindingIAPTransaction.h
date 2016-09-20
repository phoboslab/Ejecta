// An IAPTransaction is the result of a purchase and returned by either
// purchase()ing a product or restoring all purchases through the IAPManager. 

#import "EJBindingBase.h"
#import <StoreKit/StoreKit.h>

@interface EJBindingIAPTransaction : EJBindingBase {
	SKPaymentTransaction *transaction;
}

- (id)initWithTransaction:(SKPaymentTransaction *)transaction;

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)view
	transaction:(SKPaymentTransaction *)transaction;

@end
