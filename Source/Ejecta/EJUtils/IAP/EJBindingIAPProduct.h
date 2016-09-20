// An IAPProduct instance represents a single In-App-Purchasable product as
// loaded from ItunesConnect. This class implements various getters to read
// the products title, description and price and provide as method to prompt
// the user to purchase() it.

#import "EJBindingBase.h"
#import <StoreKit/StoreKit.h>

@interface EJBindingIAPProduct : EJBindingBase {
	SKProduct *product;
	JSObjectRef callback;
}

- (id)initWithProduct:(SKProduct *)product;
- (void)finishPurchaseWithTransaction:(SKPaymentTransaction *)transaction;

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	scriptView:(EJJavaScriptView *)view
	product:(SKProduct *)product;

+ (EJBindingIAPProduct *)bindingFromJSValue:(JSValueRef)value;


@end
