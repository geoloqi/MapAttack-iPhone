//
//  LQClient.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";
static NSString *const LQAuthenticationFailedNotification = @"LQAuthenticationFailedNotification";
static NSString *const LQAccessTokenKey = @"LQAccessToken";
static NSString *const LQAuthEmailAddressKey = @"LQAuthEmailAddressKey";
static NSString *const LQAuthInitialsKey = @"LQAuthInitialsKey";
static NSString *const LQAPIBaseURL = @"https://api.geoloqi.com/1/";

typedef void (^LQHTTPRequestCallback)(NSError *error, NSDictionary *response);

@interface LQClient : NSObject {
//	NSMutableArray *queue;
//	ASIHTTPRequest *authenticationRequest;
}

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *userInitials;

@property (nonatomic, copy) NSString *shareToken;

+ (LQClient *)single;
- (BOOL)isLoggedIn;
// - (NSString *)refreshToken;
- (void)sendPushToken:(NSString *)token withCallback:(LQHTTPRequestCallback)callback;
- (void)getNearbyLayers:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback;
- (void)getPlaceContext:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback;
- (void)createNewAccountWithEmail:(NSString *)email initials:(NSString *)initials callback:(LQHTTPRequestCallback)callback;
- (void)joinGame:(NSString *)layer_id withToken:(NSString *)group_token;
- (void)logout;

@end

