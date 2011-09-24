//
//  Database.h
//  MapAttack
//
//  Created by Deepa Bhan on 9/14/11.
//  Copyright 2011 Geoloqi LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface Database : NSObject
{
    //sqlite3 *db;
}
-(NSString *) filePath;

-(void) openDB: (sqlite3 **) db;

-(void) createTableNamed:(NSString*) tableName 
              withField1:(NSString*) field1 
               andField2:(NSString*) field2 
                database:(sqlite3*) db;

-(void) insertRecordIntoTableNamed:(NSString *) 
              tableName withField1:(NSString *) field1 
                       field1Value:(uint32_t) field1Value 
                         andField2:(NSString *) field2 
                       field2Value:(NSData *) field2Value
                          database:(sqlite3 *) db;
@end
