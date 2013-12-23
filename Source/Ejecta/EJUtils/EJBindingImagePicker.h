#import "EJBindingBase.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD  UIUserInterfaceIdiomPad

#define PICKER_TYPE_FULLSCREEN 1
#define PICKER_TYPE_POPUP      2

@interface EJBindingImagePicker : EJBindingBase <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate> {
	JSObjectRef callback;
	NSString * imgFormat;
	double jpgCompression;
	UIImagePickerController * picker;
	UIPopoverController * popover;
	short pickerType;
	int maxWidth, maxHeight;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popup;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)successCallback:(JSValueRef[])params;
- (void)errorCallback:(NSString *)message;
- (void)closePicker:(JSContextRef)ctx;
- (void)dealloc;

+ (BOOL)isSourceTypeAvailable:(NSString *) sourceType;

@end
