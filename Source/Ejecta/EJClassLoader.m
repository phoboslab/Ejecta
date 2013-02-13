#import "EJClassLoader.h"
#import "EJBindingBase.h"


JSValueRef _EJGlobalUndefined;
static JSClassRef EJGlobalConstructorClass;
static NSMutableDictionary *EJGlobalJSClassCache;


JSValueRef EJGetNativeClass(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception) {
	CFStringRef className = JSStringCopyCFString( kCFAllocatorDefault, propertyNameJS );
	
	JSObjectRef obj = NULL;
	NSString *fullClassName = [@EJ_BINDING_CLASS_PREFIX stringByAppendingString:(NSString *)className];
	Class class = NSClassFromString(fullClassName);
	if( class && [class isSubclassOfClass:EJBindingBase.class] ) {
		obj = JSObjectMake( ctx, EJGlobalConstructorClass, (void *)class );
	}
	
	CFRelease(className);
	return obj ? obj : _EJGlobalUndefined;
}

JSObjectRef EJCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
	Class class = (Class)JSObjectGetPrivate(constructor);	
	EJBindingBase *instance = [(EJBindingBase *)[class alloc] initWithContext:ctx argc:argc argv:argv];
	
	JSObjectRef obj = [class createJSObjectWithContext:ctx instance:instance];
	[instance release];
	return obj;
}


@implementation EJClassLoader

+ (JSClassRef)getJSClass:(id)class {
	NSAssert(EJGlobalJSClassCache != nil, @"Attempt to access class cache without a loader present.");
	
	// Try the cache first
	JSClassRef jsClass = [EJGlobalJSClassCache[class] pointerValue];
	if( jsClass ) {
		return jsClass;
	}
	
	// Still here? Create and insert into cache
	jsClass = [self createJSClass:class];
	EJGlobalJSClassCache[class] = [NSValue valueWithPointer:jsClass];
	return jsClass;
}

+ (JSClassRef)createJSClass:(id)class {
	// Gather all class methods that return C callbacks for this class or it's parents
	NSMutableArray *methods = [[NSMutableArray alloc] init];
	NSMutableArray *properties = [[NSMutableArray alloc] init];
		
	// Traverse this class and all its super classes
	Class base = EJBindingBase.class;
	for( Class sc = class; sc != base && [sc isSubclassOfClass:base]; sc = sc.superclass ) {
	
		// Traverse all class methods for this class; i.e. all classes that are defined with the
		// EJ_BIND_FUNCTION, EJ_BIND_GET or EJ_BIND_SET macros
		u_int count;
		Method *methodList = class_copyMethodList(object_getClass(sc), &count);
		for (int i = 0; i < count ; i++) {
			SEL selector = method_getName(methodList[i]);
			NSString *name = NSStringFromSelector(selector);
			
			if( [name hasPrefix:@"_ptr_to_func_"] ) {
				[methods addObject: [name substringFromIndex:sizeof("_ptr_to_func_")-1] ];
			}
			else if( [name hasPrefix:@"_ptr_to_get_"] ) {
				// We only look for getters - a property that has a setter, but no getter will be ignored
				[properties addObject: [name substringFromIndex:sizeof("_ptr_to_get_")-1] ];
			}
		}
		free(methodList);
	}
	
	
	// Set up the JSStaticValue struct array
	JSStaticValue *values = calloc( properties.count + 1, sizeof(JSStaticValue) );
	for( int i = 0; i < properties.count; i++ ) {
		NSString *name = properties[i];
		
		values[i].name = name.UTF8String;
		values[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL get = NSSelectorFromString([@"_ptr_to_get_" stringByAppendingString:name]);
		values[i].getProperty = (JSObjectGetPropertyCallback)[class performSelector:get];
		
		// Property has a setter? Otherwise mark as read only
		SEL set = NSSelectorFromString([@"_ptr_to_set_"stringByAppendingString:name]);
		if( [class respondsToSelector:set] ) {
			values[i].setProperty = (JSObjectSetPropertyCallback)[class performSelector:set];
		}
		else {
			values[i].attributes |= kJSPropertyAttributeReadOnly;
		}
	}
	
	// Set up the JSStaticFunction struct array
	JSStaticFunction *functions = calloc( methods.count + 1, sizeof(JSStaticFunction) );
	for( int i = 0; i < methods.count; i++ ) {
		NSString *name = methods[i];
				
		functions[i].name = name.UTF8String;
		functions[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL call = NSSelectorFromString([@"_ptr_to_func_" stringByAppendingString:name]);
		functions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[class performSelector:call];
	}
	
	JSClassDefinition classDef = kJSClassDefinitionEmpty;
	classDef.className = class_getName(class) + sizeof(EJ_BINDING_CLASS_PREFIX)-1;
	classDef.finalize = EJBindingBaseFinalize;
	classDef.staticValues = values;
	classDef.staticFunctions = functions;
	JSClassRef jsClass = JSClassCreate(&classDef);
	
	free( values );
	free( functions );
	
	[properties release];
	[methods release];
	
	return jsClass;
}

- (id)initWithGlobalContext:(JSGlobalContextRef)contextp name:(NSString *)name {
	if( self = [super init] ) {
		context = JSGlobalContextRetain(contextp);
		
		// Create or retain the global constructor class
		if( !EJGlobalConstructorClass ) {
			JSClassDefinition constructorClassDef = kJSClassDefinitionEmpty;
			constructorClassDef.callAsConstructor = EJCallAsConstructor;
			EJGlobalConstructorClass = JSClassCreate(&constructorClassDef);
		}
		else {
			JSClassRetain(EJGlobalConstructorClass);
		}
		
		
		// FIXME: Somehow make this per instance!?
		_EJGlobalUndefined = JSValueMakeUndefined(context);
		
		
		// Create the collection class and attach it to the global context with
		// the given name
		JSClassDefinition constructorCollectionClassDef = kJSClassDefinitionEmpty;
		constructorCollectionClassDef.getProperty = EJGetNativeClass;
		JSClassRef constructorCollectionClass = JSClassCreate(&constructorCollectionClassDef);
		
		JSValueProtect(context, _EJGlobalUndefined);
		JSObjectRef global = JSContextGetGlobalObject(context);
		
		JSObjectRef constructorCollection = JSObjectMake(context, constructorCollectionClass, NULL );
		JSStringRef jsName = JSStringCreateWithUTF8CString(name.UTF8String);
		JSObjectSetProperty(
			context, global, jsName, constructorCollection,
			(kJSPropertyAttributeDontDelete | kJSPropertyAttributeReadOnly),
			NULL
		);
		JSStringRelease(jsName);
		
		
		// Create or retain the global Class cache
		if( !EJGlobalJSClassCache ) {
			EJGlobalJSClassCache = [[NSMutableDictionary alloc] initWithCapacity:16];
		}
		else {
			[EJGlobalJSClassCache retain];
		}
	}
	return self;
}

- (void)dealloc {
	// If we are the last Collection to hold on to the Class cache, release it and
	// set it to NULL, so it can be properly re-created if needed.
	if( EJGlobalJSClassCache.retainCount == 1 ) {
		[EJGlobalJSClassCache release];
		EJGlobalJSClassCache = NULL;
	}
	else {
		[EJGlobalJSClassCache release];
	}
	
	JSClassRelease(EJGlobalConstructorClass);
	JSGlobalContextRelease(context);
	[super dealloc];
}


@end

