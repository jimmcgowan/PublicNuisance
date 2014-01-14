//
//  AppDelegate.m
//  Public Nuisance
//
//  Created by Jim McGowan on 9/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup our Audio Session - this defines the audio behaviour of our app and how it interacts with the OS and other apps
    // We use AVAudioSessionCategoryPlayback, which means we will not be silenced when the screen locks, and we don't allow any other apps to play sound.
    
    NSError *audioSessionError = nil;
    
    if (![[AVAudioSession sharedInstance] setActive: YES error: &audioSessionError])
    {
        NSLog(@"Error Activating Audio Session: %@", audioSessionError);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[audioSessionError localizedDescription] message:[audioSessionError localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
    
    audioSessionError = nil;
    if (![[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&audioSessionError])
    {
        NSLog(@"Error Activating Audio Session: %@", audioSessionError);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[audioSessionError localizedDescription] message:[audioSessionError localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
    
    
    self.audioPlayer = [[AudioPlayer alloc] init];
    
    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
