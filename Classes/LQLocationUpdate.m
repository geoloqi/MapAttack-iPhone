//
//  LQLocationUpdate.m
//  MapAttack
//
//  Created by Deepa Bhan on 8/19/11.
//  Copyright 2011 __GEOLOQI__. All rights reserved.
//

#import "LQLocationUpdate.h"

FTLocationSimulator *locationManager;
BOOL locationUpdatesOn;

@implementation LQLocationUpdate 

- (void)startMonitoringLocation 
{
	if (!locationManager) {
#ifdef FAKE_CORE_LOCATION
		FTLocationSimulator *locationManager = [[FTLocationSimulator alloc] init];
        NSLog(@"I am here");
#else
		locationManager = [[CLLocationManager alloc] init];
#endif
		locationManager.distanceFilter = 1.0; //distanceFilterDistance;
		//locationManager.delegate = self;
}
[locationManager startUpdatingLocation];
locationUpdatesOn = YES;
    
}
@end
