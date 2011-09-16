//
//  MapAttackAppDelegate.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "MapAttackAppDelegate.h"
#import "CJSONSerializer.h"

@implementation MapAttackAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the tab bar controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];

	[MapAttackAppDelegate getUUID];
	
	geoloqi = [[GeoloqiSocketClient alloc] init];
	
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"Received Push! %@", userInfo);
	
	// Push was received while the app was in the foreground
	if(application.applicationState == UIApplicationStateActive) {
		NSDictionary *data = [userInfo valueForKeyPath:@"mapattack"];
		if(data) {
			NSLog(@"Got some location data! Yeah!!");
			
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    // Get a hex string from the device token with no spaces or < >
    deviceToken = [[[[_deviceToken description]
						  stringByReplacingOccurrencesOfString: @"<" withString: @""] 
						 stringByReplacingOccurrencesOfString: @">" withString: @""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSLog(@"Device Token: %@", deviceToken);
	
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		NSLog(@"Notifications are disabled for this application. Not registering.");
		return;
	}
}

+ (NSString *)getUUID {
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"] == nil) {
		CFUUIDRef theUUID = CFUUIDCreate(NULL);
		CFStringRef string = CFUUIDCreateString(NULL, theUUID);
		CFRelease(theUUID);
		[[NSUserDefaults standardUserDefaults] setObject:(NSString *)string forKey:@"uuid"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"Generating new UUID: %@", string);
		return [(NSString *)string autorelease];
	} else {
		NSLog(@"Returning existing UUID: %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"]);
		return [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
	}
}

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


- (void)dealloc {
	[geoloqi release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

