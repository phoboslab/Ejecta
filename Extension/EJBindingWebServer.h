#import "JavaScriptCore/JavaScriptCore.h"
#import "EJBindingBase.h"
#import "mongoose.h"
#import <UIKit/UIKit.h>

@interface EJBindingWebServer : EJBindingBase
{
    struct mg_server *server;
}

@end


