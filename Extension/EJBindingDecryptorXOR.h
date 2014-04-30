#import "EJBindingBaseInterceptor.h"

//Please Don't change the value of EJ_SECRET_HEADER, unless you understand it.
#define EJ_SECRET_HEADER @"=S="
#define EJ_SECRET_KEY @"SecretKey (Don't include Breakline)"

@interface EJBindingDecryptorXOR : EJBindingBaseInterceptor

@end
