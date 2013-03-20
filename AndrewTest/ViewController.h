//
//  ViewController.h
//  AndrewTest
//
//  Created by Andrew Bueno on 3/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property AVAudioRecorder *audioRecorder;
@property AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) IBOutlet UIButton *playButton; //Refers to the play button in the UI
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;

- (IBAction)recordPress:(UIButton *)sender; //What is done when a button is pressed

- (IBAction)playPress:(UIButton *)sender;

- (IBAction)stopPress:(UIButton *)sender;

@end
