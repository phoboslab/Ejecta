#import "EJBindingBase.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD  UIUserInterfaceIdiomPad

#define PICKER_TYPE_FULLSCREEN 1
#define PICKER_TYPE_POPUP      2

@interface EJBindingImagePicker : EJBindingBase <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate> {
	JSObjectRef callback;
	UIImagePickerController * picker;
	UIPopoverController * popover;
	NSString * imgFormat;
	float jpgCompression;
	short pickerType;
	float maxWidth, maxHeight;
}

- (void)dealloc;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popup;
- (void)successCallback:(JSValueRef[])params;
- (void)errorCallback:(NSString *)message;
- (void)closePicker:(JSContextRef)ctx;
- (UIImage *)reduceImageSize:(UIImage *)image;

+ (BOOL)isSourceTypeAvailable:(NSString *) sourceType;

@end
