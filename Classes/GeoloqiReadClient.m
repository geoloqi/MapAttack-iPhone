//
//  GeoloqiReadClient.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-21.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "GeoloqiReadClient.h"

#define TIMEOUT_SEC 6.0
#define TAG_DEVICE_ID_SENT 1


@implementation GeoloqiReadClient

- (id)init
{
    if (self = [super init])
    {
		// Change to use UDP
        asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [self normalConnect];    
    }
    
    return self;
}

- (void)normalConnect
{
	NSError *error = nil;
	
	NSString *host = LQ_READ_SOCKET_HOST;
    UInt16 port = LQ_READ_SOCKET_PORT;
	
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
    NSLog(@"Connected on local host:%@ port:%hu", [sock localHost], [sock localPort]);
}


@end
