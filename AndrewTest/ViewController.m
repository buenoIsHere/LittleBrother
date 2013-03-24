//
//  ViewController.m
//  AndrewTest
//
//  Created by Andrew Bueno on 3/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize audioRecorder;
@synthesize audioPlayer;

@synthesize playButton;
@synthesize recordButton;
@synthesize stopButton;
@synthesize recordSettings;

@synthesize latLongCoords;
@synthesize coordTimes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //These buttons are useless until either something is recorded or something is playing
    playButton.enabled = NO;
    stopButton.enabled = NO;
    
    //Settings for audio recording
    recordSettings = [NSDictionary 
                      dictionaryWithObjectsAndKeys:
                      [NSNumber numberWithInt:AVAudioQualityMin],
                      AVEncoderAudioQualityKey,
                      [NSNumber numberWithInt:16], 
                      AVEncoderBitRateKey,
                      [NSNumber numberWithInt: 2], 
                      AVNumberOfChannelsKey,
                      [NSNumber numberWithFloat:44100.0], 
                      AVSampleRateKey,
                      nil];
    
    latLongCoords = [NSMutableArray array];
    coordTimes = [NSMutableArray array];
    
    locationController = [[MyCLController alloc] init];
    locationController.delegate = self;
    
    //Have controller begin tracking location
    [locationController.locationManager startUpdatingLocation];
    
    //That said, we don't want to actually record data until record is pressed
    recordGPS = NO;

}

//- (void)viewDidUnload
//{
//    [self setCoordDisplay:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


//Grabs location from MyCLController and updates the coordinate string.
//If record button currently pressed, this will also call upon saveToPlist.
- (void)locationUpdate:(CLLocation *)location {
    
    NSString *lat = [NSString stringWithFormat: @"%f", location.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat: @"%f", location.coordinate.longitude];
    
    coordTxt = [lat stringByAppendingString:
                [NSString stringWithFormat:@", %@", lon]];
    
    coordDisplay.text = coordTxt;
    
    if(recordGPS){
        [self saveToPlist];
    }
}

- (void) saveToPlist{
    NSDictionary *dict;
    
    NSDate *currentTime = [NSDate date];
    NSTimeInterval coordTime = [currentTime timeIntervalSince1970];
    
    [latLongCoords addObject:coordTxt];
    [coordTimes addObject: [NSString stringWithFormat:@"%d",[NSNumber numberWithDouble:coordTime]]];
    
    dict = [NSDictionary dictionaryWithObjects:latLongCoords forKeys:coordTimes];
    
    NSError *error = nil;
    
    //This plist is of type NSData, which we may write to a file.
    NSData *plist = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListMutableContainersAndLeaves error:&error];
    
    NSString *plistFilePath = [folderPath stringByAppendingPathComponent:@"data.plist"];
    NSURL *plistFileURL = [NSURL fileURLWithPath:plistFilePath];
    
    [plist writeToURL:plistFileURL atomically:YES];
}


//In case there is an error from MyCLController
- (void)locationError:(NSError *)error {
    coordDisplay.text = [error description];
}

//What happens when "record" is pressed.
- (IBAction)recordPress:(UIButton *)sender {
    
    if (!audioRecorder.recording)
    {
        //This is so time/GPS data is also recorded
        recordGPS = YES;
        
        //We can stop recording, but certainly can't play during it!
        playButton.enabled = NO;
        stopButton.enabled = YES;
        
        NSDate *today = [NSDate date];
        
        //All directories are timestamped
        NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
        [inFormat setDateFormat: @"YY-MM-DD-hh:mm:ss"];
        
        NSString *timestamp = [inFormat stringFromDate:today];
        
        //Creating the directory path
        NSString *docPath = [ViewController documentsPath];
        folderPath = [docPath stringByAppendingPathComponent: timestamp];
        NSString *soundFilePath = [folderPath stringByAppendingPathComponent:@"sound.caf"];
        
        //Actually creating the directory. If error returned the rest of this method is
        //pretty meaningless.
        if(![[NSFileManager defaultManager] createDirectoryAtPath: folderPath withIntermediateDirectories: NO attributes:nil error: nil])
            NSLog(@"Error: Couldn't create folder %@", docPath);
        
        //Audio recorder likes urls.
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        NSError *error = nil;
        
        //Instantiate the audioRecorder object property, which will write to the file url we have created
        audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
        audioRecorder.delegate = self;
        
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        } else {
            [audioRecorder prepareToRecord];
        }

        [audioRecorder record];
    }            
}

//What happens when "play" is pressed.
- (IBAction)playPress:(UIButton *)sender {
    if (!audioRecorder.recording)
    {
        //We can stop but can't record while playing!
        stopButton.enabled = YES;
        recordButton.enabled = NO;
        
        
        //Assuming the audioRecorder has already been instantiated, 
        //this will instantiate the audioPlayer.
        NSError *error;
        
        audioPlayer = [[AVAudioPlayer alloc] 
                       initWithContentsOfURL:audioRecorder.url                                    
                       error:&error];
        
        audioPlayer.delegate = self;
        
        if (error)
            NSLog(@"Error: %@", 
                  [error localizedDescription]);
        else
            [audioPlayer play];
    }
}

//What happens when "stop" is pressed.
- (IBAction)stopPress:(UIButton *)sender {
    
    //We want to reset our arrays of coords and times for the next recording session.
    latLongCoords = [NSMutableArray array];
    coordTimes = [NSMutableArray array];
    
    recordGPS = NO;
    
    //We only want to be able to play or record, and stop only once!
    stopButton.enabled = NO;
    playButton.enabled = YES;
    recordButton.enabled = YES;
    
    //Cease recording/playing.
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    
    
    NSArray *whoa = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];    
    NSString *noway = [whoa lastObject];
    
    
//    BOOL what;
//    [[NSFileManager defaultManager] fileExistsAtPath:soundFilePath isDirectory:&what];
//    NSLog(what ? @"Yes" : @"No");
    NSLog(@"%@",noway);

}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    recordButton.enabled = YES;
    stopButton.enabled = NO;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSArray *paths = [[NSFileManager defaultManager] subpathsAtPath:[ViewController documentsPath]];
    for(NSString *p in paths)
    {
        NSLog(@"%@",p);
    }
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

+ (NSString *)documentsPath {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [dirPaths objectAtIndex:0];
    return path;
}

-(void)dealloc {
    //[locationController release];
    //[super dealloc];
    
}

@end
