#import "EJBindingEventedBase.h"

@interface EJBindingLifecycle : EJBindingEventedBase <EJLifecycleDelegate>

- (void)pause;
- (void)resume;

@end
