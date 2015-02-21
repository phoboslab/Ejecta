#import "EJBindingBase.h"
#import <Social/Social.h>
#import <Accounts/ACAccount.h>
#import <Accounts/Accounts.h>

@interface EJBindingSocial : EJBindingBase <UITextViewDelegate>
{
	UITextView *sharingTextView;
}
@property (nonatomic, strong) ACAccountStore *accountStore;
@end
