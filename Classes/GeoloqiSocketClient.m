//
//  GeoloqiSocketClient.m
//
//  Created by Aaron Parecki on 4/9/11.
//  Copyright 2011 Geoloqi LLC. All rights reserved.
//

#import "GeoloqiSocketClient.h"
#import "CJSONDeserializer.h"
#import "LQConstants.h"

#define TIMEOUT_SEC 6.0
#define TAG_DEVICE_ID_SENT 1

@implementation GeoloqiSocketClient


- (id) init
{
    if (self = [super init])
    {
		// Change to use UDP
        asyncSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        distanceFilterDistance = 1.0;
		trackingFrequency = 1;
		sendingFrequency = 1;
        // [self normalConnect];    
		[self startMonitoringLocation];
    }
    
    return self;
}

- (void) normalConnect
{
	NSError *error = nil;
	
	NSString *host = LQ_SOCKET_HOST;
    UInt16 port = LQ_SOCKET_PORT;
	
    NSLog(@"Connecting to %@:%i", host, port);
    
	// Change to use UDP
	if (![asyncSocket connectToHost:host onPort:port withTimeout:1 error:&error])
	{
		NSLog(@"Error connecting: %@", error);
	}
    else
    {
		NSData *data = [[UIDevice currentDevice].uniqueIdentifier dataUsingEncoding:NSASCIIStringEncoding];
		NSLog(@"Writing device id: %@", data);
		[asyncSocket writeData:data withTimeout:TIMEOUT_SEC tag:TAG_DEVICE_ID_SENT];
    }	
}

#pragma mark  -

- (void) socket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"localHost:%@ port:%hu", [sock localHost], [sock localPort]);	
}

- (void) socketDidSecure:(AsyncSocket *)sock
{
	NSLog(@"socketDidSecure:%p", sock);
}

- (void) socketDidDisconnect:(AsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    
    // TODO: reconnect
}

- (void) readPacket:(NSData *)data
{
    NSString *packet = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];    
    NSLog(@"Read packet:\n\n'%@'\n\n", packet);
}

- (void) socket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"\n\nINCOMING!!\n\ndidReadData with length %i, tag %i: %@", [data length], tag, data);
}


/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"socketDidReadPartialDataOfLength %i with tag %i", partialLength, tag);
}


/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socketDidWriteDataWithTag: %i", tag);
}


/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"socketDidWritePartialDataOfLength: %i", partialLength);
}


/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 * 
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
- (NSTimeInterval)socket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
				 elapsed:(NSTimeInterval)elapsed
			   bytesDone:(NSUInteger)length
{
	NSLog(@"readTimedOut tag %i", tag);
	return 0;
}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 * 
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
/*
 - (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
 elapsed:(NSTimeInterval)elapsed
 bytesDone:(NSUInteger)length
 {
 
 }
 */

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 * 
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(AsyncSocket *)sock
{
    NSLog(@"socketDidCloseReadStream");
}



- (void)startMonitoringLocation {
	if (!locationManager) {
#ifdef FAKE_CORE_LOCATION
		locationManager = [[FTLocationSimulator alloc] init];
#else
		locationManager = [[CLLocationManager alloc] init];
#endif
		locationManager.distanceFilter = distanceFilterDistance;
		locationManager.delegate = self;
	}
	
	[locationManager startUpdatingLocation];
	
	locationUpdatesOn = YES;
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:LQTrackingStartedNotification object:self];
	
	// Disabling significant location changes. 12/8/10 -ap
	/*
	 [locationManager startMonitoringSignificantLocationChanges];
	 if (significantUpdatesOnly) {
	 NSLog(@"Significant updates on.");
	 [locationManager stopUpdatingLocation];
	 } else {
	 NSLog(@"Starting location updates");
	 [locationManager startUpdatingLocation];
	 }
	 */
}

- (void)stopMonitoringLocation {
	[locationManager stopUpdatingLocation];
	//[locationManager stopMonitoringSignificantLocationChanges];
	[locationManager release];
	locationManager = nil;
	locationUpdatesOn = NO;
	//[[NSNotificationCenter defaultCenter] postNotificationName:LQTrackingStoppedNotification object:self];
}

