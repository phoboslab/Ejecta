#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

/*!
@enum JSType
@abstract     A constant identifying the Typed Array type of a JSValue.
@constant     kJSTypedArrayTypeNone                 Not a Typed Array.
@constant     kJSTypedArrayTypeInt8Array            Int8Array
@constant     kJSTypedArrayTypeInt16Array           Int16Array
@constant     kJSTypedArrayTypeInt32Array           Int32Array
@constant     kJSTypedArrayTypeUint8Array           Int8Array
@constant     kJSTypedArrayTypeUint8ClampedArray    Int8ClampedArray
@constant     kJSTypedArrayTypeUint16Array          Uint16Array
@constant     kJSTypedArrayTypeUint32Array          Uint32Array
@constant     kJSTypedArrayTypeFloat32Array         Float32Array
@constant     kJSTypedArrayTypeFloat64Array         Float64Array
@constant     kJSTypedArrayTypeArrayBuffer          ArrayBuffer
*/
typedef enum {
	kJSTypedArrayTypeNone = 0,
	kJSTypedArrayTypeInt8Array = 1,
	kJSTypedArrayTypeInt16Array = 2,
	kJSTypedArrayTypeInt32Array = 3,
	kJSTypedArrayTypeUint8Array = 4,
	kJSTypedArrayTypeUint8ClampedArray = 5,
	kJSTypedArrayTypeUint16Array = 6,
	kJSTypedArrayTypeUint32Array = 7,
	kJSTypedArrayTypeFloat32Array = 8,
	kJSTypedArrayTypeFloat64Array = 9,
	kJSTypedArrayTypeArrayBuffer = 10
} JSTypedArrayType;

/*!
@function
@abstract           Setup the JSContext for use of the Typed Array functions.
@param ctx          The execution context to use
*/
void JSContextPrepareTypedArrayAPI(JSContextRef ctx);

/*!
@function
@abstract           Returns a JavaScript value's Typed Array type
@param ctx          The execution context to use.
@param value        The JSObject whose Typed Array type you want to obtain.
@result             A value of type JSTypedArrayType that identifies value's Typed Array type
*/
JSTypedArrayType JSObjectGetTypedArrayType(JSContextRef ctx, JSObjectRef object);

/*!
@function
@abstract           Creates an empty JavaScript Typed Array with the given number of elements
@param ctx          The execution context to use.
@param arrayType    A value of type JSTypedArrayType identifying the type of array you want to create
@param numElements  The number of elements for the array.
@result             A JSObjectRef that is a Typed Array or NULL if there was an error
*/
JSObjectRef JSObjectMakeTypedArray(JSContextRef ctx, JSTypedArrayType arrayType, size_t numElements);

/*!
@function
@abstract           Returns a copy of the Typed Array's data
@param ctx          The execution context to use.
@param value        The JSObject whose Typed Array data you want to obtain.
@result             A copy of the Typed Array's data or NULL if the JSObject is not a Typed Array
*/
NSMutableData *JSObjectGetTypedArrayData(JSContextRef ctx, JSObjectRef object);

/*!
@function
@abstract           Replaces a Typed Array's data
@param ctx          The execution context to use.
@param value        The JSObject whose Typed Array data you want to replace
*/
void JSObjectSetTypedArrayData(JSContextRef ctx, JSObjectRef object, NSData *data);

