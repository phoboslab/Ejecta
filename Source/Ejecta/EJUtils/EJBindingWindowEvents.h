// WindowEvents provides the `pagehide`, `pageshow` and `resize` events to
// JavaScript. The event listeners are directly attached to the `window` object
// through the Ejecta.js.

// On instantination, this class installs itself as the WindowEventsDelegate on
// the owning EJScriptView. The EJScriptView detects these events and and just
// hands them down to this class.

#import "EJBindingEventedBase.h"
#import "EJJavaScriptView.h"

@interface EJBindingWindowEvents : EJBindingEventedBase <EJWindowEventsDelegate>

- (void)pause;
- (void)resume;
- (void)resize;
- (void)unload;
- (void)load;
@end
