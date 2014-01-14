//
//  MWLog.m
//  Malkinware
//
//  Created by Jim McGowan on 09/10/2009.
//  Copyright 2009 Jim McGowan. All rights reserved.
//

#import "MWLog.h"


void MWLogFormatStringWithSourceFileAndLineNumber(char *sourceFile, NSInteger line, NSString *string, ...)
{
    va_list ap;
	va_start(ap,string);
	NSString *ouputMsg = [[NSString alloc] initWithFormat:string arguments:ap];
	NSString *fileName = [[NSString stringWithUTF8String:sourceFile] lastPathComponent];
	va_end(ap);
	
	NSLog(@"%s:%ld %@",[fileName UTF8String], (long)line, ouputMsg);
}


void MWLogOSStatusWithSourceFileAndLineNumber(char *sourceFile, NSInteger line, OSStatus status)
{
    if(status != noErr)
    {
        NSString *fileName = [[NSString stringWithUTF8String:sourceFile] lastPathComponent];
        NSLog(@"%s:%ld %@",[fileName UTF8String], (long)line, [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    }
}
