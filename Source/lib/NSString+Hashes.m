//
//  NSString+Hashes.m
//
//  Created by Klaus-Peter Dudas on 26/07/2011.
//  Copyright: Do whatever you want with this, i.e. Public Domain
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+Hashes.h"

static inline NSString *NSStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    
    for (int i = 0; i < digestLength; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
                             
@implementation NSString (Hashes)

- (NSString *)md5
{
    return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, self);
}

- (NSString *)sha1
{
    return NSStringCCHashFunction(CC_SHA1, CC_SHA1_DIGEST_LENGTH, self);
}

- (NSString *)sha224
{
    return NSStringCCHashFunction(CC_SHA224, CC_SHA224_DIGEST_LENGTH, self);
}

- (NSString *)sha256
{
    return NSStringCCHashFunction(CC_SHA256, CC_SHA256_DIGEST_LENGTH, self);
}

- (NSString *)sha384
{
    return NSStringCCHashFunction(CC_SHA384, CC_SHA384_DIGEST_LENGTH, self);
}
- (NSString *)sha512
{
    return NSStringCCHashFunction(CC_SHA512, CC_SHA512_DIGEST_LENGTH, self);
}

@end
