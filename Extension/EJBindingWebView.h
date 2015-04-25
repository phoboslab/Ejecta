
#import <UIKit/UIKit.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJBindingEventedBase.h"


@interface EJBindingWebView : EJBindingEventedBase <UIWebViewDelegate>  {

	short width, height;
	short left, top;
	BOOL loading;
	NSString *src;
    NSString *backgroundColor;
	NSString *evalProtocol;
	UIWebView *webView;

}

@property (nonatomic,assign) BOOL loaded;

- (BOOL)load:(NSString *)path;
- (NSString *)evalScriptInWeb:(NSString *)script;
- (JSValueRef)evalScriptInNative:(NSString *)script;
- (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary;

@end