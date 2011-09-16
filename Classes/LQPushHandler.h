//
//  LQPushHandler.h
//  Geoloqi
//
//  Created by Aaron Parecki on 12/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
	kLQPushAlertGeonote = 0,
	kLQPushAlertShutdown,
	kLQPushAlertStart
};

@interface LQPushHandler : NSObject <UIAlertViewDelegate> {
	NSString *lastAlertURL;
}

@property (nonatomic, retain) NSString *lastAlertURL;

- (id)myInit;
- (void)handlePush:(UIApplication *)application notification:(NSDictionary *)userInfo;
- (void)handleLocalNotificationFromApp:(UIApplication *)app notif:(UILocalNotification *)notif;
- (void)handleLaunch:(NSDictionary *)launchOptions;

@end
