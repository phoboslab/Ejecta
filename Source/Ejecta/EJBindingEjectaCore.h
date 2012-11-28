#import <Foundation/Foundation.h>
#import "EJBindingBase.h"

enum {
	kEJCoreAlertViewOpenURL = 1,
	kEJCoreAlertViewGetText
};

@interface EJBindingEjectaCore : EJBindingBase {
	NSString * urlToOpen;
	JSObjectRef getTextCallback;
}

@end
