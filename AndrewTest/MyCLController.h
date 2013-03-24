//
//  MyCLController.h
//  AndrewTest
//
//  Created by  on 3/23/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyCLControllerDelegate
@required
-(void)locationUpdate:(CLLocation *)location;
-(void)locationError:(NSError *)error;

@end

@interface MyCLController : UIViewController <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    id delegate;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id delegate;


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;


@end