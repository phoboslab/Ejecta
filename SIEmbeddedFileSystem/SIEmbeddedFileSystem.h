//
//  EmbeddedFileSystem.h
//  EmbeddedFileSystem
//
//  Created by Shaun Inman on 6/1/13.
//  Copyright (c) 2013 Shaun Inman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIEmbeddedFileSystem : NSObject
{
	NSMutableDictionary *files;
}

-(NSString *)stringWithContentsOfFile:(NSString *)path;
+(SIEmbeddedFileSystem *)sharedInstance;

@end
