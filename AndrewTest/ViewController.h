//
//  ViewController.h
//  AndrewTest
//
//  Created by Andrew Bueno on 3/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MyCLController.h"
#import "WebServer.h"

@interface ViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, MyCLControllerDelegate> {
    MyCLController *locationController;
    IBOutlet UILabel *coordDisplay;

    NSString *coordTxt; //Text to be displayed
    NSString *folderPath; //Current directory being saved to
    BOOL recordGPS;
    
    NSMutableArray *latLongCoords;
    NSMutableArray *coordTimes;
}


@property AVAudioRecorder *audioRecorder;
@property AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) IBOutlet UIButton *playButton; //Refers to the play button in the UI
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property NSDictionary *recordSettings;
@property WebServer *server;
@property (weak, nonatomic) IBOutlet UILabel *serverAddressLabel;


- (IBAction)recordPress:(UIButton *)sender; //What is done when a button is pressed

- (IBAction)playPress:(UIButton *)sender;

- (IBAction)stopPress:(UIButton *)sender;

+ (NSString *)documentsPath;

- (void) saveToPlist;

- (IBAction)toggleServer:(UISwitch*)sender;


@end
