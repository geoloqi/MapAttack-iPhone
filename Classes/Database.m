//
//  Database.m
//  MapAttack
//
//  Created by Deepa Bhan on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

@implementation Database

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// File path for the database location
- (NSString *) filePath 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"LQdatabase.sql"];
}

// Database Create function
- (void) openDB :(sqlite3 **) db
{
    // --create database
    if (sqlite3_open([[self filePath] UTF8String], db) != SQLITE_OK)
    {
        sqlite3_close(*db);
        NSAssert(0, @"Database failed to open.");
    }
    else
    {
        NSLog(@"Successfully opened the database");
    }
}


// Creating Tables
-(void) createTableNamed:(NSString*) tableName
              withField1:(NSString*) field1           
               andField2:(NSString*) field2 
                database:(sqlite3 *) db
{
    char *err;
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' (ID INTEGER PRIMARY KEY, '%@' INTEGER, '%@' BLOB);" ,
                     tableName, field1, field2];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(0, @"Table failed to be created");
    }    
}

// Inserting Data Rows
-(void) insertRecordIntoTableNamed:(NSString *) tableName 
                        withField1:(NSString *) field1 
                       field1Value:(uint32_t) field1Value 
                         andField2:(NSString *) field2 
                       field2Value:(NSData *) field2Value
                          database:(sqlite3 *) db
{
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@') VALUES (?,?)",
                        tableName, field1, field2];
    const char* sql = [sqlStr UTF8String];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_int(statement, 1, field1Value);
        sqlite3_bind_blob(statement, 2, [field2Value bytes], [field2Value length], SQLITE_TRANSIENT);        
    }
    if(sqlite3_step(statement) != SQLITE_DONE)
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating the table.");
    }
    sqlite3_finalize(statement);
}


@end
