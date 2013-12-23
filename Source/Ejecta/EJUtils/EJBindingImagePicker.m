#import <MobileCoreServices/UTCoreTypes.h> // for media filtering
#import "EJBindingImagePicker.h"
#import "EJJavaScriptView.h"


// helpers for extracting options values

static inline JSObjectRef getOptionValue(JSContextRef ctx, JSObjectRef options, NSString * key) {
	JSValueRef jsKeyVal = NSStringToJSValue(ctx, key);
	JSStringRef jsKey = JSValueToStringCopy(ctx, jsKeyVal, NULL);
	JSObjectRef value = (JSObjectRef)JSObjectGetProperty(ctx, options, jsKey, NULL);
	if (JSValueIsEqual(ctx, value, JSValueMakeUndefined(ctx), NULL)) {
		return nil;
	}
	return value;
}

static inline NSString * getOptionValueAsNSString(JSContextRef ctx, JSObjectRef options, NSString * key, NSString * defaultValue) {
	JSObjectRef value = getOptionValue(ctx, options, key);
	if( !value ) { return defaultValue; }
	return JSValueToNSString(ctx, value);
}

static inline int getOptionValueAsInt(JSContextRef ctx, JSObjectRef options, NSString * key, int defaultValue) {
	JSObjectRef value = getOptionValue(ctx, options, key);
	if( !value ) { return defaultValue; }
	return JSValueToNumber(ctx, value, NULL);
}

static inline float getOptionValueAsFloat(JSContextRef ctx, JSObjectRef options, NSString * key, float defaultValue) {
	JSObjectRef value = getOptionValue(ctx, options, key);
	if( !value ) { return defaultValue; }
	return JSValueToNumber(ctx, value, NULL);
}


// starting implementation

@implementation EJBindingImagePicker


// constructor
- (id)initWithContext:(JSContextRef) ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
    if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		NSLog(@"A new picker have been created");
	}
    return self;
}


