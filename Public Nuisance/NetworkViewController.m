//
//  ViewController.m
//  Public Nuisance
//
//  Created by Jim McGowan on 9/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import "NetworkViewController.h"
#import "AppDelegate.h"


#define SEVICE_TYPE @"publicnuiscance"

@implementation NetworkViewController
{
    //AudioPlayer *audioPlayer;
    MCSession *session;
    MCAdvertiserAssistant *advertiserAssistant; // Framework UI class for handling incoming invitations
    MCBrowserViewController *browserViewController;
    
    NSData *playMusicSignal;
    NSData *setTrack1Signal, *setTrack2Signal, *setTrack3Signal, *setTrack4Signal;
}





#pragma mark -
#pragma mark Setup


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // These are used as 'command' messages sent among peers
    playMusicSignal = [[NSData alloc] initWithData:[@"public-niusance-play-music-signal" dataUsingEncoding:NSUTF8StringEncoding]];
    setTrack1Signal = [[NSData alloc] initWithData:[@"1public1niusance1set1track1signal1" dataUsingEncoding:NSUTF8StringEncoding]];
    setTrack2Signal = [[NSData alloc] initWithData:[@"2public2niusance2set2track2signal2" dataUsingEncoding:NSUTF8StringEncoding]];
    setTrack3Signal = [[NSData alloc] initWithData:[@"3public3niusance3set3track3signal3" dataUsingEncoding:NSUTF8StringEncoding]];
    setTrack4Signal = [[NSData alloc] initWithData:[@"4public4niusance4set4track4signal4" dataUsingEncoding:NSUTF8StringEncoding]];
}




- (void)viewDidAppear:(BOOL)animated
{
    // Note: this gets called when the view is first shown when the app launches, but also when the username sheet closes, browser closes, etc.
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        // First time we load, get the username from defaults, if it's not there, ask the user to enter a name
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        if (username == nil)
        {
            [self performSegueWithIdentifier:@"ShowUsernameFieldSegue" sender:self];
        }
        else
        {
            [self setupMultipeerSession];
        }
    });
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowUsernameFieldSegue"])
    {
        // Setup self as the delegate of the username view controller, to get called back when the user finishes entering a name
        UsernameViewController *usernameViewController = (UsernameViewController *)segue.destinationViewController;
        usernameViewController.delegate = self;
    }
}


- (void)controller:(UsernameViewController *)controller didEndEditingWithUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [self setupMultipeerSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setupMultipeerSession
{
    // Create a Peer ID for the user of this device
    NSString *displayName = [NSString stringWithFormat:@"%@ on %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"username"], [UIDevice currentDevice].model];
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    // Create the session that peers will be invited/join into.  We use no encryption to keep things as fast as possible
    session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    
    // Create the advertiser assistant for managing incoming invitations.  The session name is used as the 'service type'
    // Note: the service type must be 1–15 characters long and contain only ASCII lowercase letters, numbers, and hyphens.
    advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:SEVICE_TYPE discoveryInfo:nil session:session];
    
    // Start the assistant to begin advertising availability
    [advertiserAssistant start];
    
    // Initialize the session browser controller
    browserViewController = [[MCBrowserViewController alloc] initWithServiceType:SEVICE_TYPE session:session];
    browserViewController.delegate = self;
    browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
    browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
}









#pragma mark -
#pragma mark Actions

- (void)displayMessage:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messageView.text = [self.messageView.text stringByAppendingFormat:@"%@\n", msg];
        [self.messageView scrollRangeToVisible:NSMakeRange(self.messageView.text.length -1, 1)];
    });
}


- (IBAction)joinSession:(id)sender
{
    [self presentViewController:browserViewController animated:YES completion:nil];
}


- (IBAction)assignTracksToPeers:(id)sender
{
    NSUInteger i = 0;
    NSArray *signals = @[setTrack1Signal, setTrack2Signal, setTrack3Signal, setTrack4Signal];
    
    // Interate through each connected peer and assign a track to each.
    for (MCPeerID *peer in session.connectedPeers)
    {
        NSError *sendError = nil;
        [session sendData:signals[i] toPeers:@[peer] withMode:MCSessionSendDataReliable error:&sendError];
        
        // Check the error return to know if there was an issue sending data to peers.  Note if any peers in the 'toPeers' array argument are not connected sending will fail.
        if (sendError != nil)
        {
            [self displayMessage:[NSString stringWithFormat:@"Error sending assign track message to peer [%@]", sendError]];
        }
        else
        {
            [self displayMessage:[NSString stringWithFormat:@"Assigned track %lu to %@", (unsigned long)i+1, peer.displayName]];
        }
        
        
        i++;
        if (i == 4)
        {
            i = 0;
        }
    }
}


