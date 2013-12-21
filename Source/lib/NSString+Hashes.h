//
//  NSString+Hashes.h
//
//  Created by Klaus-Peter Dudas on 26/07/2011.
//  Copyright: Do whatever you want with this, i.e. Public Domain
//

#import <Foundation/Foundation.h>

@interface NSString (Hashes)

@property (nonatomic, readonly) NSString *md5;
@property (nonatomic, readonly) NSString *sha1;
@property (nonatomic, readonly) NSString *sha224;
@property (nonatomic, readonly) NSString *sha256;
@property (nonatomic, readonly) NSString *sha384;
@property (nonatomic, readonly) NSString *sha512;

@end