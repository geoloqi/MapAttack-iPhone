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
#import "LQConfig.h"
#import "MapAttackAppDelegate.h"

#define TIMEOUT_SEC 6.0
#define TAG_DEVICE_ID_SENT 1
#define TAG_MESSAGE_RECEIVED 2

#define VERBOSE 0

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
	
    DLog(@"[Read] Connecting to %@:%i", host, port);
    
	if (![asyncSocket connectToHost:host onPort:port withTimeout:1 error:&error])
	{
		DLog(@"[Read] Error connecting: %@", error);
	}
    else
    {
		const unsigned *tokenBytes = [[MapAttackAppDelegate UUID] bytes];
		NSString *hexDeviceID = [NSString stringWithFormat:@"%08x%08x%08x%08x",
								 ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]), ntohl(tokenBytes[3])];	

		NSData *data = [hexDeviceID dataUsingEncoding:NSASCIIStringEncoding];
		DLog(@"[Read] Writing device id: %@", data);
		[asyncSocket writeData:data withTimeout:TIMEOUT_SEC tag:TAG_DEVICE_ID_SENT];
    }	
}

- (void)reconnect
{
	DLog(@"[Read] Reconnecting to socket...");
	[self disconnect];
	[self normalConnect];
}

// After the client finishes writing the UUID, start listening for new data
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if(VERBOSE)
		DLog(@"[Read] Did write data with tag %d", tag);
	[asyncSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:TAG_MESSAGE_RECEIVED];
}

- (void)playCoinSound {
	if(!ding) {
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pop" ofType:@"aiff"]], &ding);
	}
	AudioServicesPlaySystemSound(ding);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	DLog(@"DING!");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if(VERBOSE)
		DLog(@"[Read] Did read data with tag %d: %@", tag, data);
	
	if([data isEqualToData:[@"ok\r\n" dataUsingEncoding:NSUTF8StringEncoding]]) {
		if(VERBOSE)
			DLog(@"[Read] Got 'ok' response");
		[asyncSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:TAG_MESSAGE_RECEIVED];
		return;
	}
	
	NSError **err;
	NSDictionary *dict;
	
	// DLog(@"[Read] String: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	
	dict = [[CJSONDeserializer deserializer] deserialize:data error:err];
	DLog(@"[Read] Message: %@", dict);
	
	if([dict objectForKey:@"mapattack"] != nil && [[dict objectForKey:@"mapattack"] objectForKey:@"scores"] != nil) {
		/*
		// Find this user's scores in the array
		NSDictionary *scores = [[dict objectForKey:@"mapattack"] objectForKey:@"scores"];
		if([scores objectForKey:[[LQClient single] userID]] != nil) {
			NSLog(@"Score: %@", [scores objectForKey:[[LQClient single] userID]]);
			UITabBarItem *tbi = (UITabBarItem *)[lqAppDelegate.tabBarController.tabBar.items objectAtIndex:1];
			tbi.badgeValue = [NSString stringWithFormat:@"%@", [scores objectForKey:[[LQClient single] userID]]];
		} else {
			DLog(@"Didn't find score for user %@", [[LQClient single] userID]);
		}
		 */
		
	} else if([dict objectForKey:@"aps"] == nil) {
		// Custom push data, pass off to the web view
		NSDictionary *json = [NSDictionary dictionaryWithObject:[[CJSONSerializer serializer] serializeObject:dict] forKey:@"json"];
		[[NSNotificationCenter defaultCenter] postNotificationName:LQMapAttackDataNotification
															object:self
														  userInfo:json];

		// Player captured a coin!
		if([dict objectForKey:@"mapattack"] != nil && [[[dict objectForKey:@"mapattack"] objectForKey:@"triggered_user_id"] isEqualToString:[[LQClient single] userID]]) {
			[self playCoinSound];
		}
		// Game is over. Shut down sockets. Javascript will handle redirecting to a "game over" screen.
		if([dict objectForKey:@"mapattack"] != nil && [[[dict objectForKey:@"mapattack"] objectForKey:@"gamestate"] isEqualToString:@"done"]) {
			// Game over! Stop tracking, close socket.
			[lqAppDelegate.socketClient stopMonitoringLocation];
			[self disconnect];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MapAttack!"
															message:@"Game Over!"
														   delegate:self
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}

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
    DLog(@"[Read] Connected on local host:%@ port:%hu", [sock localHost], [sock localPort]);
}


@end
