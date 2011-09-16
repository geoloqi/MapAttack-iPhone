//
//  MapAttackAppDelegate.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoloqiSocketClient.h"
#import "MapAttack.h"
#import "LQClient.h"
#import "AuthView.h"
#import "MapViewController.h"

static NSString *const LQUUIDKey = @"LQUUID";

@interface MapAttackAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	GeoloqiSocketClient *socketClient;
	LQClient *geoloqi;
	NSString *deviceToken;
}

@property (nonatomic, retain) GeoloqiSocketClient *socketClient;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AuthView *authViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) LQClient *geoloqi;
@property (nonatomic, retain) IBOutlet MapViewController *mapController;

+(NSData *)UUID;
-(void)loadGameWithURL:(NSString *)url;

@end

extern MapAttackAppDelegate *lqAppDelegate;
