//
//  ViewController.h
//  Public Nuisance
//
//  Created by Jim McGowan on 9/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AudioPlayer.h"
#import "UsernameViewController.h"

@interface NetworkViewController : UIViewController <MCSessionDelegate, MCBrowserViewControllerDelegate, UsernameViewControllerDelegate>

@property (weak) IBOutlet UITextView *messageView;

- (IBAction)joinSession:(id)sender;
- (IBAction)assignTracksToPeers:(id)sender;
- (IBAction)playMusic:(id)sender;
- (IBAction)sendMessage:(id)sender;


@end
