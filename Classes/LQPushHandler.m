//
//  LQPushHandler.m
//  Geoloqi
//
//  Created by Aaron Parecki on 12/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQPushHandler.h"
#import "CJSONSerializer.h"
#import "MapAttack.h"
#import "MapAttackAppDelegate.h"

@implementation LQPushHandler

@synthesize lastAlertURL;

- (id)myInit {
	self = [super init];
	lastAlertURL = [[NSString alloc] init];
	NSLog(@"Alloc url: %@", lastAlertURL);
	return self;
}

/**
 * This is called from application: didReceiveRemoteNotification: which is called regardless of whether 
 * the app is in the foreground or background, but only if it is currently running.
 */
- (void)handlePush:(UIApplication *)application notification:(NSDictionary *)userInfo {
	NSString *title;
	
	// Push was received while the app was in the foreground
	if(application.applicationState == UIApplicationStateActive) {
		NSDictionary *location = [userInfo valueForKeyPath:@"lqloc"];
		if(location) {
			NSLog(@"Got some location data! Yeah!!");
			
			NSDictionary *json = [NSDictionary dictionaryWithObject:[[CJSONSerializer serializer] serializeObject:userInfo] forKey:@"json"];
			[[NSNotificationCenter defaultCenter] postNotificationName:LQMapAttackDataNotification
																object:self
															  userInfo:json];
			return;
		}
	}
	
	NSString *type = [userInfo valueForKeyPath:@"geoloqi.type"];
	
	if(type && [@"geonote" isEqualToString:type]) {
		title = @"MapAttack";
	} else if(type && [@"message" isEqualToString:type]) {
		title = @"MapAttack";
	} else {
		title = @"MapAttack";
	}
	
	if([type isEqualToString:@"shutdownPrompt"]){
		if([application applicationState] == UIApplicationStateActive) {
			// Received a push notification asking the user if they want to shut off location updates.
			// If updates have already been turned off, don't bother actually prompting this.
			if([[lqAppDelegate socketClient] locationUpdateState]){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
																message:[userInfo valueForKeyPath:@"aps.alert.body"]
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes", nil];
				[alert setTag:kLQPushAlertShutdown];
				[alert show];
				[alert release];
			}
		} else {
			[[lqAppDelegate socketClient] stopMonitoringLocation];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geoloqi"
															message:@"Location tracking is off"
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"Ok", nil];
			[alert show];
			[alert release];
		}
	} else if([type isEqualToString:@"startPrompt"]) {
		if([application applicationState] == UIApplicationStateActive) {
			// Received a push notification asking the user if they want to turn on location updates.
			// If updates are already on, don't bother actually prompting this.
			if([[lqAppDelegate socketClient] locationUpdateState] == NO){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
																message:[userInfo valueForKeyPath:@"aps.alert.body"]
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes", nil];
				[alert setTag:kLQPushAlertStart];
				[alert show];
				[alert release];
			} else {
				[[lqAppDelegate socketClient] startMonitoringLocation];
			}
		}
	} else {
		if([userInfo valueForKeyPath:@"aps.alert.body"] != nil) {
			UIAlertView *alert;
			if([userInfo valueForKeyPath:@"geoloqi.link"] != nil) {
				alert = [[UIAlertView alloc] initWithTitle:title 
												   message:[userInfo valueForKeyPath:@"aps.alert.body"] 
												  delegate:self
										 cancelButtonTitle:@"Close"
										 otherButtonTitles:@"View", nil];
				self.lastAlertURL = [userInfo valueForKeyPath:@"geoloqi.link"];
				NSLog(@"Storing value in lastAlertURL: %@", lastAlertURL);
			} else {
				alert = [[UIAlertView alloc] initWithTitle:title 
												   message:[userInfo valueForKeyPath:@"aps.alert.body"] 
												  delegate:self
										 cancelButtonTitle:nil
										 otherButtonTitles:@"Ok", nil];
				self.lastAlertURL = nil;
			}
			if([application applicationState] == UIApplicationStateActive) {
				[alert show];
				[alert setTag:kLQPushAlertGeonote];
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.lastAlertURL]];
			}
			[alert release];
		}	
	}
}

- (void)handleLocalNotificationFromApp:(UIApplication *)app notif:(UILocalNotification *)notif {
	// A local notification came in but the app was in the foreground. This method is called immediately,
	// so we need to show them the alert and handle the response appropriately.
	
	if([app applicationState] == UIApplicationStateActive){
		// Don't prompt if tracking is already off. Probably won't happen anymore since the timers are cancelled when tracking is turned off.
		if([[lqAppDelegate socketClient] locationUpdateState]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[notif.userInfo objectForKey:@"title"]
															message:[notif.userInfo objectForKey:@"description"]
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:notif.alertAction, nil];
			[alert show];
			[alert setTag:kLQPushAlertShutdown];
			[alert release];
		}
	} else {
		// The app just launched and it was running in the background. If they hit "Yes" then shut off updates
		[[lqAppDelegate socketClient] stopMonitoringLocation];
	}
}

/**
 * This is called when the app is launched from the button on a push notification
 */
- (void)handleLaunch:(NSDictionary *)launchOptions {
	
	NSLog(@"---- Handling launch from push notification");
	
	NSDictionary *data = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if(data == nil)
		return;
	
	NSString *type = [data valueForKeyPath:@"geoloqi.type"];
	
	if([type isEqualToString:@"startPrompt"]){
		
		[[lqAppDelegate socketClient] startMonitoringLocation];
		lqAppDelegate.tabBarController.selectedIndex = 1;
		
	}else if([type isEqualToString:@"shutdownPrompt"]){
		
		[[lqAppDelegate socketClient] stopMonitoringLocation];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MapAttack"
														message:@"Location tracking is off"
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Ok", nil];
		[alert show];
		[alert release];
	}else{
		if([data valueForKeyPath:@"geoloqi.link"] != nil) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[data valueForKeyPath:@"geoloqi.link"]]];
		}
	}
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"URL: %@", lastAlertURL);
	
	switch([alertView tag]) {
		case kLQPushAlertShutdown:
			if(buttonIndex == 1){
				// Shut off location tracking now
				[[lqAppDelegate socketClient] stopMonitoringLocation];
			}
			break;
		case kLQPushAlertStart:
			if(buttonIndex == 1){
				// Turn on location tracking now
				[[lqAppDelegate socketClient] startMonitoringLocation];
			}
			break;
		case kLQPushAlertGeonote:
			if(buttonIndex == 1){
				// Clicked "view" and the push contained a link, so open a web browser
				NSLog(@"User clicked View, reading the value from lastAlertURL");
				NSLog(@"Value: %@", self.lastAlertURL);
				if(self.lastAlertURL != nil) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.lastAlertURL]];
				}
			}
	}
}

- (void)dealloc {
	[lastAlertURL release];
	[super dealloc];
}

@end
