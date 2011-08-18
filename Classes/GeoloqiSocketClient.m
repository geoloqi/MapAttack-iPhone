//
//  GeoloqiSocketClient.m
//
//  Created by Aaron Parecki on 4/9/11.
//  Copyright 2011 Geoloqi LLC. All rights reserved.
//

#import "GeoloqiSocketClient.h"
#import "CJSONDeserializer.h"
#import "LQConstants.h"
#import "AsyncUdpSocket.h"

#define TIMEOUT_SEC 6.0
#define TAG_DEVICE_ID_SENT 1

#if LITTLE_ENDIAN

#pragma pack(push)  /* push current alignment to stack */
#pragma pack(1)     /* set alignment to 1 byte boundary */

typedef union {
	struct {
		unsigned char command;
		uint32_t date;
		uint32_t lat;
		uint32_t lon;
		uint16_t speed;
		uint16_t heading;
		uint16_t altitude;
		uint16_t accuracy;
		uint16_t batteryPercent;
		unsigned char uuid[16];
	} f;
	char bytes[39];
} LQUpdatePacket;

#pragma pack(pop)  /* push current alignment to stack */

#endif

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
	if (![asyncSocket connectToHost:LQ_SOCKET_HOST onPort:LQ_SOCKET_PORT error:&error])
	{
		NSLog(@"Error connecting: %@", error);
	}
}

#pragma mark  -



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
			[asyncSocket sendData:data toHost:LQ_SOCKET_HOST port:LQ_SOCKET_PORT withTimeout:10.0 tag:TAG_DEVICE_ID_SENT];
			//Look for ack back
			[asyncSocket receiveWithTimeout:30.0 tag:TAG_DEVICE_ID_SENT];
			
		} else {
#if LQ_LOCMAN_DEBUG
			NSLog(@"Location update (to %@; from %@) rejected", newLocation, oldLocation);
#endif
		}
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
{
	NSLog(@"did send");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
	NSLog(@"did not get ack back");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port;
{
	//TODO: determine if this is a valid packet
	NSLog(@"Recieved packet back from server: %@", data);
	
	if (data.length == sizeof(uint32_t)) {
		uint32_t time = OSSwapBigToHostInt32(*(uint32_t *)data.bytes);
		NSLog(@"Accepted packet with timestamp: %u", time);
		return YES;
	} else {
		NSLog(@"packet invalid size: %d", data.length);
		return NO;
	}
}

- (NSData *)dataFromLocation:(CLLocation *)location {
	// See documentation at https://developers.geoloqi.com/api/Streaming_API
	
	// Create a new byte array
	LQUpdatePacket update;
		
	update.f.command = 65;
	
	update.f.date = (uint32_t)[[NSDate date] timeIntervalSince1970];
	//Scale to [0, 1), then scale to [0, 2^32)
	update.f.lat  = (uint32_t)(((location.coordinate.latitude  + 90.0) / 180.0) * 0xffffffff);
	update.f.lon  = (uint32_t)(((location.coordinate.longitude + 180.0) / 360.0) * 0xffffffff);
	
	// convert meters/sec to km/h
	update.f.speed = location.speed > 0 ? (uint16_t)location.speed * 3.6: 0;
	//Represent heading as unsigned 0...360
	update.f.heading = (uint16_t)(MAX(0, location.course)); 
	
	update.f.altitude = MAX(0, (int)(location.altitude));
	update.f.accuracy = (uint16_t)(MAX(0, (int)(location.horizontalAccuracy)));
	//battery percent
	update.f.batteryPercent = (uint16_t)(round(MAX(0.0f, [UIDevice currentDevice].batteryLevel) * 100.0));
	
	memset(update.f.uuid, 0x0, sizeof(update.f.uuid));
	
//	NSLog(@"Size of packet: %lu", sizeof(LQUpdatePacket));
//	NSLog(@"Offset of command: %lu", offsetof(LQUpdatePacket, f.command));
//	NSLog(@"Offset of date: %lu", offsetof(LQUpdatePacket, f.date));
	
	NSLog(@"Sending timestamp: %d", update.f.date);
	
	//Swap endianness of each 16 bit int
	update.f.date           = OSSwapHostToBigInt32(update.f.date);
	update.f.lat            = OSSwapHostToBigInt32(update.f.lat);
	update.f.lon            = OSSwapHostToBigInt32(update.f.lon);
	update.f.speed          = OSSwapHostToBigInt16(update.f.speed);
	update.f.heading        = OSSwapHostToBigInt16(update.f.heading);
	update.f.altitude       = OSSwapHostToBigInt16(update.f.altitude);
	update.f.accuracy       = OSSwapHostToBigInt16(update.f.accuracy);
	update.f.batteryPercent = OSSwapHostToBigInt16(update.f.batteryPercent);	

	return [NSData dataWithBytes:update.bytes length:sizeof(update.bytes)];
}

@end
