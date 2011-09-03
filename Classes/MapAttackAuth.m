//
//  MapAttackAuth.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-09-03.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "MapAttackAuth.h"
#import "LQClient.h"

@implementation MapAttackAuth

@synthesize refreshToken, email, initials;

+ (MapAttackAuth *)create {
	MapAttackAuth *auth = [[MapAttackAuth alloc] init];
	auth.refreshToken = [[NSUserDefaults standardUserDefaults] stringForKey:LQRefreshTokenKey];
	auth.email = [[NSUserDefaults standardUserDefaults] stringForKey:LQAuthEmailAddressKey];
	auth.initials = [[NSUserDefaults standardUserDefaults] stringForKey:LQAuthInitialsKey];
	return [auth autorelease];
}

@end
