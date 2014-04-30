#import "EJBindingEncryptorXOR.h"

@implementation EJBindingEncryptorXOR


-(void)interceptData:(NSMutableData *)data {
    
    if (!data){
        return;
    }
    
	NSData *headData = [EJ_SECRET_HEADER dataUsingEncoding:NSUTF8StringEncoding];
	size_t headLen = headData.length;
	char const *head = headData.bytes;

    char const *bytes = data.bytes;
	for (int i = 0; i < headLen; i++) {
		if (bytes[i]!=head[i]){
            return;
        };
	}
    
    NSData *keyData = [EJ_SECRET_KEY dataUsingEncoding:NSUTF8StringEncoding];
	size_t keyLen = keyData.length;
	char const *key = keyData.bytes;
    
    NSRange range = NSMakeRange(0, headLen);
    [data replaceBytesInRange:range withBytes:NULL length:0];
    size_t dataSize = data.length;
    char *mutableBytes = data.mutableBytes;
    
	for (int i = 0; i < dataSize; i++) {
		char v = bytes[i];
        char kv = key[i % keyLen];
		mutableBytes[i] = v ^ kv;
	}
}

@end