- (IBAction)playMusic:(id)sender
{
    NSError *error = nil;
    [session sendData:playMusicSignal toPeers:session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
    
    // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
    if (error != nil)
    {
        [self displayMessage:[NSString stringWithFormat:@"Error sending Play Music Signal to peers [%@]", error]];
    }
    else
    {
        [self displayMessage:@"Sent Play Music Signal."];
    }

}


- (IBAction)sendMessage:(id)sender
{
    // Convert the string into a UTF8 encoded data
    NSData *messageData = [[NSString stringWithFormat:@"Hello from %@", session.myPeerID.displayName]  dataUsingEncoding:NSUTF8StringEncoding];
    
    // Send text message to all connected peers
    NSError *error = nil;
    [session sendData:messageData toPeers:session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
    
    // Check the error return to know if there was an issue sending data to peers.  Note if any peers in the 'toPeers' array argument are not connected sending will fail.
    if (error != nil)
    {
        [self displayMessage:[NSString stringWithFormat:@"Error sending message to peers [%@]", error]];
    }
    else
    {
        [self displayMessage:@"Sent message."];
    }
}






#pragma mark -
#pragma mark MCBrowserViewControllerDelegate methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browser
{
    // Called when the browser view controller is dismissed with peers connected in a session. (required)
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browser
{
    // Called when the user cancels the browser view controller. (required)
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}









#pragma mark -
#pragma mark Session Delegate Methods

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Indicates that an NSData object has been received from a nearby peer. (required)
    
    if ([data isEqualToData:playMusicSignal])
    {
        [((AppDelegate *)[UIApplication sharedApplication].delegate).audioPlayer play];
    }
    
    if ([data isEqualToData:setTrack1Signal])
    {
        if ([((AppDelegate *)[UIApplication sharedApplication].delegate).audioPlayer assignTrackNumber:1])
        {
            [self displayMessage:@"Assigned to audio track 1"];
        }
    }
    
    if ([data isEqualToData:setTrack2Signal])
    {
        if ([((AppDelegate *)[UIApplication sharedApplication].delegate).audioPlayer assignTrackNumber:2])
        {
            [self displayMessage:@"Assigned to audio track 2"];
        }
    }
    
    if ([data isEqualToData:setTrack3Signal])
    {
        if ([((AppDelegate *)[UIApplication sharedApplication].delegate).audioPlayer assignTrackNumber:3])
        {
            [self displayMessage:@"Assigned to audio track 3"];
        }
    }
    
    if ([data isEqualToData:setTrack4Signal])
    {
        if ([((AppDelegate *)[UIApplication sharedApplication].delegate).audioPlayer assignTrackNumber:4])
        {
            [self displayMessage:@"Assigned to audio track 4"];
        }
    }
    
    
    [self displayMessage:[NSString stringWithFormat:@"%@:\"%@\"", peerID.displayName, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
}


- (void)session:(MCSession *)aSession peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    // Called when the state of a nearby peer changes. (required)
    
    NSString *statusString = @"in unknown status";
    switch (state)
    {
        case MCSessionStateConnected:
            statusString = @"Connected";
            break;
            
        case MCSessionStateConnecting:
            statusString = @"Connecting";
            break;
            
        case MCSessionStateNotConnected:
            statusString = @"Not Connected";
            break;
    }
    
    [self displayMessage:[NSString stringWithFormat:@"%@ is %@", peerID.displayName, statusString]];
}


- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    // Indicates that the local peer began receiving a resource from a nearby peer. (required)
    // We are not interested in sending/receiving resources.
    NSLog(@"-session:didStartReceivingResourceWithName:fromPeer:withProgress:");
}


- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    // Indicates that the local peer finished receiving a resource from a nearby peer. (required)
    // We are not interested in sending/receiving resources.
    NSLog(@"-session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:");
}


- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    // Called when a nearby peer opens a byte stream connection to the local peer. (required)
    // We are not interested in streams
    NSLog(@"-session:didReceiveStream:withName:fromPeer:");
}







#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [advertiserAssistant stop];
    [session disconnect];
}




@end
