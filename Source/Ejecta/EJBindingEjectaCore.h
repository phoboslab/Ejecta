#import <Foundation/Foundation.h>
#import "EJBindingBase.h"
#import "EJFont.h"

enum {
	kEJCoreAlertViewOpenURL = 1,
	kEJCoreAlertViewGetText
};

@interface EJBindingEjectaCore : EJBindingBase {
	NSString *urlToOpen;
	JSObjectRef getTextCallback;
	NSString *deviceName;
}

@end
