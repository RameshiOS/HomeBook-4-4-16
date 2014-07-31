//
//  PropertiesDataBaseManager.h
//  Properties
//
//  Created by Manulogix on 21/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//http://pragmaticstudio.com/blog/2010/9/23/install-rails-ruby-mac
//http://matthom.com/archive/2009/06/14/installing-mysql-mac-os-x
//http://www.entropy.ch/software/macosx/mysql/

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <QuartzCore/QuartzCore.h>
#import "FAUtilities.h"

@interface DataBaseManager : NSObject<UIAlertViewDelegate>{
	NSString* _dataBasePath;
	sqlite3 *_database;
	BOOL copyDb;
    NSString* dbName;
}

+(DataBaseManager*)dataBaseManager;

-(NSString*) getDBPath;
-(void)openDatabase;

//-(BOOL)createDatabase;
-(BOOL)execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)execute:(NSString*)sqlStatement;

-(NSInteger)getScalar:(NSString*)sqlStatement;
-(NSString*)getValue:(NSString*)sqlStatement;
@end
