//
//  SIEmbeddedFileSystem.m
//  SIEmbeddedFileSystem
//
//  Created by Shaun Inman on 6/1/13.
//  Copyright (c) 2013 Shaun Inman. All rights reserved.
//

#import "SIEmbeddedFileSystem.h"

// BUILD PHASE SCRIPT WILL WORK MAGIC HERE

@implementation SIEmbeddedFileSystem

-(id)init
{
	if (self = [super init])
	{
		files = [[NSMutableDictionary alloc] init];
		NSData *data;
		NSString *jsString;

		// SILENCE WARNINGS UNTIL BUILD SCRIPT IS RUN
		data = nil;
		jsString = nil;
		
		// BUILD PHASE SCRIPT WILL WORK MAGIC HERE
	}
	return self;
}

+(SIEmbeddedFileSystem *)sharedInstance
{
    static SIEmbeddedFileSystem *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SIEmbeddedFileSystem alloc] init];
    });
    return sharedInstance;
}

-(NSString *)stringWithContentsOfFile:(NSString *)path
{
	return [files objectForKey:path];
}

@end
