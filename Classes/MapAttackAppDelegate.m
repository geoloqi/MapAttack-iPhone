//
//  MapAttackAppDelegate.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "MapAttackAppDelegate.h"
#import "CJSONSerializer.h"

MapAttackAppDelegate *lqAppDelegate;

@implementation MapAttackAppDelegate

@synthesize window;
@synthesize tabBarController, authViewController;
@synthesize geoloqi;
@synthesize mapController;

#pragma mark Application launched
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	lqAppDelegate = self;

	DLog(@"App Launch %@", launchOptions);

    // Override point for customization after application launch.

    // Add the tab bar controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];

	[MapAttackAppDelegate UUID];
	
	socketClient = [[GeoloqiSocketClient alloc] init];
	self.geoloqi = [[LQClient alloc] init];

	if([[LQClient single] isLoggedIn]) {
		// Start sending location updates
		[socketClient startMonitoringLocation];

		[[UIApplication sharedApplication]
		 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
											 UIRemoteNotificationTypeSound |
											 UIRemoteNotificationTypeAlert)];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(authenticationDidSucceed:)
													 name:LQAuthenticationSucceededNotification
												   object:nil];
	}
	
    return YES;
}

#pragma mark Logged in Successfully
- (void)authenticationDidSucceed:(NSNotificationCenter *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationSucceededNotification 
                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self 
//                                                    name:LQAuthenticationFailedNotification 
//                                                  object:nil];
	
    if (tabBarController.modalViewController && [tabBarController.modalViewController isKindOfClass:[authViewController class]])
        [tabBarController dismissModalViewControllerAnimated:YES];
	
	// Register for push notifications after logging in successfully
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];
	
	[self.mapController loadURL:@""];
	
	// Start sending location updates
	[socketClient startMonitoringLocation];
}

#pragma mark Push token registered
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    // Get a hex string from the device token with no spaces or < >
    deviceToken = [[[[_deviceToken description]
					 stringByReplacingOccurrencesOfString: @"<" withString: @""] 
					stringByReplacingOccurrencesOfString: @">" withString: @""] 
				   stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	DLog(@"Device Token: %@", deviceToken);
	
	[[LQClient single] sendPushToken:deviceToken withCallback:^(NSError *error, NSDictionary *response){
		DLog(@"Sent device token: %@", response);
	}];
	
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		DLog(@"Notifications are disabled for this application. Not registering.");
		return;
	}
}

#pragma mark Received push notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	DLog(@"Received Push! %@", userInfo);
	
	// Push was received while the app was in the foreground
	if(application.applicationState == UIApplicationStateActive) {
		NSDictionary *data = [userInfo valueForKeyPath:@"mapattack"];
		if(data) {
			DLog(@"Got some location data! Yeah!!");
			
			// The data in the push notification is already an NSDictionary, we need to serialize it to JSON
			// format to pass to the web view.
			
			NSDictionary *json = [NSDictionary dictionaryWithObject:[[CJSONSerializer serializer] serializeObject:userInfo] forKey:@"json"];
			[[NSNotificationCenter defaultCenter] postNotificationName:LQMapAttackDataNotification
																object:self
															  userInfo:json];
			return;
		}
	}
	
}

#pragma mark -

-(void)loadGameWithURL:(NSString *)url {
	[tabBarController setSelectedIndex:1];
	DLog(@"MapAttackAppDelegate loadGameWithURL:%@", url);
	[self.mapController loadURL:url];
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark -


+ (NSData *)UUID {
	if([[NSUserDefaults standardUserDefaults] dataForKey:LQUUIDKey] == nil) {
		CFUUIDRef theUUID = CFUUIDCreate(NULL);
		CFUUIDBytes bytes = CFUUIDGetUUIDBytes(theUUID);
		NSData *dataUUID = [NSData dataWithBytes:&bytes length:sizeof(CFUUIDBytes)];
		CFRelease(theUUID);
		[[NSUserDefaults standardUserDefaults] setObject:dataUUID forKey:LQUUIDKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		DLog(@"Generating new UUID: %@", dataUUID);
		return dataUUID;
	} else {
		DLog(@"Returning existing UUID: %@", [[NSUserDefaults standardUserDefaults] dataForKey:LQUUIDKey]);
		return [[NSUserDefaults standardUserDefaults] dataForKey:LQUUIDKey];
	}
}

- (void)dealloc {
	[geoloqi release];
	[socketClient release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