// .getPicture(function(error, image) {}, options)
EJ_BIND_FUNCTION(getPicture, ctx, argc, argv) {

	// checking if the 2 parameters are here (callback and options)
	if( argc < 2 ) {
		return NULL;
	}
	
	// 1st parameter: callback
	JSValueUnprotectSafe(ctx, callback);
	callback = JSValueToObject(ctx, argv[0], NULL);
	
	// 2nd parameter: options
	JSObjectRef options = JSValueToObject(ctx, argv[1], NULL);
	
	// Set the source type
	NSString * sourceType = getOptionValueAsNSString(ctx, options, @"sourceType", @"PhotoLibrary");
	if( ![sourceType isEqualToString:@"PhotoLibrary"] && ![sourceType isEqualToString:@"SavedPhotosAlbum"] && ![sourceType isEqualToString:@"Camera"] ) {
		[self errorCallback:[NSString stringWithFormat:@"sourceType `%@` unknown. Valid values are: `PhotoLibrary`, `SavedPhotosAlbum`, `Camera`.", sourceType]];
		return NULL;
	}

	// Set the returned image format
	imgFormat = getOptionValueAsNSString(ctx, options, @"imgFormat", @"png");
	if( ![imgFormat isEqualToString:@"png"] && ![imgFormat isEqualToString:@"jpg"] && ![imgFormat isEqualToString:@"jpeg"] ) {
		[self errorCallback:[NSString stringWithFormat:@"imgFormat `%@` unknown. Valid values are: `png`, `jpg`, `jpeg`.", imgFormat]];
		return NULL;
	}
	
	// Set the jpeg compression
	jpgCompression = getOptionValueAsFloat(ctx, options, @"jpgCompression", 0.9);
	if( jpgCompression < 0.1 ) {
		jpgCompression = 0.1;
	} else if( jpgCompression > 1 ) {
		jpgCompression = 1;
	}
	
	// Picture maximum width and height, default is the maximum GL texture size
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	maxWidth = lroundf(getOptionValueAsFloat(ctx, options, @"maxWidth", maxTextureSize));
	maxHeight = lroundf(getOptionValueAsFloat(ctx, options, @"maxHeight", maxTextureSize));
	maxWidth = MIN(maxWidth, maxTextureSize);
	maxHeight = MIN(maxHeight, maxTextureSize);
	
	// X and Y position pointed by the popup on iPad
	float popupX = getOptionValueAsFloat(ctx, options, @"popupX", 0);
	float popupY = getOptionValueAsFloat(ctx, options, @"popupY", 0);
	
	// iPad popup width and height (see Apple UIPopoverController doc for more explanations) default is 1 (automatic / smaller size)
	float popupWidth = getOptionValueAsFloat(ctx, options, @"popupWidth", 0);
	float popupHeight = getOptionValueAsFloat(ctx, options, @"popupHeight", 0);
	
	//NSLog(@"sourcetype: %@ - imgFormat: %@ - jpgCompression: %f", sourceType, imgFormat, jpgCompression);
	//NSLog(@"maxWidth: %i - maxHeight: %i", maxWidth, maxHeight);
	//NSLog(@"popupX: %f - popupY: %f - popupWidth: %f - popupHeight: %f", popupX, popupY, popupWidth, popupHeight);
	
	// check if the requested sourceType is available on this device
	if( ![EJBindingImagePicker isSourceTypeAvailable:sourceType] ) {
		[self errorCallback:[NSString stringWithFormat:@"sourceType `%@` is not available on this device.", sourceType]];
		return NULL;
	}

	// identify the type of picker we need: full screen or popup
	if( IDIOM == IPAD && ![sourceType isEqualToString:@"Camera"] ) {
		pickerType = PICKER_TYPE_POPUP;
	} else {
		pickerType = PICKER_TYPE_FULLSCREEN;
	}
	
	// init and alloc
	picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	if( pickerType == PICKER_TYPE_POPUP ) {
		popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		popover.delegate = self;
	}

	// limit to pictures only
	[picker setMediaTypes: [NSArray arrayWithObject:(NSString *)kUTTypeImage]];
	
	// select the source type
	if( [sourceType isEqualToString:@"PhotoLibrary"] ) {
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	} else if ( [sourceType isEqualToString:@"SavedPhotosAlbum"] ) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else if ( [sourceType isEqualToString:@"Camera"] ) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	
	// we are ready to open the picker, let's retain the variables we need for the callback
	[imgFormat retain];
	JSValueProtect(ctx, callback);
	[self retain];
	
	// open it
	if ( pickerType == PICKER_TYPE_POPUP ) {
		[popover
		    presentPopoverFromRect:CGRectMake(popupX, popupY, popupWidth, popupHeight)
		    inView:scriptView.window.rootViewController.view
		    permittedArrowDirections:UIPopoverArrowDirectionAny
		    animated:YES];
	} else {
		[scriptView.window.rootViewController presentModalViewController:picker animated:YES];
	}
	
    return NULL;
}


// .isSourceTypeAvailable(sourceType), returns bool
EJ_BIND_FUNCTION(isSourceTypeAvailable, ctx, argc, argv) {
	if( argc == 0 ) {
		return NULL;
	}
	NSString * sourceType = JSValueToNSString(ctx, argv[0]);
	return [EJBindingImagePicker isSourceTypeAvailable:sourceType];
}


// popup was dismissed (relevant only when pickerType == PICKER_TYPE_POPUP)
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popup {
	JSContextRef ctx = scriptView.jsGlobalContext;
	// close and release
	[self closePicker:ctx];
}


