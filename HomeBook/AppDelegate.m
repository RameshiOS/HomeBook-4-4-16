//
//  AppDelegate.m
//  HomeBook
//
//  Created by Manulogix on 13/06/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // for handling memory pressure
    int cacheSizeMemory = 0; // 16MB
    int cacheSizeDisk = 0; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    // memory pressure end
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"YES" forKey:@"IsLaunching"];
        [standardUserDefaults setObject:@"YES" forKey:@"IsLaunchingSignUp"];
        [standardUserDefaults synchronize];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError* error = nil;
    
    if (![fileManager fileExistsAtPath:rhmDir]){
        [fileManager createDirectoryAtPath:rhmDir withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    dbManager = [DataBaseManager dataBaseManager];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'LoginDetails'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'LoginUserName' TEXT NOT NULL , 'Password' TEXT,'CurrentUser' TEXT,'UserID' TEXT,'User_Type' TEXT,'Family' TEXT)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Interested_users'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'SignupEmail' TEXT NOT NULL , 'Name' TEXT,'CurrentUser' TEXT,'Phone' TEXT)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'House'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,ServerID INTEGER,'Name' TEXT NOT NULL , 'Description' TEXT,'Address' TEXT,'SyncStatus' TEXT,'ServerTimeStamp' TEXT,'UserID' TEXT)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Room'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,ServerID INTEGER,'HouseID' INTEGER NOT NULL ,'Name' TEXT NOT NULL ,'Description' TEXT,'Type' TEXT,'SyncStatus' TEXT,'ServerTimeStamp' TEXT)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Item'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,ServerID INTEGER,'RoomID' INTEGER NOT NULL,'HouseID' INTEGER NOT NULL ,'Name' TEXT NOT NULL ,'Description' TEXT,'Category' TEXT,'DatePurchase' TEXT,'InvoiceNum' TEXT,'Manufacturer' TEXt, 'Cost' TEXT,'Brand' TEXT,'Model' TEXT,'Condition' TEXT,'Quantity' TEXT,'Status' TEXT,'YearMade' TEXT,'MaterialMade' TEXT,'Shape' TEXT,'Color' TEXT,'IsTaxable' TEXT,'IsInsured' TEXT,'SoldTo' TEXT,'SoldDate' TEXT,'SoldPrice' TEXT,'WarrantyExpire' TEXT,'WarrantyInfo' TEXT,'InsuredBy' TEXT,'InsuredPolicy' TEXT,'LeaseStartDate' TEXT,'LeaseEndDate' TEXT,'LeaseDesc' TEXT,'ReplacementCost' TEXT,'SerialNum' TEXT,'PlacedInService' TEXT,'UsePercentage' TEXT,'SalvageValue' TEXT,'DepreciationMethod' TEXT,'Beneficiary' TEXT,'LifeInYears' TEXT, 'Comments' TEXT,'Size' TEXT,'CurrentValue' TEXT,'PdfLink' TEXT,'PdfPath' TEXT,'SyncStatus' TEXT,'ServerTimeStamp' TEXT)", nil]];//Divya
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Item_Status'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'Status' TEXT NOT NULL ,'Status_ID' INTEGER)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'RoomType'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'Type' TEXT NOT NULL ,'Description' TEXT,'RoomType_ID' INTEGER)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Item_Category'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'Name' TEXT NOT NULL ,'Description' TEXT,'Category_ID' INTEGER)", nil]];
    
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Item_Condition'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'Type' TEXT NOT NULL ,'Description' TEXT,'Condition_ID' INTEGER)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Lease'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,ServerID INTEGER,'SyncStatus' TEXT,'HouseID' INTEGER NOT NULL ,'RoomID' INTEGER ,'ItemID' INTEGER ,'StartDate' TEXT,'EndDate' TEXT,'Description' TEXT)", nil]];
    
    [dbManager execute:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'Images'(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'HouseID' INTEGER NOT NULL ,'RoomID' INTEGER ,'ItemID' INTEGER ,'ImagePath' TEXT,'ImageData' TEXT,'FileName' TEXT,'ServerPath' TEXT,ServerID INTEGER,'SyncStatus' TEXT)", nil]];
//        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FAUtilities addSkipBackupAttributeToPath:rhmDir];

    // Override point for customization after application launch.
    return YES;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"Application recived memory warning ");
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
     NSLog(@"Cache cleared");
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
