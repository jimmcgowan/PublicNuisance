//
//  AppDelegate.h
//  Public Nuisance
//
//  Created by Jim McGowan on 9/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>   // for AVAudioSession
#import "AudioPlayer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong) AudioPlayer *audioPlayer;

@end
