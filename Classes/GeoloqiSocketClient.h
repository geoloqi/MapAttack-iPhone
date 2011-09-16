//
//  GeoloqiSocketClient.h
//
//  Created by Aaron Parecki on 4/9/11.
//  Copyright 2011 Geoloqi LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include "FTLocationSimulator.h"
//#import "Database.h"
#import "sqlite3.h"            // Import SQLITE3 header file
#import "Reachability.h"

@class AsyncUdpSocket;
// class GeoloqiSocketClient extends NSObject implements CLLocationManagerDelegate
@interface GeoloqiSocketClient : NSObject <CLLocationManagerDelegate>
{
	AsyncUdpSocket *asyncSocket;
    GeoloqiSocketClient *geoloqiClient;
   sqlite3 *db;        // Create an object of the type sqlite3d

#ifdef FAKE_CORE_LOCATION
	FTLocationSimulator *locationManager;
#else
	CLLocationManager *locationManager;
#endif
	CLLocation *currentLocation;
	BOOL locationUpdatesOn;
	CLLocationDistance distanceFilterDistance;
	NSTimeInterval trackingFrequency;
	NSTimeInterval sendingFrequency;
	NSData *uuid;
    Reachability *reachability;
}

- (void)normalConnect;
- (NSData *)dataFromLocation:(CLLocation *)location;
- (void)startMonitoringLocation;
- (void)stopMonitoringLocation;
- (BOOL)locationUpdateState;

@end
