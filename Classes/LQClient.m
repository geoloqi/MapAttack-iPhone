//
//  LQClient.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQClient.h"
#import "LQConfig.h"
#import "MapAttack.h"
#import "CJSONDeserializer.h"

static LQClient *singleton = nil;

@implementation LQClient

@synthesize accessToken;

+ (LQClient *)single {
    if(!singleton) {
		singleton = [[self alloc] init];
	}
	return singleton;
}

- (void)dealloc {
	[accessToken release];
	[super dealloc];
}

- (ASIHTTPRequest *)appRequestWithURL:(NSURL *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
	[request setUsername:LQ_OAUTH_CLIENT_ID];
	[request setPassword:LQ_OAUTH_SECRET];
	return request;
}

- (id)appRequestWithURL:(NSURL *)url class:(NSString *)class {
	id request = [NSClassFromString(class) requestWithURL:url];
	[request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
	[request setUsername:LQ_OAUTH_CLIENT_ID];
	[request setPassword:LQ_OAUTH_SECRET];
	return request;
}

- (ASIHTTPRequest *)userRequestWithURL:(NSURL *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@"]];
	return request;
}

- (NSDictionary *)dictionaryFromResponse:(NSString *)response {
	NSError *err = nil;
	NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[response dataUsingEncoding:NSUTF8StringEncoding] error:&err];
	return res;
}

- (NSURL *)urlWithPath:(NSString *)path {
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", LQAPIBaseURL, path]];
}

#pragma mark public methods

- (BOOL)isLoggedIn {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LQRefreshTokenKey] != nil;	
}

- (void)sendPushToken:(NSString *)token {
	// TODO: Send this device token to the Geoloqi API
}

- (void)createNewAccountWithEmail:(NSString *)email initials:(NSString *)initials callback:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:@"user/create_anon"];
	__block ASIFormDataRequest *request = [self appRequestWithURL:url class:@"ASIFormDataRequest"];
	[request setPostValue:initials forKey:@"name"];
	[request setCompletionBlock:^{
		NSDictionary *responseDict = [self dictionaryFromResponse:[request responseString]];
		[[NSUserDefaults standardUserDefaults] setObject:(NSString *)[responseDict objectForKey:@"refresh_token"] forKey:LQRefreshTokenKey];
		[[NSUserDefaults standardUserDefaults] setObject:email forKey:LQAuthEmailAddressKey];
		[[NSUserDefaults standardUserDefaults] setObject:initials forKey:LQAuthInitialsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		self.accessToken = (NSString *)[responseDict objectForKey:@"access_token"];
		callback(nil, responseDict);
	}];
	[request startAsynchronous];
}

- (void)getNearbyLayers:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"layer/nearby?latitude=45.5246&longitude=-122.6843&application_id=%@", MapAttackAppID]];
	__block ASIHTTPRequest *request = [self appRequestWithURL:url];
	[request setCompletionBlock:^{
		callback(nil, [self dictionaryFromResponse:[request responseString]]);
	}];
	[request startAsynchronous];
}

@end


