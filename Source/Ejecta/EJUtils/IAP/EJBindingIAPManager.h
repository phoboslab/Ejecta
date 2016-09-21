// This class provides a sensible API for the convoluted StoreKit that Apple
// provides for In-App-Purchases.

// Using the IAPManager, you can restore previous transactions or load certain
// produts that you set up in ItunesConnect.

#import "EJBindingBase.h"
#import <StoreKit/StoreKit.h>

@interface EJBindingIAPManager : EJBindingBase <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	NSMutableDictionary *productRequestCallbacks;
	NSMutableDictionary *products;
	
	JSObjectRef restoreCallback;
	NSMutableArray *restoredTransactions;
}
@end
