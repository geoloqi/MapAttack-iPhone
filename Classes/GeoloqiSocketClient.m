//
//  GeoloqiSocketClient.m
//
//  Created by Aaron Parecki on 4/9/11.
//  Copyright 2011 Geoloqi LLC. All rights reserved.
//

#import "GeoloqiSocketClient.h"
#import "CJSONDeserializer.h"
#import "LQConfig.h"
#import "AsyncUdpSocket.h"
#import "Reachability.h"
#import "Database.h"
#import "MapAttackAppDelegate.h"

#define TIMEOUT_SEC 6.0
#define TAG_DEVICE_ID_SENT 1

#define VERBOSE 0

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

//#pragma pack(pop)  /* push current alignment to stack */

#endif

@implementation GeoloqiSocketClient

- (id) init
{
    if (self = [super init])
    {
		// Change to use UDP
        asyncSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        distanceFilterDistance = 0.5;
		trackingFrequency = 1;
		sendingFrequency = 1;
		uuid = [[MapAttackAppDelegate UUID] retain];
        // [self normalConnect];
    }
    
    return self;
}

- (void) dealloc
{
	[uuid release];
	[asyncSocket release];
	[locationManager release];
	[geoloqiClient release];
	[super dealloc];
}

- (void) normalConnect
{
	NSError *error = nil;
	
	NSString *host = LQ_WRITE_SOCKET_HOST;
    UInt16 port = LQ_WRITE_SOCKET_PORT;

	DLog(@"[Write] Connecting to %@:%i", host, port);
	
	// Change to use UDP
	if (![asyncSocket connectToHost:LQ_WRITE_SOCKET_HOST onPort:LQ_WRITE_SOCKET_PORT error:&error])
	{
		DLog(@"[Write] Error connecting: %@", error);
	}
}

#pragma mark  -

- (BOOL)locationUpdateState {
	return locationUpdatesOn;
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
	 DLog(@"Significant updates on.");
	 [locationManager stopUpdatingLocation];
	 } else {
	 DLog(@"Starting location updates");
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
    sqlite3_close(db);                      // since we are stopping the location updates the databse can be closed
	//[[NSNotificationCenter defaultCenter] postNotificationName:LQTrackingStoppedNotification object:self];
}

