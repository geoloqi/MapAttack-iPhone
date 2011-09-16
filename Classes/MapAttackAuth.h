//
//  MapAttackAuth.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-09-03.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MapAttackAuth : NSObject {

}

@property (nonatomic, retain) NSString *refreshToken;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *initials;

+ (MapAttackAuth *)create;

@end