// user picked a picture
- (void)imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// retrieve image data
	UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
	NSData *dataForFile;
	if( [imgFormat isEqualToString:@"jpg"] || [imgFormat isEqualToString:@"jpeg"] ) {
		dataForFile = UIImageJPEGRepresentation(chosenImage, jpgCompression);
	} else {
		dataForFile = UIImagePNGRepresentation(chosenImage);
	}
	
	// encode into base64
	// TODO: should create a js image object instead
	NSString *encodedString = [dataForFile base64Encoding];
	
	// call the callback passing the base64 string representation of the image
	JSContextRef ctx = scriptView.jsGlobalContext;
	JSValueRef params[] = { NULL, NSStringToJSValue(ctx, encodedString) };
	[self successCallback:params];
	
	// close and release
	[self closePicker:ctx];
}


// user cancelled
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)_picker {
	
	// error
	[self errorCallback:@"User cancelled"];
	
	// close and release
	JSContextRef ctx = scriptView.jsGlobalContext;
	[self closePicker:ctx];
}


// success callback
- (void)successCallback:(JSValueRef[])params {
	[scriptView invokeCallback:callback thisObject:jsObject argc:2 argv:params];
}


// error callback
- (void)errorCallback:(NSString *)message {
	JSContextRef ctx = scriptView.jsGlobalContext;
	JSValueRef params[] = { NSStringToJSValue(ctx, message), NULL };
	[scriptView invokeCallback:callback thisObject:jsObject argc:1 argv:params];
}


// called to close the picker and release retained stuff
- (void)closePicker:(JSContextRef)ctx {
	
	// close the picker
	[picker dismissViewControllerAnimated:YES completion:NULL];
	
	// close the popup
	if( pickerType == PICKER_TYPE_POPUP ) {
		[popover dismissPopoverAnimated:TRUE];
	}
	
	// release all the retained stuff
	JSValueUnprotectSafe(ctx, callback);
	[imgFormat release];
	[picker release];
	NSLog(@"picker released");
	if ( pickerType == PICKER_TYPE_POPUP ) {
		[popover release];
		NSLog(@"popup released");
	}
	[self release];
}


// Triggered by the garbage collector when the instance created in javascript with
// `new Ejecta.ImagePicker()` doesn't exists anymore
- (void)dealloc {
	NSLog(@"An ImagePicker instance is being deallocated.");
    [super dealloc];
}


// to check if a source type is available on the current device
+ (BOOL)isSourceTypeAvailable:(NSString *) sourceType {
	if( ![sourceType isEqualToString:@"PhotoLibrary"] && ![sourceType isEqualToString:@"SavedPhotosAlbum"] && ![sourceType isEqualToString:@"Camera"] ) {
		return NO;
	}
	if( [sourceType isEqualToString:@"PhotoLibrary"] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
		return NO;
	} else if( [sourceType isEqualToString:@"SavedPhotosAlbum"] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] ) {
		return NO;
	} else if( [sourceType isEqualToString:@"Camera"] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
		return NO;
	}
	return YES;
}


@end


/*
Example JS code:

 // Tap the screen to open the image picker
 
 var w = window.innerWidth;
 var h = window.innerHeight;
 var canvas = document.getElementById('canvas');
 canvas.width = w;
 canvas.height = h;
 var ctx = canvas.getContext('2d');
 ctx.fillStyle = '#000000';
 ctx.fillRect(0, 0, w, h);
 
 document.addEventListener('touchend', function (ev) {
 
 // the imagePicker instance have to be still alive when the callback will be called
 // for this purpose, attaching it to window
 var imagePicker = new Ejecta.ImagePicker();
 
 var options = {
 sourceType     : 'PhotoLibrary',
 imgFormat      : 'jpeg',
 jpgCompression : 0.5,
 popupX         : ev.changedTouches[0].pageX,
 popupY         : ev.changedTouches[0].pageY,
 popupWidth     : 1,
 popupHeight    : 1,
 maxWidth       : w,
 maxHeight      : h
 };
 
 imagePicker.getPicture(function (error, image) {
 if (error) {
 return console.log('Loading failed: ' + error);
 }
 var img = new Image();
 img.onload = function () {
 ctx.drawImage(this, 0, 0);
 };
 img.src = 'data:image/jpeg;base64,' + image;
 }, options);
 
 }, false);
 
*/