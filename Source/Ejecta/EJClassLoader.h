// The Class loader provides constructors for all EJBinding* subclasses to
// JavaScript and takes care building and instantiating JSClasses and JSObjects.

// EJClassLoader works closely with EJBinding classes. It uses Obj-C reflection
// functions to get a list of all Methods of an Obj-C class. Using a convention
// of prefixes for functions and properties that should be exposed to JS, the
// Class Loader constructs a JSClass for each Obj-C class and hands it to JSC.

// The EJJavaScriptView instantiates the loader with the name "Ejecta". The
// loader creates a global object with that name under which all EJBinding*
// contructors can be accessed.

// The Class Loader is lazy - a JSClass is only ever constructed when an attempt
// is made to access the contructor of that class in JavaScript.

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@class EJJavaScriptView;
@class EJLoadedJSClass;

@interface EJClassLoader : NSObject {
	JSClassRef jsConstructorClass;
	NSMutableDictionary *classCache;
}

- (EJLoadedJSClass *)getJSClass:(id)class;
- (EJLoadedJSClass *)loadJSClass:(id)class;

- (id)initWithScriptView:(EJJavaScriptView *)scriptView name:(NSString *)name;

@property (nonatomic, readonly) JSClassRef jsConstructorClass;

@end



@interface EJLoadedJSClass : NSObject {
	JSClassRef jsClass;
	NSDictionary *constantValues;
}

- (id)initWithJSClass:(JSClassRef)jsClassp constantValues:(NSDictionary *)constantValuesp;
@property (readonly) JSClassRef jsClass;
@property (readonly) NSDictionary *constantValues;
@end
