#import "EJBindingEventedBase.h"
#import "EJJavaScriptView.h"

@interface EJBindingLifecycle : EJBindingEventedBase <EJLifecycleDelegate>

- (void)pause;
- (void)resume;

@end
