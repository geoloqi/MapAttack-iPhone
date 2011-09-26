//
//  GeoloqiReadClient.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-21.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AsyncSocket.h"
#import "Reachability.h"


@interface GeoloqiReadClient : NSObject {
	AsyncSocket *asyncSocket;
	SystemSoundID ding;
}


- (void)normalConnect;
- (void)disconnect;
- (void)reconnect;

@end
