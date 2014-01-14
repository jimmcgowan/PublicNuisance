//
//  AudioPlayer.m
//  Public Nuisance
//
//  Created by Jim McGowan on 12/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer
{
    AUGraph audioUnitsGraph;
    AudioUnit filePlayerUnit;
    AudioFileID musicFileID;
    CFURLRef audioFileURLRef;
}


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        audioFileURLRef = NULL;
        
        // create the empty audio units graph
		NewAUGraph(&audioUnitsGraph);
        
        // make a ComponentDescription structure to fetch audio units
		AudioComponentDescription componentDescription;
		componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
		componentDescription.componentFlags = 0;
		componentDescription.componentFlagsMask = 0;
        
        
        // add the nodes in reverse signal order:
		// output <- file playback
		
		// add an ouput node
		componentDescription.componentType = kAudioUnitType_Output;
		componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
		
		AUNode outputNode;
		MWLogOSStatus(AUGraphAddNode(audioUnitsGraph, &componentDescription, &outputNode));
        
        
        // add a file playback node for the loop & connect it to the time pitch
		componentDescription.componentType = kAudioUnitType_Generator;
		componentDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;
		
		AUNode filePlaybackNode;
		MWLogOSStatus(AUGraphAddNode(audioUnitsGraph, &componentDescription, &filePlaybackNode));
		MWLogOSStatus(AUGraphConnectNodeInput(audioUnitsGraph, filePlaybackNode, 0, outputNode, 0));
        
        
        // Open the graph: Instantiates every Audio Unit in the graph.
		MWLogOSStatus(AUGraphOpen(audioUnitsGraph));
		
		// Initialize the graph: Initializes the graph and the connected Audio Units
		MWLogOSStatus(AUGraphInitialize(audioUnitsGraph));
        
        // initialize the instance-variable pointer to the file player unit
        MWLogOSStatus(AUGraphNodeInfo(audioUnitsGraph, filePlaybackNode, NULL, &filePlayerUnit));
        
        // Start the graph running: Begins audio rendering through the graph.
        MWLogOSStatus(AUGraphStart(audioUnitsGraph));

    }
    return self;
}


- (BOOL)assignTrackNumber:(NSUInteger)trackNumber
{
    if (trackNumber >4 || trackNumber <1)
    {
        NSLog(@"Invalid track number %lu", (unsigned long)trackNumber);
        return NO;
    }
    
    
    // Get the audio file url for this track number
    NSString *filename;
    switch (trackNumber) {
        case 1:
        {
            filename = @"MusicTrack1";
            break;
        }
        case 2:
        {
            filename = @"MusicTrack2";
            break;
        }
        case 3:
        {
            filename = @"MusicTrack3";
            break;
        }
        case 4:
        {
            filename = @"MusicTrack4";
            break;
        }
        default:
        {
            return NO;
            break;
        }
    }
    
    NSURL *nsURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"aif"];
    if (nsURL == nil)
    {
        NSLog(@"Couldn't find file %@", filename);
        return NO;
    }
    
    [self setAudioFile:(CFURLRef)nsURL];
    return YES;
}


- (void)setAudioFile:(CFURLRef)audioFileURL
{
    // Stop the graph
    MWLogOSStatus(AUGraphStop(audioUnitsGraph));
    
    // Close any previously opened file
    if (musicFileID != NULL)
    {
        AudioFileClose(musicFileID);
    }
    
    // Reset the file player unit & restart the graph
    MWLogOSStatus(AudioUnitReset(filePlayerUnit, kAudioUnitScope_Global, 0));
    MWLogOSStatus(AUGraphStart(audioUnitsGraph));
    
    
    // Open the music file
    MWLogOSStatus(AudioFileOpenURL(audioFileURL, kAudioFileReadPermission, 0, &musicFileID)); // needs closed again when we are finished with it
    
    // Pass the file ID to the file player unit
    MWLogOSStatus(AudioUnitSetProperty(filePlayerUnit, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &musicFileID, sizeof(musicFileID)));
    
    // Set play region info - play whole file, don't loop.
    ScheduledAudioFileRegion playRegion;
    playRegion.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    playRegion.mTimeStamp.mSampleTime = 0;
    playRegion.mCompletionProc = NULL;
    playRegion.mCompletionProcUserData = NULL;
    playRegion.mAudioFile = musicFileID;
    playRegion.mLoopCount = 0; // 0 = do not loop
    playRegion.mStartFrame = 0;
    playRegion.mFramesToPlay = UINT_MAX;
    
    MWLogOSStatus(AudioUnitSetProperty(filePlayerUnit, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &playRegion, sizeof(playRegion)));
    
    // Prime the unit
    // From Technical Q&A QA1786 https://developer.apple.com/library/ios/qa/qa1786/_index.html :
    //   "Note: When this call is made the audio unit begins reading the audio files and will not return until the number of frames specified by the property value have been read"
    // From kAudioUnitProperty_ScheduledFilePrime comments in AudioUnitProperties.h
    //   "The number of frames to read from disk before returning, or 0 to specify use of a default value"
    UInt32 primeFrames = 0;
    MWLogOSStatus(AudioUnitSetProperty(filePlayerUnit, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &primeFrames, sizeof(primeFrames)));
    
    if (audioFileURLRef != audioFileURL)
    {
        CFRetain(audioFileURL);
        if (audioFileURLRef != NULL)
        {
            CFRelease(audioFileURLRef);
        }
        audioFileURLRef = audioFileURL;
    }
}


- (void)play
{
    // Set the start time of the file player unit to be the next render cycle
    AudioTimeStamp startTime;
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1; // -1 = next render cycle
    MWLogOSStatus(AudioUnitSetProperty(filePlayerUnit, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)));
}


- (void)stop
{
    [self setAudioFile:audioFileURLRef];
}


- (void)dealloc
{
	// close the music file
	AudioFileClose(musicFileID);
	
	// dispose of the audio graph
	AUGraphStop(audioUnitsGraph);
	AUGraphUninitialize(audioUnitsGraph);
	AUGraphClose(audioUnitsGraph);
	DisposeAUGraph(audioUnitsGraph);
}

@end
