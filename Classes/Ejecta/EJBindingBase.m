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


@implementation EJBindingBase

- (id)initWithContext:(JSContextRef)ctxp object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self  = [super init] ) {
		jsObject = obj;
	}
	return self;
}

+ (JSClassRef)getJSClass {
	// Gather all class methods that return C callbacks for this class or it's parents
	NSMutableArray * methods = [[NSMutableArray alloc] init];
	NSMutableArray * properties = [[NSMutableArray alloc] init];
		
	// Traverse this class and all its super classes
	id base = [EJBindingBase class];
	for( id sc = [self class]; sc != base && [sc isSubclassOfClass:base]; sc = [sc superclass] ) {
	
		// Traverse all class methods for this class; i.e. all classes that are defined with the
		// EJ_BIND_FUNCTION, EJ_BIND_GET or EJ_BIND_SET macros
		u_int count;
		Method * methodList = class_copyMethodList(sc, &count);
		for (int i = 0; i < count ; i++) {
			SEL selector = method_getName(methodList[i]);
			NSString * name = NSStringFromSelector(selector);
			
			if( [name hasPrefix:@"_func_"] ) {
				NSString * shortName = [[[name componentsSeparatedByString:@":"] objectAtIndex:0] 
					substringFromIndex:sizeof("_func_")-1];
				[methods addObject:shortName];
			}
			else if( [name hasPrefix:@"_get_"] ) {
				// We only look for getters - a property that has a setter, but no getter will be ignored
				NSString * shortName = [[[name componentsSeparatedByString:@":"] objectAtIndex:0] 
					substringFromIndex:sizeof("_get_")-1];
				[properties addObject:shortName];
			}
		}
		free(methodList);
	}
	
	
	// Set up the JSStaticValue struct array
	JSStaticValue * values = malloc( sizeof(JSStaticValue) * (properties.count+1) );
	memset( values, 0, sizeof(JSStaticValue) * (properties.count+1) );
	for( int i = 0; i < properties.count; i++ ) {
		NSString * name = [properties objectAtIndex:i];
		NSData * nameData = NSDataFromString( name );
		
		values[i].name = [nameData bytes];
		values[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL get = NSSelectorFromString([NSString stringWithFormat:@"_callback_for_get_%@", name]);
		values[i].getProperty = (JSObjectGetPropertyCallback)[self performSelector:get];
		
		SEL set = NSSelectorFromString([NSString stringWithFormat:@"_callback_for_set_%@", name]);
		
		// Property has a setter? Otherwise mark as read only
		if( [self respondsToSelector:set] ) {
			values[i].setProperty = (JSObjectSetPropertyCallback)[self performSelector:set];
		}
		else {
			values[i].attributes |= kJSPropertyAttributeReadOnly;
		}
	}
	
	// Set up the JSStaticFunction struct array
	JSStaticFunction * functions = malloc( sizeof(JSStaticFunction) * (methods.count+1) );
	memset( functions, 0, sizeof(JSStaticFunction) * (methods.count+1) );
	for( int i = 0; i < methods.count; i++ ) {
		NSString * name = [methods objectAtIndex:i];
		NSData * nameData = NSDataFromString( name );
				
		functions[i].name = [nameData bytes];
		functions[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL call = NSSelectorFromString([NSString stringWithFormat:@"_callback_for_func_%@", name]);
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

@end
