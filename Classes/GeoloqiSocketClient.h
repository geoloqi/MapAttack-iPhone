//
//  GeoloqiSocketClient.h
//
//  Created by Aaron Parecki on 4/9/11.
//  Copyright 2011 Geoloqi LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AsyncSocket.h"
#include "FTLocationSimulator.h"

#define LQ_SOCKET_HOST @"loki.geoloqi.com"
#define LQ_SOCKET_PORT 40000

@interface GeoloqiSocketClient : NSObject <CLLocationManagerDelegate>
{
	AsyncSocket *asyncSocket;
    GeoloqiSocketClient *geoloqiClient;
#ifdef FAKE_CORE_LOCATION
	CLLocationManager *locationManager;
#else
	FTLocationSimulator *locationManager;
#endif
	CLLocation *currentLocation;
	BOOL locationUpdatesOn;
	CLLocationDistance distanceFilterDistance;
	NSTimeInterval trackingFrequency;
	NSTimeInterval sendingFrequency;
}

- (void) normalConnect;
- (NSData *)dataFromLocation:(CLLocation *)location;
- (void)startMonitoringLocation;
- (void)stopMonitoringLocation;

// TODO: Make a delegate protocol.
// TODO: Send CLLocation to server.

@end
