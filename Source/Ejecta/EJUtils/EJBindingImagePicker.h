// The Image Picker is one of the few classes that have no direct counterpart
// in the browser. It allows Ejecta to load an image from camera roll or a new
// photo.

// The image is returned as EJBindingImage instance to JavaScript and can be
// directly drawn onto a Canvas or loaded as a WebGL texture.

// The Image Picker is disabled by default, because Apple will reject your
// app from the appstore if this functionality is compiled in, but an
// `NSPhotoLibraryUsageDescription` key is missing from the app's plist,
// explaining what it's used for.



// To enable the image picker, change the following `EJ_PICKER_ENABLED` to
// true and add the `NSPhotoLibraryUsageDescription` key to your info.plist.

#define EJ_PICKER_ENABLED false




#if EJ_PICKER_ENABLED

#import "EJBindingBase.h"

#define EJ_PICKER_TYPE_FULLSCREEN 1
#define EJ_PICKER_TYPE_POPUP      2

typedef enum {
	kEJImagePickerTypeFullscreen,
	kEJImagePickerTypePopup
} EJImagePickerType;

@interface EJBindingImagePicker : EJBindingBase <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate> {
	JSObjectRef callback;
	UIImagePickerController *picker;
	NSString *imgFormat;
	float jpgCompression;
	EJImagePickerType pickerType;
	float maxJsWidth, maxJsHeight;
	float maxTexWidth, maxTexHeight;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)successCallback:(JSValueRef[])params;
- (void)errorCallback:(NSString *)message;
- (void)closePicker:(JSContextRef)ctx;
- (UIImage *)reduceImageSize:(UIImage *)image;

+ (BOOL)isSourceTypeAvailable:(NSString *) sourceType;

@end

#endif
