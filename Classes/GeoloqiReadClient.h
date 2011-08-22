//
//  GeoloqiReadClient.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-21.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

#define LQ_READ_SOCKET_HOST @"localhost"
#define LQ_READ_SOCKET_PORT 40001

@interface GeoloqiReadClient : NSObject {
	AsyncSocket *asyncSocket;

}

- (void)normalConnect;
- (void)disconnect;

@end
