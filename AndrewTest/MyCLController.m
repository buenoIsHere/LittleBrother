//
//  MyCLController.m
//  AndrewTest
//
//  Created by  on 3/23/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MyCLController.h"



@implementation MyCLController

@synthesize locationManager;
@synthesize delegate;

-(id) init{
    self = [super init];
    if(self != nil){
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self; //send loc updates to myself
    }
    return self;
}

-(void) viewDidLoad {
    [[MyCLController alloc] init];
}

-(void)locationManager:(CLLocationManager *)manager
        didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    [self.delegate locationUpdate:newLocation]; 
    //NSLog(@"Location: %@", [newLocation description]);
}

-(void)locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error
{
    [self.delegate locationError:error]; 
    //NSLog(@"Error: %@", [error description]);
}

-(void)dealloc {
    [self.locationManager release];
    [super dealloc];
}

- (void)locationUpdate:(CLLocation *)location {
}

- (void)locationError:(NSError *)error {
}

@end
