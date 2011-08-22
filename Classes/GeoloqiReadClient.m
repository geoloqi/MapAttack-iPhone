//
//  GeoloqiReadClient.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-21.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "GeoloqiReadClient.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "MapAttack.h"

#define TIMEOUT_SEC 6.0
#define TAG_DEVICE_ID_SENT 1
#define TAG_MESSAGE_RECEIVED 2


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

// After the client finishes writing the UUID, start listening for new data
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog(@"Did write data with tag %d", tag);
	[asyncSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:TAG_MESSAGE_RECEIVED];
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSLog(@"Did read data with tag %d: %@", tag, data);
	NSError **err;
	NSDictionary *dict;
	
	dict = [[CJSONDeserializer deserializer] deserialize:data error:err];
	NSLog(@"Message: %@", dict);
	
	if([dict objectForKey:@"aps"] == nil) {
		// Custom push data, pass off to the web view
		NSDictionary *json = [NSDictionary dictionaryWithObject:[[CJSONSerializer serializer] serializeObject:dict] forKey:@"json"];
		[[NSNotificationCenter defaultCenter] postNotificationName:LQMapAttackDataNotification
															object:self
														  userInfo:json];
	} else {
		// Push notification, create an alert!
		NSString *message = nil;
		id alert;
		if((alert = [[dict objectForKey:@"aps"] objectForKey:@"alert"]) != nil) {
			if([alert isKindOfClass:[NSString class]]) {
				message = alert;
			} else if([alert isKindOfClass:[NSDictionary class]] && [alert objectForKey:@"body"] != nil) {
				message = [alert valueForKey:@"body"];
			}
			
			if(message != nil) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MapAttack!"
																message:message
															   delegate:self
													  cancelButtonTitle:@"Ok"
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
	}
	
	[asyncSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:TAG_MESSAGE_RECEIVED];
}

- (void)disconnect 
{
	[asyncSocket disconnect];
}


#pragma mark  -

- (void) socket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected on local host:%@ port:%hu", [sock localHost], [sock localPort]);
}


@end
