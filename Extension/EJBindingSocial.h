#import "EJBindingBase.h"
#import <Social/Social.h>
#import <Accounts/ACAccount.h>
#import <Accounts/Accounts.h>


#define EJECTA_SYSTEM_VERSION_LESS_THAN(v) \
([UIDevice.currentDevice.systemVersion compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface EJBindingSocial : EJBindingBase <UITextViewDelegate>
{
	UITextView *sharingTextView;
}
@property (nonatomic, strong) ACAccountStore *accountStore;
@end