// This is the method called by the OS when a new location update is received
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {

//	NSLog(@"Updated to location %@ from %@", newLocation, oldLocation);
	
	// horizontalAccuracy is negative when the location is invalid, so completely ignore it in this case
	if(newLocation.horizontalAccuracy < 0){
		return;
	}
	
	// Only capture points as frequently as the min. tracking interval
	// These checks are done against the last saved location (currentLocation)
	if (YES || !oldLocation || // first update
		([newLocation distanceFromLocation:currentLocation] > distanceFilterDistance && // check min. distance
		 [newLocation.timestamp timeIntervalSinceDate:currentLocation.timestamp] > trackingFrequency)) {
			
			// currentLocation is always the point that was last accepted into the queue.
			currentLocation = newLocation;
			
			// Notify observers about the location change
//			[[NSNotificationCenter defaultCenter]
//			 postNotificationName:LQLocationUpdateManagerDidUpdateLocationNotification
//			 object:self];

			NSData *data = [self dataFromLocation:newLocation];
			NSLog(@"Writing device id: %@", data);
			// Change to use UDP
			[asyncSocket writeData:data withTimeout:TIMEOUT_SEC tag:TAG_DEVICE_ID_SENT];
			
		} else {
#if LQ_LOCMAN_DEBUG
			NSLog(@"Location update (to %@; from %@) rejected", newLocation, oldLocation);
#endif
		}
}

- (NSData *)dataFromLocation:(CLLocation *)location {
	// See documentation at https://developers.geoloqi.com/api/Streaming_API
	
	// Create a new byte array
	char update[28];
	
	// Zero out all the elements of the array
	for(int i=0; i<28; i++) 
		update[i] = 0;
	
	// Command
	update[0] = 0;
	update[1] = 65;

	int datestamp = [[NSDate date] timeIntervalSince1970];
	update[2] = (char)((char)(datestamp >> 24) & 0xFF);
	update[3] = (char)((char)(datestamp >> 16) & 0xFF);
	update[4] = (char)((char)(datestamp >> 8) & 0xFF);
	update[5] = (char)((char)(datestamp) & 0xFF);
	
	int lat1 = (int)(location.coordinate.latitude) + 90;
	update[6] = (char)((char)(lat1 >> 8) & 0xFF);
	update[7] = (char)((char)(lat1) & 0xFF);
	
	double lat = fabs(location.coordinate.latitude);
	lat = lat - (int)lat;
	int lat2 = (int)(lat * 1000000);
	update[8] = (char)((char)(lat2 >> 24) & 0xFF);
	update[9] = (char)((char)(lat2 >> 16) & 0xFF);
	update[10] = (char)((char)(lat2 >> 8) & 0xFF);
	update[11] = (char)((char)(lat2) & 0xFF);
	
	int lng1 = (int)(location.coordinate.longitude) + 180;
	update[12] = (char)((char)(lng1 >> 8) & 0xFF);
	update[13] = (char)((char)(lng1) & 0xFF);
	
	double lng = fabs(location.coordinate.longitude);
	lng = lng - (int)lng;
	int lng2 = (int)(lng * 1000000);
	update[14] = (char)((char)(lng2 >> 24) & 0xFF);
	update[15] = (char)((char)(lng2 >> 16) & 0xFF);
	update[16] = (char)((char)(lng2 >> 8) & 0xFF);
	update[17] = (char)((char)(lng2) & 0xFF);
	
	NSLog(@"Speed: %i", location.speed);
	int spd = 0;
	if(location.speed > 0)
		spd = (int)(location.speed * 3.6); // convert meters/sec to km/h
	update[18] = (char)((char)(spd >> 8) & 0xFF);
	update[19] = (char)((char)(spd) & 0xFF);

	int hdg = 0;
	if(location.course > 0)
		hdg = (int)(location.course);
	update[20] = (char)((char)(hdg >> 8) & 0xFF);
	update[21] = (char)((char)(hdg) & 0xFF);

	int alt = (int)(location.altitude);
	update[22] = (char)((char)(alt >> 8) & 0xFF);
	update[23] = (char)((char)(alt) & 0xFF);
	
	int acc = (int)(location.horizontalAccuracy);
	update[24] = (char)((char)(acc >> 8) & 0xFF);
	update[25] = (char)((char)(acc) & 0xFF);
	
	int bat = 0;
	int bat2 = 0;
	if((bat2=round([UIDevice currentDevice].batteryLevel * 100)) > 0)
		bat = bat2;
	update[26] = (char)((char)(bat >> 8) & 0xFF);
	update[27] = (char)((char)(bat) & 0xFF);

	return [NSData dataWithBytes:update length:28];
}

@end
