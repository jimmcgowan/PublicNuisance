//
//  AudioPlayer.h
//  Public Nuisance
//
//  Created by Jim McGowan on 12/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>   // For AUGraph
#import "MWLog.h"

@interface AudioPlayer : NSObject

- (BOOL)assignTrackNumber:(NSUInteger)trackNumber; // returns NO if track number is not valid (valid values are 1,2,3,4)
- (void)play;
- (void)stop;

@end
