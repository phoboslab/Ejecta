#import <MobileCoreServices/UTCoreTypes.h> // for media filtering
#import "EJBindingImagePicker.h"
#import "EJJavaScriptView.h"


// helpers for extracting options values

static inline JSObjectRef getOptionValue(JSContextRef ctx, JSObjectRef options, NSString * key) {
	JSValueRef jsKeyVal = NSStringToJSValue(ctx, key);
	JSStringRef jsKey = JSValueToStringCopy(ctx, jsKeyVal, NULL);
	JSObjectRef value = (JSObjectRef)JSObjectGetProperty(ctx, options, jsKey, NULL);
	if( JSValueIsEqual(ctx, value, JSValueMakeUndefined(ctx), NULL) ) {
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


@implementation EJBindingImagePicker


- (id)initWithContext:(JSContextRef) ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
    if( self = [super initWithContext:ctx argc:argc argv:argv] ) {
		NSLog(@"A new picker have been created");
	}
    return self;
}


- (void)dealloc {
	NSLog(@"An ImagePicker instance is being deallocated.");
    [super dealloc];
}


EJ_BIND_FUNCTION(isSourceTypeAvailable, ctx, argc, argv) {
	if( argc == 0 ) {
		return NULL;
	}
	NSString * sourceType = JSValueToNSString(ctx, argv[0]);
	return [EJBindingImagePicker isSourceTypeAvailable:sourceType];
}


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
	float popupWidth = getOptionValueAsFloat(ctx, options, @"popupWidth", 1);
	float popupHeight = getOptionValueAsFloat(ctx, options, @"popupHeight", 1);
	
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


// user picked a picture
- (void)imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// retrieve image data
	UIImage * rawImage = info[UIImagePickerControllerOriginalImage];
	UIImage * chosenImage;
	
	// resize it if required
	if( rawImage.size.width > maxWidth || rawImage.size.height > maxHeight ) {
		chosenImage = [self reduceImageSize:rawImage];
	} else {
		chosenImage = rawImage;
	}
	
	// here the UIImage chosenImage should be transformed into a javascript image object
	// for the time being, it's going to return a Data URI representation instead
	
	NSData *dataForFile;
	if( [imgFormat isEqualToString:@"jpg"] || [imgFormat isEqualToString:@"jpeg"] ) {
		dataForFile = UIImageJPEGRepresentation(chosenImage, jpgCompression);
	} else {
		dataForFile = UIImagePNGRepresentation(chosenImage);
	}
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


// popup was dismissed (relevant only when the picker was opened as a popup)
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popup {
	JSContextRef ctx = scriptView.jsGlobalContext;
	// close and release
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


// to close the picker and release retained stuff
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
}


// reduce an image to fit the maximum values
- (UIImage *)reduceImageSize:(UIImage *)image {
	float originalWidth = image.size.width;
	float originalHeight = image.size.height;
	float ratio = MIN((float)maxWidth / originalWidth, (float)maxHeight / originalHeight);
	float targetWidth = lroundf(originalWidth * ratio);
	float targetHeight = lroundf(originalHeight * ratio);
	
	CGSize newSize = CGSizeMake(targetWidth, targetHeight);
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	[image drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
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