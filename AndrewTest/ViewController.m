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

- (void)viewDidLoad
{
    [super viewDidLoad];
    playButton.enabled = NO;
    stopButton.enabled = NO;
    
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
    
    	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (IBAction)recordPress:(UIButton *)sender {

    if (!audioRecorder.recording)
    {
        playButton.enabled = NO;
        stopButton.enabled = YES;
        
        NSDate *today = [NSDate date];
        
        NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
        [inFormat setDateFormat: @"YY-MM-DD-hh:mm:ss"];
        
        NSString *timestamp = [inFormat stringFromDate:today];
        
        
        //Getting the documents directory
        NSString *docPath = [ViewController documentsPath ];
        NSString *folderPath = [docPath stringByAppendingPathComponent: timestamp];
        NSString *soundFilePath = [folderPath stringByAppendingPathComponent:@"sound.caf"];
        
        
        if(![[NSFileManager defaultManager] createDirectoryAtPath: folderPath withIntermediateDirectories: NO attributes:nil error: nil])
            NSLog(@"Error: Couldn't create folder %@", docPath);
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        NSError *error = nil;
        
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

- (IBAction)playPress:(UIButton *)sender {
    if (!audioRecorder.recording)
    {
        stopButton.enabled = YES;
        recordButton.enabled = NO;
        
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

- (IBAction)stopPress:(UIButton *)sender {
    stopButton.enabled = NO;
    playButton.enabled = YES;
    recordButton.enabled = YES;
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
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

@end
