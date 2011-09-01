//
//  LQClient.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";
static NSString *const LQAuthenticationFailedNotification = @"LQAuthenticationFailedNotification";
static NSString *const LQRefreshTokenKey = @"LQRefreshToken";
static NSString *const LQAPIBaseURL = @"https://api.geoloqi.com/";

typedef void (^LQHTTPRequestCallback)(NSError *error, NSDictionary *response);

@interface LQClient : NSObject {

}

@property (nonatomic, retain) NSString *accessToken;

+ (LQClient *)single;
- (BOOL)isLoggedIn;
- (void)sendPushToken:(NSString *)token;
- (void)getNearbyLayers:(LQHTTPRequestCallback)callback;
- (void)createNewAccountWithEmail:(NSString *)email initials:(NSString *)initials callback:(LQHTTPRequestCallback)callback;

@end
