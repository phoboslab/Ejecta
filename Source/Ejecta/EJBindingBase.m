#import "EJBindingBase.h"
#import <objc/runtime.h>


void _ej_class_finalize(JSObjectRef object) {
	id instance = (id)JSObjectGetPrivate(object);
	[instance release];
}

NSData * NSDataFromString( NSString *str ) {
	int len = [str length] + 1;
	NSMutableData * d = [NSMutableData dataWithLength:len];
	strlcpy([d mutableBytes], [str UTF8String], len);
	return d;
}

static NSMutableDictionary * CachedJSClasses;


@implementation EJBindingBase

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self  = [super init] ) {
	}
	return self;
}

+ (JSClassRef)getJSClass {
	id ownClass = [self class];
	
	// Try the cache first
	if( !CachedJSClasses ) {
		CachedJSClasses = [[NSMutableDictionary alloc] initWithCapacity:16];
	}
	
	JSClassRef jsClass = [[CachedJSClasses objectForKey:ownClass] pointerValue];
	if( jsClass ) {
		return jsClass;
	}
	
	// Still here? Create and insert into cache
	jsClass = [self createJSClass];
	[CachedJSClasses setObject:[NSValue valueWithPointer:jsClass] forKey:ownClass];
	return jsClass;
}

+ (JSClassRef)createJSClass {
	// Gather all class methods that return C callbacks for this class or it's parents
	NSMutableArray * methods = [[NSMutableArray alloc] init];
	NSMutableArray * properties = [[NSMutableArray alloc] init];
		
	// Traverse this class and all its super classes
	id base = [EJBindingBase class];
	for( id sc = [self class]; sc != base && [sc isSubclassOfClass:base]; sc = [sc superclass] ) {
	
		// Traverse all class methods for this class; i.e. all classes that are defined with the
		// EJ_BIND_FUNCTION, EJ_BIND_GET or EJ_BIND_SET macros
		u_int count;
		Method * methodList = class_copyMethodList(object_getClass(sc), &count);
		for (int i = 0; i < count ; i++) {
			SEL selector = method_getName(methodList[i]);
			NSString * name = NSStringFromSelector(selector);
			
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
	JSStaticValue * values = calloc( properties.count + 1, sizeof(JSStaticValue) );
	for( int i = 0; i < properties.count; i++ ) {
		NSString * name = [properties objectAtIndex:i];
		NSData * nameData = NSDataFromString( name );
		
		values[i].name = [nameData bytes];
		values[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL get = NSSelectorFromString([NSString stringWithFormat:@"_ptr_to_get_%@", name]);
		values[i].getProperty = (JSObjectGetPropertyCallback)[self performSelector:get];
		
		// Property has a setter? Otherwise mark as read only
		SEL set = NSSelectorFromString([NSString stringWithFormat:@"_ptr_to_set_%@", name]);
		if( [self respondsToSelector:set] ) {
			values[i].setProperty = (JSObjectSetPropertyCallback)[self performSelector:set];
		}
		else {
			values[i].attributes |= kJSPropertyAttributeReadOnly;
		}
	}
	
	// Set up the JSStaticFunction struct array
	JSStaticFunction * functions = calloc( methods.count + 1, sizeof(JSStaticFunction) );
	for( int i = 0; i < methods.count; i++ ) {
		NSString * name = [methods objectAtIndex:i];
		NSData * nameData = NSDataFromString( name );
				
		functions[i].name = [nameData bytes];
		functions[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL call = NSSelectorFromString([NSString stringWithFormat:@"_ptr_to_func_%@", name]);
		functions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[self performSelector:call];
	}
	
	JSClassDefinition classDef = kJSClassDefinitionEmpty;
	classDef.finalize = _ej_class_finalize;
	classDef.staticValues = values;
	classDef.staticFunctions = functions;
	JSClassRef class = JSClassCreate(&classDef);
	
	free( values );
	free( functions );
	
	[properties release];
	[methods release];
	
	return class;
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx instance:(EJBindingBase *)instance {
	JSClassRef jsClass = [self getJSClass];
	
	JSObjectRef obj = JSObjectMake( ctx, jsClass, NULL );
	JSObjectSetPrivate( obj, (void *)instance );
	instance->jsObject = obj;
	
	return obj;
}

@end