// This is the method called by the OS when a new location update is received
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    
    NSData *raw;
	DLog(@"Updated to location %@ from %@", newLocation, oldLocation);

	// horizontalAccuracy is negative when the location is invalid, so completely ignore it in this case
	if(newLocation.horizontalAccuracy < 0){
		return;
	}
    
    // Only capture points as frequently as the min. tracking interval
	// These checks are done against the last saved location (currentLocation)
	if (YES || !oldLocation || // first update
		([newLocation distanceFromLocation:currentLocation] > distanceFilterDistance && // check min. distance
<<<<<<< HEAD
		 [newLocation.timestamp timeIntervalSinceDate:currentLocation.timestamp] > trackingFrequency)) 
    {
        // currentLocation is always the point that was last accepted into the queue.
        currentLocation = newLocation;
        // Notify observers about the location change
		//[[NSNotificationCenter defaultCenter]
		//postNotificationName:LQLocationUpdateManagerDidUpdateLocationNotification
		//object:self];
        NSData *data = [self dataFromLocation:newLocation];
        NSLog(@"Storing location data: %@", data);

        
        Database *LqDatabase = [Database new];                    // Init Database class
        
        // Trying to extract the timestamp from NSData
        LQUpdatePacket *packet = (LQUpdatePacket *)[data bytes];
        
        // Open the LQDatabase
        [LqDatabase openDB:&db];
        
        [LqDatabase createTableNamed: @"LQ_DATA" withField1:@"TIME_STAMP" andField2:@"DATA_PACKET" database:db];
        [LqDatabase insertRecordIntoTableNamed:@"LQ_DATA"
                                    withField1:@"TIME_STAMP"
                                   field1Value:packet->f.date 
                                     andField2:@"DATA_PACKET" field2Value:data database:db];
       
        //Network Connectivity check -- dhan
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                selector:@selector(handleNetworkChange:) 
                                                name:kReachabilityChangedNotification 
                                                object:nil];
        // Init Reachablility class and ask the notifications to start
        reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        // What is the current connectivity status?
        NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
        
        if(remoteHostStatus == NotReachable) { NSLog(@"No Network Connectivity");}
        else if (remoteHostStatus == ReachableViaWiFi) { NSLog(@"Local Network (WiFi) detected");}
        else if (remoteHostStatus == ReachableViaWWAN) { NSLog(@"Carrier Network Connectivity detected");}
        
        if (remoteHostStatus == ReachableViaWiFi || remoteHostStatus == ReachableViaWWAN)
        {
            // Try to retrieve data from the database
            NSString *qsql = @"SELECT * FROM LQ_DATA ORDER BY ROWID";
            sqlite3_stmt *getStatement;
            if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &getStatement, nil) == SQLITE_OK)
            {
                while (sqlite3_step(getStatement) == SQLITE_ROW)
                {
                    //Loop through all the returned rows
                    int rowId = sqlite3_column_int(getStatement,0);
                    raw = [[NSData alloc] initWithBytes:sqlite3_column_blob(getStatement, 2)
                                                 length:sqlite3_column_bytes(getStatement,2)];
                    NSLog(@"Retrieved location data: %@", raw);
                    NSLog(@"Sending location data now..");
                    // Send out data
                    [asyncSocket sendData:raw toHost:LQ_SOCKET_HOST 
                                     port:LQ_SOCKET_PORT withTimeout:10.0
                                      tag:TAG_DEVICE_ID_SENT];
                    [asyncSocket receiveWithTimeout:30.0 tag:TAG_DEVICE_ID_SENT];
                    [raw release];  // release the allocated memory
                    
                    // Delete rows from the sqlite3 table that you just retrieved
                    NSString *query = [NSString stringWithFormat:@"DELETE FROM LQ_DATA WHERE ROWID = '%i'", rowId]; 
                    if (sqlite3_exec(db, [query UTF8String], NULL, NULL, NULL) != SQLITE_OK)
                    {
                        NSAssert(0, @"Deletion not successful");
                    }
                }
            }
        }
    } else {
        
#if LQ_LOCMAN_DEBUG
			if(VERBOSE)
				DLog(@"[Write] Location update (to %@; from %@) rejected", newLocation, oldLocation);
#endif
		}
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
{
	if(VERBOSE)
		DLog(@"[Write] did send");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
	if(VERBOSE)
		DLog(@"[Write] did not get ack back");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port;
{
	//TODO: determine if this is a valid packet
	if(VERBOSE)
		DLog(@"[Write] Recieved packet back from server: %@", data);
	
	if (data.length == sizeof(uint32_t)) {
        uint32_t time = (*(uint32_t *)data.bytes);
		if(VERBOSE)
			DLog(@"[Write] Accepted packet with timestamp: %u", time);
		return YES;
	} else {
		if(VERBOSE)
			DLog(@"[Write] packet invalid size: %d", data.length);
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
	
	// memset(update.f.uuid, 0x0, sizeof(update.f.uuid));
	if(uuid.length == 16)
		memcpy(update.f.uuid, [uuid bytes], 16);
	else
		memset(update.f.uuid, 0x0, sizeof(update.f.uuid));

		
//	DLog(@"Size of packet: %lu", sizeof(LQUpdatePacket));
//	DLog(@"Offset of command: %lu", offsetof(LQUpdatePacket, f.command));
//	DLog(@"Offset of date: %lu", offsetof(LQUpdatePacket, f.date));
    Dlog(@"The time stamp is %d\n", update.f.date);
	
	// if(VERBOSE)
		DLog(@"[Write] Sending location update %@", [NSData dataWithBytes:update.bytes length:sizeof(update.bytes)]);
	
	//Swap endianness of each 16 bit int
	update.f.date           = OSSwapHostToBigInt32(update.f.date); // Check for issues if any with this line. Think it's needed. -- dbhan
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
