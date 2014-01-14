//
//  MWLog.h
//  Malkinware
//
//  Created by Jim McGowan on 09/10/2009.
//  Copyright 2009 Jim McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MWLog(s,...) MWLogFormatStringWithSourceFileAndLineNumber(__FILE__, __LINE__, (s), ##__VA_ARGS__)
#define MWLogOSStatus(x) MWLogOSStatusWithSourceFileAndLineNumber(__FILE__, __LINE__, (x))

void MWLogFormatStringWithSourceFileAndLineNumber(char *sourceFile, NSInteger line, NSString *string, ...);

void MWLogOSStatusWithSourceFileAndLineNumber(char *sourceFile, NSInteger line, OSStatus status);