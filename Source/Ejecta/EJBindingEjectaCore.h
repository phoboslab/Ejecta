#import <Foundation/Foundation.h>
#import "EJBindingEventedBase.h"
#import "EJFont.h"

enum {
	kEJCoreAlertViewOpenURL = 1,
	kEJCoreAlertViewGetText
};

@interface EJBindingEjectaCore : EJBindingEventedBase {
	NSString *urlToOpen;
	JSObjectRef getTextCallback;
	NSString *deviceName;
}

@end
