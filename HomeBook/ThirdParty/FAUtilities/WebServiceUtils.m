 //
//  WebServiceUtils.m
//  RoyalHouseManagement
//
//  Created by Manulogix on 18/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "WebServiceUtils.h"
//#import "ContainerViewController.h"
#import "DashBoardViewController.h"

@interface WebServiceUtils ()

@property(nonatomic, strong) UIViewController    *wsiParentVC;


@end

@implementation WebServiceUtils
@synthesize wsiParentVC;
@synthesize delegate;


#pragma mark -
#pragma mark init Methods
-(id) initWithVC: (UIViewController *)parentVC {
    self = [super init];
    if(self) {
        self.wsiParentVC = parentVC; // DO NOT allocate as we should point only
        //        self.delegate    = (id)parentVC; // DO NOT allocate as we should point only
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tempRespDic = [[NSMutableDictionary alloc]init];

        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

	// Do any additional setup after loading the view.
}


-(BOOL)postRequest:(NSString *)reqType withHouseID:(NSString *)houseID{
    
    //    NSString *postDataInString = [NSString stringWithFormat: @"{\"login\":{\"username\":\"%@\",\"password\":\"%@\"}}",[userNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[passwordField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    houseIDStr = houseID;
    
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails Where CurrentUser = 'ON'"] resultsArray:loginDetails];
    NSDictionary *currentUser;
    NSString *userType;
    NSString *userID;
    if ([loginDetails count]>0) {
        currentUser = [loginDetails objectAtIndex:0];
        userType = [currentUser valueForKey:@"User_Type"];
        userID = [currentUser valueForKey:@"UserID"];
    }
    
    

    NSLog(@"userID %@", userID);
    NSLog(@"WebService userType %@", userType);

    NSString *formattedStr;
    NSString *aryKey;
    

    if ([reqType isEqualToString:SYNC_HOUSE_TYPE]) {
        formattedStr = [self jsonFormatForTable:@"House" WithHouseID:houseIDStr];
        if (standardUserDefaults) {
            [standardUserDefaults setObject:SYNC_HOUSE_TYPE forKey:@"CurrentRequest"];
            [standardUserDefaults synchronize];
        }
        aryKey = @"Houses";
    }else if ([reqType isEqualToString:SYNC_ROOM_TYPE]){
        formattedStr = [self jsonFormatForTable:@"Room" WithHouseID:houseIDStr];
        if (standardUserDefaults) {
            [standardUserDefaults setObject:SYNC_ROOM_TYPE forKey:@"CurrentRequest"];
            [standardUserDefaults synchronize];
        }

        aryKey = @"Rooms";
    }else if ([reqType isEqualToString:SYNC_ITEM_TYPE]){
        formattedStr = [self jsonFormatForTable:@"Item" WithHouseID:houseIDStr];
        if (standardUserDefaults) {
            [standardUserDefaults setObject:SYNC_ITEM_TYPE forKey:@"CurrentRequest"];
            [standardUserDefaults synchronize];
        }
        aryKey = @"Items";

    }
    
    NSLog(@"formattedStr %@", formattedStr);
    
    
    NSString *reqTypeStr = [NSString stringWithFormat:@"\"Type\":\"%@\"",reqType];
    NSString *userIDStr = [NSString stringWithFormat:@"\"UserID\":\"%@\"",userID];
    
    
    NSLog(@"houseID %@", houseID);
    NSString *houseServerID = [self getServerIDTable:@"House" ForID:houseID];
    NSLog(@"house server id %@", houseServerID);
    
    if (houseServerID.length == 0) {
        houseServerID = @"";
    }
    
    NSString *postString;
    
    NSString *houseIDString = [NSString stringWithFormat:@"\"HouseID\":\"%@\"",houseServerID];

    
    NSString *tempTableStr = [NSString stringWithFormat:@"\"%@\":[%@]",aryKey,formattedStr];
    NSLog(@"tempTableStr %@", tempTableStr);
    
    if ([reqType isEqualToString:SYNC_ROOM_TYPE] || [reqType isEqualToString:SYNC_ITEM_TYPE] ) {
        postString = [NSString stringWithFormat:@"{%@,%@,%@,%@}",reqTypeStr,userIDStr,houseIDString,tempTableStr];
    }else{
        postString = [NSString stringWithFormat:@"{%@,%@,%@}",reqTypeStr,userIDStr,tempTableStr];
    }

    
    
//    NSString *postString = [NSString stringWithFormat:@"{%@,%@,%@}",reqTypeStr,userIDStr,tempTableStr];
    
    NSLog(@"postString %@", postString);
    NSData *postJsonData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
//    DashBoardViewController *tempVC = [[DashBoardViewController alloc]init];
    
//    UIViewController *tempVC;
    
//    if (houseIDStr.length == 0) {
//        tempVC = self;
//    }else{
//        DashBoardViewController *VC = [[DashBoardViewController alloc]init];
//        tempVC =VC;
//    }
    
    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self.wsiParentVC];
    webServiceInterface.delegate =self;
    [webServiceInterface sendRequest:postString PostJsonData:postJsonData Req_Type:reqType Req_url:SYNC_REQ_URL];
    
    
//    NSString *tempStr = [NSString stringWithFormat:@"URL: %@, Request: %@", SYNC_REQ_URL,postString];
//    [FAUtilities showAlert:tempStr];
    return  YES;
}

-(NSString *)jsonFormatForTable:(NSString *)tableName WithHouseID:(NSString *)houseID{
NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];    
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *tableDetails = [[NSMutableArray alloc]init];
    
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];

    if (houseID == nil) {
//        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM %@ ",tableName] resultsArray:tableDetails];

        if([tableName isEqualToString:@"House"]){
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM %@ Where UserID='%@'",tableName,user_Server_ID] resultsArray:tableDetails];
        }else{
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM %@ ",tableName] resultsArray:tableDetails];
        }
    }else{
         //NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
         //NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"UserServerID"];
        if ([tableName isEqualToString:@"House"]) {
     //   [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM %@ Where UserID='%@'",tableName,CurrentUser_ID] resultsArray:tableDetails];
           [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM %@ Where UserID='%@'",tableName,user_Server_ID] resultsArray:tableDetails];
         }else{
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM %@ Where HouseId = '%@'",tableName,houseID] resultsArray:tableDetails];
        }
    }
    
    NSMutableString *tableDetailsStr = [[NSMutableString alloc]init];
    
    
    if ([tableDetails count] ==0) {
        
    }else{
        for (int i=0; i<[tableDetails count]; i++) {
            NSDictionary *tempDict = [[NSDictionary alloc]init];
            tempDict = [tableDetails objectAtIndex:i];
            NSLog(@"tempDict %@",tempDict);
            
            NSUInteger dirValLen;
            dbManager = [DataBaseManager dataBaseManager];
            NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT Family FROM LoginDetails Where CurrentUser = 'ON'"] resultsArray:loginDetails];
           
           
            NSDictionary *familyNameDict=[[NSDictionary alloc]init];
            NSString *familyNameStr = [[NSString alloc]init];
            NSMutableString *formattedImagePathStr = [[NSMutableString alloc]init];
            
            if ([loginDetails count]>0) {
                familyNameDict= [loginDetails objectAtIndex:0];
                familyNameStr = [familyNameDict valueForKey:@"Family"];
            }
            
            if ([familyNameStr isKindOfClass:[NSNull class]]||(familyNameStr.length==0)) {
                
            }else{
                [formattedImagePathStr appendString:[NSString stringWithFormat:@"uploads/%@",familyNameStr]];
            }
            
            
            NSMutableString *houseImgStr = [[NSMutableString alloc]init];
            
            
            NSMutableArray *tableImgAry = [[NSMutableArray alloc]init];
             if ([tableName isEqualToString:@"House"]) {
                [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images Where HouseID = '%@' and RoomID IS NULL and ItemID IS NULL",[tempDict objectForKey:@"ID"]] resultsArray:tableImgAry];
                NSString *imageHouseID;
                imageHouseID = [tempDict objectForKey:@"ID"];
                dirValLen = imageHouseID.length +1;
                
            }else if ([tableName isEqualToString:@"Room"]){
                [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images Where HouseID = '%@' and RoomID = '%@' and ItemID IS NULL",[tempDict objectForKey:@"HouseID"],[tempDict objectForKey:@"ID"]] resultsArray:tableImgAry];
                NSString *imageHouseID;
                NSString *imageRoomID;
                imageHouseID=[tempDict objectForKey:@"HouseID"];
                imageRoomID = [tempDict objectForKey:@"ID"];
                dirValLen = imageHouseID.length +1 +imageRoomID.length +1;
            }else if ([tableName isEqualToString:@"Item"]){
                [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images Where HouseID = '%@' and RoomID = '%@' and ItemID = '%@'",[tempDict objectForKey:@"HouseID"],[tempDict objectForKey:@"RoomID"],[tempDict objectForKey:@"ID"]] resultsArray:tableImgAry];
                NSString *imageHouseID;
                NSString *imageRoomID;
                NSString *imageItemID;

                imageHouseID=[tempDict objectForKey:@"HouseID"];
                imageRoomID = [tempDict objectForKey:@"RoomID"];
                imageItemID = [tempDict objectForKey:@"ID"];

                dirValLen = imageHouseID.length +1 +imageRoomID.length +1 +imageItemID.length +1;

            }
            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            NSString *currentHouseName = [defaults valueForKey:@"HouseName"];
            NSString *currentHouseName;
            if ([tableName isEqualToString:@"House"]) {
                currentHouseName = [tempDict objectForKey:@"Name"];
                NSLog(@"currentHouseName %@",currentHouseName);
            }
            
            if ([currentHouseName isKindOfClass:[NSNull class]]||(currentHouseName.length==0)) {
            }else{
                [formattedImagePathStr appendString:[NSString stringWithFormat:@"/%@",currentHouseName]];
            }
            
           // NSMutableString *houseImgStr = [[NSMutableString alloc]init];
            
            for (int j=0; j<[tableImgAry count]; j++) {
                NSDictionary *tempImgDict = [[NSMutableDictionary alloc]init];
                tempImgDict = [tableImgAry objectAtIndex:j];
                NSString *crudOperation;
                
                if ([[tempImgDict objectForKey:@"SyncStatus"] isEqualToString:@"New"]) {
                    crudOperation = @"C";
                }else if ([[tempImgDict objectForKey:@"SyncStatus"] isEqualToString:@"Delete"]){
                    crudOperation = @"D";
                }
                else if ([[tempImgDict objectForKey:@"SyncStatus"] isEqualToString:@"Sync"]){
                    crudOperation = @"R";
                }
               
                 NSString *imageNameStr =[[tempImgDict objectForKey:@"ImagePath"] lastPathComponent];
                
                NSString *keyNameStr;
                NSString *parentID;
                
                if ([tableName isEqualToString:@"House"]) {
                    keyNameStr = @"HouseServerID";
                    parentID = @"HouseID";
                }else if ([tableName isEqualToString:@"Item"]){
                    keyNameStr = @"ItemServerID";
                    parentID = @"ItemID";
                }
                NSString *imgParentServerID = [self getServerIDTable:tableName ForID:[tempImgDict valueForKey:parentID]];                   NSLog(@"houseServerID %@", imgParentServerID);

                
                if (crudOperation.length !=0) {
                    NSString *imgStr;
                    
                    if ([crudOperation isEqualToString:@"D"] || [crudOperation isEqualToString:@"R"]) {
                        imgStr = [NSString stringWithFormat:@"{\"ID\":\"%@\",\"Filename\":\"%@\",\"ImagePath\":\"%@\",\"CRUD\":\"%@\",\"ServerID\":\"%@\",\"%@\":\"%@\"}",[tempImgDict valueForKey:@"ID"],imageNameStr,[NSString stringWithFormat:@"%@/images/%@",formattedImagePathStr,imageNameStr],crudOperation,[tempImgDict valueForKey:@"ServerID"],keyNameStr,imgParentServerID];
                    }else{
                        imgStr = [NSString stringWithFormat:@"{\"ID\":\"%@\",\"Filename\":\"%@\",\"ImagePath\":\"%@\",\"CRUD\":\"%@\",\"ServerID\":\"%@\",\"Data\":\"%@\",\"%@\":\"%@\"}",[tempImgDict valueForKey:@"ID"],imageNameStr,[NSString stringWithFormat:@"%@/images/%@",formattedImagePathStr,imageNameStr],crudOperation,[tempImgDict valueForKey:@"ServerID"],[tempImgDict valueForKey:@"ImageData"],keyNameStr,imgParentServerID];
                    }
                    
                    NSLog(@"imgStr %@", imgStr);
                    if (houseImgStr.length ==0) {
                        [houseImgStr appendString:imgStr];
                    }else{
                        [houseImgStr appendString:[NSString stringWithFormat:@",%@",imgStr]];
                    }
                }
            }
            
            NSLog(@"houseImgStr %@", houseImgStr);
            NSMutableArray *dbColumns = [[NSMutableArray alloc]init];
        
            [dbManager execute:[NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName] resultsArray:dbColumns];
            NSLog(@"columnNames %@", dbColumns);
            NSMutableArray *columnNames = [[NSMutableArray alloc]init];
            
            
            for (int k=0; k<[dbColumns count]; k++) {
                NSDictionary *tempDict = [dbColumns objectAtIndex:k];
                NSString *columnName = [tempDict valueForKey:@"name"];
                [columnNames addObject:columnName];
            }
            NSLog(@"columnNames %@", columnNames);
            NSMutableString *objMutableStr = [[NSMutableString alloc]init];
            
            
            for (int index=0; index<[columnNames count]; index++) {
                NSString *currnetColumn = [columnNames objectAtIndex:index];
                NSString *objStr;
                if ([currnetColumn isEqualToString:@"SyncStatus"]) {
                  
                    if ([[tempDict valueForKey:currnetColumn] isEqualToString:@"New"]) {
                        objStr = [NSString stringWithFormat:@"\"CRUD\":\"C\""];
                    }else if ([[tempDict valueForKey:currnetColumn] isEqualToString:@"Update"]){
                        objStr = [NSString stringWithFormat:@"\"CRUD\":\"U\""];
                    }
                    else if ([[tempDict valueForKey:currnetColumn] isEqualToString:@"Delete"]){
                        objStr = [NSString stringWithFormat:@"\"CRUD\":\"D\""];
                        objMutableStr = [[NSMutableString alloc]init];

                        NSString *tempIDStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",@"ID",[tempDict valueForKey:@"ID"]];
                        NSString *tempServerIDStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",@"ServerID",[tempDict valueForKey:@"ServerID"]];
                        NSString *tempServerTimeStamp = [NSString stringWithFormat:@"\"%@\":\"%@\"",@"ServerTimeStamp",[tempDict valueForKey:@"ServerTimeStamp"]];
                        [objMutableStr appendString:[NSString stringWithFormat:@"%@,%@,%@,%@",tempIDStr,tempServerIDStr,tempServerTimeStamp,objStr]];
                        break;
                        
                    }
                    else{
                        objStr = [NSString stringWithFormat:@"\"CRUD\":\"R\""];
                        objMutableStr = [[NSMutableString alloc]init];
                        NSString *tempIDStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",@"ID",[tempDict valueForKey:@"ID"]];

                        NSString *tempServerIDStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",@"ServerID",[tempDict valueForKey:@"ServerID"]];
                        
                        NSString *tempServerTimeStamp = [NSString stringWithFormat:@"\"%@\":\"%@\"",@"ServerTimeStamp",[tempDict valueForKey:@"ServerTimeStamp"]];
                        
                        [objMutableStr appendString:[NSString stringWithFormat:@"%@,%@,%@,%@",tempIDStr,tempServerIDStr,tempServerTimeStamp,objStr]];
                        break;
                    
                    }
                }else if ([currnetColumn isEqualToString:@"HouseID"]) {
                    

                    if ([tableName isEqualToString:@"Room"] || [tableName isEqualToString:@"Item"]) {
                        NSString * houseServerID = [self getServerIDTable:@"House" ForID:[tempDict valueForKey:currnetColumn]];                   NSLog(@"houseServerID %@", houseServerID);
                        objStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",currnetColumn,houseServerID];
                    }
                    
                    
                }else if ([currnetColumn isEqualToString:@"RoomID"]) {
                    if ([tableName isEqualToString:@"Item"]) {
                        
                        NSString * roomServerID = [self getServerIDTable:@"Room" ForID:[tempDict valueForKey:currnetColumn]];
                        NSLog(@"roomServerID %@", roomServerID);
                        objStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",currnetColumn,roomServerID];
                    }
                
                }else{
                    if ([tempDict valueForKey:currnetColumn] == NULL) {
                        objStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",currnetColumn,@""];
                    }else{
                        NSLog(@"currnetColumn %@", currnetColumn);
                        
                        NSString *str= [tempDict valueForKey:currnetColumn];
                        NSLog(@"str:%@",str);
                        
                      str=[str stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];//multiLine Text
                      str=[str stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];//multiLine Text

                        objStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",currnetColumn,[tempDict valueForKey:currnetColumn]];
                    }
                    
                }
               
                NSLog(@"objStr %@", objStr);
                if (objMutableStr.length ==0) {
                    [objMutableStr appendString:objStr];
                }else{
                    [objMutableStr appendString:[NSString stringWithFormat:@",%@",objStr]];
                }
            }
            
            
            NSLog(@"objMutableStr %@", objMutableStr);
            NSString *str = [NSString stringWithFormat:@"{%@,\"Images\":[%@] }",objMutableStr,houseImgStr];
            NSLog(@"str %@",str);
            str=[str stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];//multiLine Text
            str=[str stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];//multiLine Text

            if (tableDetailsStr.length ==0) {
                [tableDetailsStr appendString:str];
            }else{
                [tableDetailsStr appendString:[NSString stringWithFormat:@",%@",str]];
            }
        }
    }
//    NSLog(@"tableDetailsStr %@", tableDetailsStr);
    return tableDetailsStr;
}

-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    
    if (resp == NULL) {
//        [FAUtilities showAlert:@"Unable to Sync data"];
        
        if ([respType isEqualToString:SYNC_HOUSE_TYPE]) {
            [tempRespDic setObject:@"HouseFailed" forKey:SYNC_HOUSE_TYPE];
            [FAUtilities showAlert:@"Unable to Sync Houses"];
        }else if([respType isEqualToString:SYNC_ROOM_TYPE]) {
            [tempRespDic setObject:@"RoomFailed" forKey:SYNC_ROOM_TYPE];
            [FAUtilities showAlert:@"Unable to Sync Rooms"];

        }else if ([respType isEqualToString:SYNC_ITEM_TYPE]){
            [tempRespDic setObject:@"ItemFailed" forKey:SYNC_ITEM_TYPE];
            [FAUtilities showAlert:@"Unable to Sync Items"];

        }
// else if ([respType isEqualToString:ITEMPDF_TYPE]){
     //       [tempRespDic setObject:@"ItemPdfFailed" forKey:ITEMPDF_TYPE];
//            [FAUtilities showAlert:@"Unable to get Itempdf"];
            
//}
    }else{
        NSLog(@"resp type %@", respType);
        if ([respType isEqualToString:SYNC_HOUSE_TYPE]) {
            NSLog(@"Resp %@", resp);
            
            [self insertHouses:resp];
            
            
            NSArray *housesAry = [resp objectForKey:@"Houses"];
            
            if (housesAry.count == 0) {
                isHousesAvailable = NO;
            }else{
                isHousesAvailable = YES;
            }
            

            [self postRequest:SYNC_ROOM_TYPE withHouseID:houseIDStr];
            [tempRespDic setObject:@"Complete" forKey:SYNC_HOUSE_TYPE];

        }else if([respType isEqualToString:SYNC_ROOM_TYPE]) {
            NSLog(@"Resp %@", resp);
            [self insertRooms:resp];
            [self postRequest:SYNC_ITEM_TYPE withHouseID:houseIDStr];
            
            [tempRespDic setObject:@"Complete" forKey:SYNC_ROOM_TYPE];
        }else if ([respType isEqualToString:SYNC_ITEM_TYPE]){
            NSLog(@"Resp %@", resp);
            [self insertItems:resp];
            [tempRespDic setObject:@"Complete" forKey:SYNC_ITEM_TYPE];
            
            if (houseIDStr.length ==0) {
//                [FAUtilities showAlert:SYNC_SUCCESS];
                
//                if (isHousesAvailable == NO) {
//                    [FAUtilities showAlert:@"Please create a house"];
//                }
            }else{
                dbManager = [DataBaseManager dataBaseManager];
                NSMutableArray *houseNameAry = [[NSMutableArray alloc]init];
               [dbManager execute:[NSString stringWithFormat:@"SELECT Name FROM House Where Id='%@'",houseIDStr] resultsArray:houseNameAry];
                if (houseNameAry.count > 0) {
                    NSString *houseNameStr = [[houseNameAry objectAtIndex:0]valueForKey:@"Name"];
//                    [FAUtilities showAlert:[NSString stringWithFormat:@"%@ Data synchronized Succesfully",houseNameStr]];
                    [FAUtilities showAlert:[NSString stringWithFormat:@"%@ data updated successfully",houseNameStr]];
                }else{
                   // [FAUtilities showAlert:@"Synchronization Successful"];
                    [FAUtilities showAlert:SYNC_SUCCESS];
                }
            }
        }
        [delegate getStatus:tempRespDic];
    }
}

-(BOOL)insertHouses:(NSDictionary *)resp{
    dbManager = [DataBaseManager dataBaseManager];
     NSMutableArray *housesAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House"] resultsArray:housesAry];
    if (housesAry.count ==0) {
        NSArray *tempHouseAry = [resp valueForKey:@"Houses"];
        for (int i=0; i<[tempHouseAry count]; i++) {
            NSDictionary *tempDict = [tempHouseAry objectAtIndex:i];
            if ((tempDict == (id)[NSNull null]) ||(tempDict==nil)) {
            }else{
                NSString *serverID = [tempDict objectForKey:@"ServerID"];
                NSString *name= [tempDict objectForKey:@"Name"];
                NSString *description= [tempDict objectForKey:@"Description"];
                NSString *address = [tempDict objectForKey:@"Address"];
                NSString *serverTimeStamp = [tempDict objectForKey:@"ServerTimeStamp"];
           
                NSArray *imgAry = [tempDict objectForKey:@"Images"];
            
                
                if ([serverID isKindOfClass:[NSNull class]]) {
                    serverID =@"";
                }
                
               if ([serverTimeStamp isKindOfClass:[NSNull class]]|| (serverTimeStamp == (id)[NSNull null])) {
//                if ([serverTimeStamp isKindOfClass:[NSNull class]]||serverTimeStamp.length==0) {
                   serverTimeStamp =@"";
               }
                if ([name isKindOfClass:[NSNull class]]||(name.length==0)) {
                    name =@"";
                }
                if ([description isKindOfClass:[NSNull class]]||(description.length==0)) {
                    description =@"";
                }if ([address isKindOfClass:[NSNull class]]||(address.length==0)) {
                    address =@"";
                }
                
                name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                address= [address stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'House' (ServerID,ServerTimeStamp,Name,Description,Address,SyncStatus,UserID)VALUES ('%@', '%@', '%@','%@','%@','%@','%@')",serverID,serverTimeStamp,name,description,address,@"Sync",user_Server_ID]];
                
                if (imgAry.count >0) {
                    [self insertImages:imgAry WithHouseServerID:serverID];
                }else{
                    NSMutableArray *localImagesAry = [[NSMutableArray alloc]init];
                    NSString *houseLocalId = [self getLocalIDTable:@"House" ForID:serverID];
                    [dbManager execute:[NSString stringWithFormat:@"Select * From Images Where HouseID='%@'",houseLocalId] resultsArray:localImagesAry];
                    
                    if (localImagesAry > 0) {
                        NSLog(@"Need to delete all local images");
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",houseLocalId]];
                    }
                    
                }
            }
        }
    }else{
        NSMutableArray *serverIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM House"] resultsArray:serverIDAry];
        NSLog(@"serverIDAry %@", serverIDAry);
        
        NSMutableArray *localServerIds = [[NSMutableArray alloc]init];
        NSMutableArray *respServerIds = [[NSMutableArray alloc]init];

        for (int i=0; i<[serverIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [serverIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [localServerIds addObject:localServerId];
        }
        

        NSArray *tempStaticRespHouseArray = [[NSArray alloc]init];
        tempStaticRespHouseArray = [resp objectForKey:@"Houses"];
        NSMutableArray *tempRespHouseArray = [tempStaticRespHouseArray mutableCopy];        
        
        NSMutableArray *remainingHousesArray = [[NSMutableArray alloc]init];
        
        
        
        for (int i =0; i<[tempRespHouseArray count]; i++) {
            NSDictionary *tempDict = [tempRespHouseArray  objectAtIndex:i];
            if ((tempDict == (id)[NSNull null]) ||(tempDict==nil)) {
            }else{
                NSString *updatedRecordStatus = [tempDict objectForKey:@"Status"];
                NSString *serverID = [tempDict objectForKey:@"ServerID"];
                NSString *localID = [tempDict objectForKey:@"ID"];
                NSString *serverTimeStamp = [tempDict objectForKey:@"ServerTimeStamp"];
                
                NSArray *imgAry = [tempDict objectForKey:@"Images"];
                NSString *curdValue = [tempDict objectForKey:@"CRUD"];
                houseSuccessUpdated = NO;

                if ([updatedRecordStatus isEqualToString:@"Success"]) {
                
                    if ([curdValue isEqualToString:@"D"]) {
                        NSString *houseLocalServerID = [self getLocalIDTable:@"House" ForID:serverID];

                        [dbManager execute:[NSString stringWithFormat:@"Delete From House where ServerId = '%@'",serverID]];
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",houseLocalServerID]];
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Room where HouseID = '%@'",houseLocalServerID]];
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Item where HouseID = '%@'",houseLocalServerID]];
                    }else if([curdValue isEqualToString:@"C"]){
                        
                        
                        if ([serverID isKindOfClass:[NSNull class]]) {
                           serverID=@"";
                        }
//                        if ([serverTimeStamp isKindOfClass:[NSNull class]]||(int)serverTimeStamp.length==0) {

                       if ([serverTimeStamp isKindOfClass:[NSNull class]] ||(serverTimeStamp == (id)[NSNull null])) {
                            serverTimeStamp =@"";
                        }
                    if ([localID isKindOfClass:[NSNull class]]) {
                            localID =@"";
                        }
                        
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
                        [dbManager execute:[NSString stringWithFormat:@"Update House set ServerId = '%@',syncStatus='%@',ServerTimeStamp='%@',UserID='%@'  where ID = '%@'",serverID,@"Sync",serverTimeStamp,user_Server_ID,localID]];
                    }else if ([curdValue isEqualToString:@"U"]){
                        
                        if ([serverID isKindOfClass:[NSNull class]]) {
                            serverID=@"";
                        }
                        if ([serverTimeStamp isKindOfClass:[NSNull class]]||(serverTimeStamp == (id)[NSNull null])) {

//                        if ([serverTimeStamp isKindOfClass:[NSNull class]]||serverTimeStamp.length==0) {
//                            serverTimeStamp =@"";
                        }
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
                        [dbManager execute:[NSString stringWithFormat:@"Update House set syncStatus='%@',ServerTimeStamp='%@',UserID='%@' where ServerId = '%@'",@"Sync",serverTimeStamp,user_Server_ID,serverID]];
                    }
                
                    if (imgAry.count >0) {
                        [self insertImages:imgAry WithHouseServerID:serverID];
                    }else{
                        NSMutableArray *localImagesAry = [[NSMutableArray alloc]init];
                        NSString *houseLocalId = [self getLocalIDTable:@"House" ForID:serverID];
                        [dbManager execute:[NSString stringWithFormat:@"Select * From Images Where HouseID='%@'",houseLocalId] resultsArray:localImagesAry];
                        
                        if (localImagesAry > 0) {
                            NSLog(@"Need to delete all local images");
                            [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",houseLocalId]];
                        }
                    }
                }else if ([updatedRecordStatus isEqualToString:@"Deleted"]){
                    NSString *houseLocalServerID = [self getLocalIDTable:@"House" ForID:serverID];
                
                    [dbManager execute:[NSString stringWithFormat:@"Delete From House where ServerId = '%@'",serverID]];
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",houseLocalServerID]];
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Room where HouseID = '%@'",houseLocalServerID]];
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Item where HouseID = '%@'",houseLocalServerID]];

                }else if ([updatedRecordStatus isEqualToString:@"Fail"]){
                
                    NSMutableArray *houseNameAry = [[NSMutableArray alloc]init];
                    [dbManager execute:[NSString stringWithFormat:@"Select Name From House where ServerId = '%@'",serverID] resultsArray:houseNameAry];

                    NSDictionary *tempDict = [houseNameAry objectAtIndex:0];
                    NSString *houseName = [tempDict valueForKey:@"Name"];
                    [FAUtilities showAlert:[NSString stringWithFormat:@"Unable to update info for %@",houseName ]];
                
                }else{
                    if ([updatedRecordStatus isEqualToString:@""]) {
                        if ([curdValue isEqualToString:@"R"]) {
                        
                        }else{
                            [remainingHousesArray addObject:tempDict];
                            [respServerIds addObject:serverID];
                        }
                    }else{
                        [remainingHousesArray addObject:tempDict];
                    }
                }
            }
        }
        
        NSMutableArray *afterUpdateserverIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM House"] resultsArray:afterUpdateserverIDAry];
        NSLog(@"serverIDAry %@", serverIDAry);
        
        localServerIds = [[NSMutableArray alloc]init];
        
        for (int i=0; i<[afterUpdateserverIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [afterUpdateserverIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [localServerIds addObject:localServerId];
        }
        
        NSLog(@"localServerIds %@", localServerIds);
        NSLog(@"respServerIds %@", respServerIds);
        
        for (int i=0; i<[remainingHousesArray count]; i++) {

            NSDictionary *tempElementsDict = [remainingHousesArray  objectAtIndex:i];
            NSString *tempServerId = [tempElementsDict objectForKey:@"ServerID"];
            NSString *tempHouseName = [tempElementsDict objectForKey:@"Name"];
            NSString *tempHouseAddr = [tempElementsDict objectForKey:@"Address"];
            NSString *tempHouseDesc = [tempElementsDict objectForKey:@"Description"];
            NSString *tempServerTimeStamp = [tempElementsDict objectForKey:@"ServerTimeStamp"];
            
            NSArray *imgAry = [tempElementsDict objectForKey:@"Images"];
            
            for (int j=0; j<[localServerIds count]; j++) {
                NSString *tempLocalServerID = [localServerIds objectAtIndex:j];
                if ([tempLocalServerID intValue] == [tempServerId intValue]) {
                    
                    if ([tempHouseName isKindOfClass:[NSNull class]]||(tempHouseName.length==0)) {
                        tempHouseName=@"";
                    }
                    if ([tempHouseDesc isKindOfClass:[NSNull class]]||(tempHouseDesc.length==0)) {
                        tempHouseDesc =@"";
                    }
                    
                    if ([tempHouseAddr isKindOfClass:[NSNull class]]||(tempHouseAddr.length==0)) {
                        tempHouseAddr=@"";
                    }
                    if ([tempServerTimeStamp isKindOfClass:[NSNull class]]||tempServerTimeStamp== (id)[NSNull null]) {

//                    if ([tempServerTimeStamp isKindOfClass:[NSNull class]]||tempServerTimeStamp.length==0) {
                        tempServerTimeStamp =@"";
                    }
                    if ([tempServerId isKindOfClass:[NSNull class]]) {
                        tempServerId =@"";
                    }
                    
                    tempHouseName = [tempHouseName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    tempHouseDesc = [tempHouseDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    tempHouseAddr = [tempHouseAddr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    
                    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
                    
                    [dbManager execute:[NSString stringWithFormat:@"Update House set Name = '%@',Description = '%@',Address = '%@',syncStatus='%@',ServerTimeStamp='%@',UserID='%@'  where ServerId = '%@'",tempHouseName,tempHouseDesc,tempHouseAddr,@"Sync",tempServerTimeStamp,user_Server_ID,tempServerId]];
                    if (imgAry.count >0) {
                        [self insertImages:imgAry WithHouseServerID:tempServerId];
                    }else{
                        NSMutableArray *localImagesAry = [[NSMutableArray alloc]init];
                        NSString *houseLocalId = [self getLocalIDTable:@"House" ForID:tempServerId];
                        [dbManager execute:[NSString stringWithFormat:@"Select ID From Images Where HouseID='%@'",houseLocalId] resultsArray:localImagesAry];
                        
                        if (localImagesAry > 0) {
                            NSLog(@"Need to delete all local images");
                            [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",houseLocalId]];
                        }
                    }
                    houseUpdated = YES;
                    break;
                }else{
                    houseUpdated = NO;
                    continue;
                }
            }
            
            if (houseUpdated == NO) {
                
                if ([tempHouseName isKindOfClass:[NSNull class]]||(tempHouseName.length==0)) {
                    tempHouseName =@"";
                }
                
                if ([tempHouseDesc isKindOfClass:[NSNull class]]||(tempHouseDesc.length==0)) {
                    tempHouseDesc =@"";
                }
                if ([tempHouseAddr isKindOfClass:[NSNull class]]||(tempHouseAddr.length==0)) {
                    tempHouseAddr =@"";
                }
                if ([tempServerId isKindOfClass:[NSNull class]]) {
                    tempServerId =@"";
                }if ([tempServerTimeStamp isKindOfClass:[NSNull class]]||tempServerTimeStamp== (id)[NSNull null]) {
//                }if ([tempServerTimeStamp isKindOfClass:[NSNull class]] ||tempServerTimeStamp.length==0) {
                    tempServerTimeStamp =@"";
                }
                
                tempHouseName = [tempHouseName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                tempHouseDesc = [tempHouseDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                tempHouseAddr= [tempHouseAddr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
                
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'House' (Name, Description,Address,SyncStatus,ServerId,ServerTimeStamp,UserID)VALUES ('%@','%@','%@','%@','%@','%@','%@')",tempHouseName,tempHouseDesc,tempHouseAddr,@"Sync",tempServerId,tempServerTimeStamp,user_Server_ID]];
                houseInserted = YES;
                if (imgAry.count >0) {
                    [self insertImages:imgAry WithHouseServerID:tempServerId];
                }else{
                    NSMutableArray *localImagesAry = [[NSMutableArray alloc]init];
                    NSString *houseLocalId = [self getLocalIDTable:@"House" ForID:tempServerId];
                    [dbManager execute:[NSString stringWithFormat:@"Select * From Images Where HouseID='%@'",houseLocalId] resultsArray:localImagesAry];
                    
                    if (localImagesAry > 0) {
                        NSLog(@"Need to delete all local images");
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",houseLocalId]];
                    }
                }
            }
        }
    }
    return YES;
}


-(BOOL)insertImages:(NSArray *)imagesAry WithHouseServerID:(NSString*)houseID{
    NSString *localHouseID = [self getLocalIDTable:@"House" ForID:houseID];
    NSLog(@"imagesAry %@", imagesAry);
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *localImgAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images Where HouseId='%@'",localHouseID] resultsArray:localImgAry];

    if (localImgAry.count ==0) {
        for (int i=0; i<[imagesAry count]; i++) {
            NSDictionary *tempDict = [imagesAry objectAtIndex:i];
            NSString *serverID = [tempDict objectForKey:@"ServerID"];
            NSString *tempFileUrl= [tempDict objectForKey:@"FileURL"];
            
            
//            NSString *tempFile = [tempDict objectForKey:@"FileURL"];
//            NSString *tempFileUrl = [tempFile stringByReplacingOccurrencesOfString:@"rhm.mlx.com" withString:@"192.168.137.20"];
            
            if ([tempFileUrl isKindOfClass:[NSNull class]]||(tempFileUrl.length==0)) {
                tempFileUrl =@"";
            }
            
            if ([serverID isKindOfClass:[NSNull class]]) {
                serverID =@"";
            }
            if ([localHouseID isKindOfClass:[NSNull class]]) {
                localHouseID =@"";
            }
            
            [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (ServerPath, ServerId,HouseID,SyncStatus)VALUES ('%@','%@','%@','%@')",tempFileUrl,serverID,localHouseID,@"Sync"]];
        }
    }else{
        NSMutableArray *serverIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM Images Where HouseID = '%@' and RoomID IS NULL and ItemID IS NULL",localHouseID] resultsArray:serverIDAry];
        NSLog(@"serverIDAry %@", serverIDAry);
        
        NSMutableArray *localServerIds = [[NSMutableArray alloc]init];
        NSMutableArray *respServerIds = [[NSMutableArray alloc]init];
        NSLog(@"respServerIds %@", respServerIds);
        
        for (int i=0; i<[serverIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [serverIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [localServerIds addObject:localServerId];
        }

        
        
        NSMutableArray *remainingImagesArray = [[NSMutableArray alloc]init];
        for (int i =0; i<[imagesAry count]; i++) {
            NSDictionary *tempDict = [imagesAry  objectAtIndex:i];
            
            NSString *updatedRecordStatus = [tempDict objectForKey:@"Status"];
            NSString *serverID = [tempDict objectForKey:@"ServerID"];
            NSString *localID = [tempDict objectForKey:@"ID"];
            NSString *curdValue = [tempDict objectForKey:@"CRUD"];
            NSString *fileUrl = [tempDict objectForKey:@"FileURL"];
            
            
//            NSString *tempFile = [tempDict objectForKey:@"FileURL"];
//            NSString *fileUrl = [tempFile stringByReplacingOccurrencesOfString:@"rhm.mlx.com" withString:@"192.168.137.20"];

            
            
            NSLog(@"fileUrl %@", fileUrl);

            imageSuccessUpdated = NO;
            if([updatedRecordStatus isKindOfClass:[NSNull class]]){
                
            }else{
                if ([updatedRecordStatus isEqualToString:@"Success"]) {
                    if ([curdValue isEqualToString:@"D"]) {
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ServerID = '%@'",serverID]];
                    }else if([curdValue isEqualToString:@"C"]){
                        
                        if ([serverID isKindOfClass:[NSNull class]]) {
                            serverID=@"";
                        }
                        if ([localID isKindOfClass:[NSNull class]]) {
                            localID =@"";
                        }
                        [dbManager execute:[NSString stringWithFormat:@"Update Images set ServerId = '%@',syncStatus='%@'  where ID = '%@'",serverID,@"Sync",localID]];
                    }else if ([curdValue isEqualToString:@"U"]){
                        if ([serverID isKindOfClass:[NSNull class]]) {
                            serverID=@"";
                        }
                        [dbManager execute:[NSString stringWithFormat:@"Update Images set syncStatus='%@'  where ServerId = '%@'",@"Sync",serverID]];
                    }
                }else if ([updatedRecordStatus isEqualToString:@"Deleted"]){
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",serverID]];
                } else{
                    if ([updatedRecordStatus isEqualToString:@""]) {
                        if ([curdValue isEqualToString:@"R"]) {
                        }else{
                            [remainingImagesArray addObject:tempDict];
                        }
                    }else{
                        [remainingImagesArray addObject:tempDict];
                    }
                }
            }
                

        }
        
        for (int localIdIndex=0; localIdIndex<[localServerIds count]; localIdIndex++) {
            BOOL imageAvailableInServer = NO;
            NSString *localIDValue = [localServerIds objectAtIndex:localIdIndex];
            for (int serverIdIndex=0; serverIdIndex<[imagesAry count]; serverIdIndex++) {
                NSString *serverIDValue = [[imagesAry objectAtIndex:serverIdIndex] objectForKey:@"ServerID"];
                if ([localIDValue intValue] == [serverIDValue intValue]) {
                    imageAvailableInServer = YES;
                    break;
                }else{
                    imageAvailableInServer = NO;
                    continue;
                }
            }
            if (imageAvailableInServer == NO) {
                dbManager = [DataBaseManager dataBaseManager];
                [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ServerID = '%@'",localIDValue]];
            }
        }
        
        
        
        
        for (int i=0; i<[remainingImagesArray count]; i++) {
            NSDictionary *tempElementsDict = [remainingImagesArray  objectAtIndex:i];
            NSString *tempServerId = [tempElementsDict objectForKey:@"ServerID"];
            NSString *tempFileUrl = [tempElementsDict objectForKey:@"FileURL"];
            
//            NSString *tempFile = [tempElementsDict objectForKey:@"FileURL"];
//            NSString *tempFileUrl = [tempFile stringByReplacingOccurrencesOfString:@"rhm.mlx.com" withString:@"192.168.137.20"];

            
            
            for (int j=0; j<[localServerIds count]; j++) {
                NSString *tempLocalServerID = [localServerIds objectAtIndex:j];
                //                if ([tempLocalServerID isEqualToString:tempServerId])
                
                if ([tempLocalServerID intValue] == [tempServerId intValue]) {
                    
                    if ([tempFileUrl isKindOfClass:[NSNull class]]||(tempFileUrl.length==0)) {
                        tempFileUrl=@"";
                    }
                    if ([tempServerId isKindOfClass:[NSNull class]]) {
                        tempServerId =@"";
                    }
                    [dbManager execute:[NSString stringWithFormat:@"Update Images set ServerPath = '%@',syncStatus ='%@' where ServerId = '%@'",tempFileUrl,@"Sync",tempServerId]];
                    
                    imageUpdated = YES;
                    break;
                }else{
                    imageUpdated = NO;
                    continue;
                }
            }
            
            if (imageUpdated == NO) {
                
                if ([tempFileUrl isKindOfClass:[NSNull class]]||(tempFileUrl.length==0)) {
                    tempFileUrl =@"";
                }
                if ([localHouseID isKindOfClass:[NSNull class]]) {
                    localHouseID =@"";
                }
                if ([tempServerId isKindOfClass:[NSNull class]]) {
                    tempServerId =@"";
                }
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (ServerPath, ServerId,HouseID,SyncStatus)VALUES ('%@','%@','%@','%@')",tempFileUrl,tempServerId,localHouseID,@"Sync"]];
                imageInserted = YES;
            }
        }
    }
    return YES;
}


-(int)lastInsertedRowID{
    
    NSMutableArray *idAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * from SQLITE_SEQUENCE;"] resultsArray:idAry];
    NSLog(@"ID Ary %@", idAry);
    
    NSString *seqVal;
    for (int i=0; i<[idAry count]; i++) {
        NSDictionary *tempDict = [idAry objectAtIndex:i];
        if ([[tempDict valueForKey:@"name"] isEqualToString:@"Images"]) {
            seqVal = [[idAry objectAtIndex:i] valueForKey:@"seq"];
        }
    }
    int rowID = [seqVal intValue]+1;
    return rowID;
}


-(BOOL)insertRooms:(NSDictionary *)resp{
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *roomsAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Room"] resultsArray:roomsAry];

    NSLog(@"roomsAry %@", roomsAry);
    
    if (roomsAry.count ==0) {
        NSArray *tempRoomAry = [resp valueForKey:@"Rooms"];
        for (int i=0; i<[tempRoomAry count]; i++) {
            NSDictionary *tempDict = [tempRoomAry objectAtIndex:i];
            if ((tempDict == (id)[NSNull null]) ||(tempDict==nil)) {//Divya
                }else{
                    NSLog(@"tempDict %@", tempDict);
                    NSString *roomServerID = [tempDict objectForKey:@"id"];
                    NSString *name= [tempDict objectForKey:@"name"];
                    NSString *roomServerHouseID = [tempDict objectForKey:@"house_id"];
                    NSString *description= [tempDict objectForKey:@"description"];
                    NSString *parentRoomServerID = [tempDict objectForKey:@"parent_room_id"];
                    NSString *serverTimeStamp = [tempDict objectForKey:@"ServerTimeStamp"];

                    NSString *roomType= [tempDict objectForKey:@"type"];
                    NSString *houseLocalId = [self getLocalIDTable:@"House" ForID:roomServerHouseID];
                    NSLog(@"hosueLocalID %@",houseLocalId );
                    NSLog(@"parentRoomServerID %@", parentRoomServerID);
                    
                    if ([roomServerID isKindOfClass:[NSNull class]]) {
                        roomServerID =@"";
                    }
                    
                    if ([houseLocalId isKindOfClass:[NSNull class]]) {
                        houseLocalId =@"";
                    }
                    if ([name isKindOfClass:[NSNull class]]||(name.length==0)) {
                        name =@"";
                    }
                    if ([description isKindOfClass:[NSNull class]]||(description.length==0)) {
                        description =@"";
                    }
                    if ([roomType isKindOfClass:[NSNull class]]) {
                        roomType =@"";
                    }
                    if ([serverTimeStamp  isKindOfClass:[NSNull class]]|| (serverTimeStamp == (id)[NSNull null])) {
                        serverTimeStamp =@"";
                    }
            
                    name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Room' (ServerID,HouseID,Name,Description,Type,SyncStatus,ServerTimeStamp)VALUES ('%@', '%@','%@','%@','%@','%@','%@')",roomServerID,houseLocalId,name,description,roomType,@"Sync",serverTimeStamp]];
                }

        }
    }else{
        
        NSMutableArray *roomServerIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM ROOM"] resultsArray:roomServerIDAry];
        NSLog(@"serverIDAry %@", roomServerIDAry);
        
        NSMutableArray *roomLocalServerIds = [[NSMutableArray alloc]init];

        for (int i=0; i<[roomServerIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [roomServerIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [roomLocalServerIds addObject:localServerId];
        }

        NSArray *tempStaticRespRoomArray = [[NSArray alloc]init];
        tempStaticRespRoomArray = [resp objectForKey:@"Rooms"];
        NSMutableArray *tempRespRoomArray = [tempStaticRespRoomArray mutableCopy];
        NSMutableArray *remainingRoomArray = [[NSMutableArray alloc]init];

        
        
        for (int i =0; i<[tempRespRoomArray count]; i++) {
            NSDictionary *tempDict = [tempRespRoomArray  objectAtIndex:i];
            if ((tempDict == (id)[NSNull null]) ||(tempDict==nil)) {//Divya
            }else{//Divya
                NSString *updatedRecordStatus = [tempDict objectForKey:@"Status"];
                NSString *serverID = [tempDict objectForKey:@"ServerID"];
                NSString *localID = [tempDict objectForKey:@"ID"];
                NSString *curdValue = [tempDict objectForKey:@"CRUD"];
                NSString *roomServerTimeStamp = [tempDict objectForKey:@"ServerTimeStamp"];
                
                roomSuccessUpdated = NO;
            
                if ([updatedRecordStatus isEqualToString:@"Success"]) {
                    if ([curdValue isEqualToString:@"D"]) {
                         NSString *roomLocalServerID = [self getLocalIDTable:@"Room" ForID:serverID];
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Room where ServerId = '%@'",serverID]];
                        [dbManager execute:[NSString stringWithFormat:@"Delete From Item where RoomId = '%@'",roomLocalServerID]];
                    
                    }else if ([curdValue isEqualToString:@"U"]){
                        if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp== (id)[NSNull null]) {
//                        if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp.length==0) {
                            roomServerTimeStamp=@"";
                        }
                        if ([serverID isKindOfClass:[NSNull class]]) {
                            serverID =@"";
                        }
                        [dbManager execute:[NSString stringWithFormat:@"Update Room set syncStatus='%@',ServerTimeStamp='%@'  where ServerId = '%@'",@"Sync",roomServerTimeStamp,serverID]];
                        roomSuccessUpdated = YES;
                    }else if ([curdValue isEqualToString:@"C"]){
                        if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp== (id)[NSNull null]) {

//                        if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp.length==0) {
                            roomServerTimeStamp=@"";
                        }
                        if ([localID isKindOfClass:[NSNull class]]) {
                            localID =@"";
                        }
                        if ([serverID isKindOfClass:[NSNull class]]) {
                            serverID =@"";
                        }
                        
                        
                        [dbManager execute:[NSString stringWithFormat:@"Update Room set ServerId = '%@',syncStatus='%@',ServerTimeStamp='%@'  where ID = '%@'",serverID,@"Sync",roomServerTimeStamp,localID]];
                    }
                }else if ([updatedRecordStatus isEqualToString:@"Deleted"]){
                    NSString *roomLocalServerID = [self getLocalIDTable:@"Room" ForID:serverID];
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Room where ServerId = '%@'",serverID]];
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Item where RoomId = '%@'",roomLocalServerID]];
                }else{
                
                    if ([updatedRecordStatus isEqualToString:@""]) {
                        if ([curdValue isEqualToString:@"R"]) {
                            NSLog(@"no updation");
                        }else{
                            [remainingRoomArray addObject:tempDict];
                        }
                    }else{
                        [remainingRoomArray addObject:tempDict];
                    }
                }
            }
        }

        NSMutableArray *afterUpdateRoomServerIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM Room"] resultsArray:afterUpdateRoomServerIDAry];
        NSLog(@"serverIDAry %@", roomServerIDAry);

        roomLocalServerIds = [[NSMutableArray alloc]init];
        
        for (int i=0; i<[afterUpdateRoomServerIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [afterUpdateRoomServerIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [roomLocalServerIds addObject:localServerId];
        }

        NSLog(@"roomlocalServerIds %@", roomLocalServerIds);

        for (int i=0; i<[remainingRoomArray count]; i++) {
            
            NSDictionary *tempElementsDict = [remainingRoomArray  objectAtIndex:i];
            
            if ((tempElementsDict == (id)[NSNull null]) ||(tempElementsDict==nil)) {//Divya
           
            }else{//Divya
                NSString *roomServerID = [tempElementsDict objectForKey:@"id"];
                NSString *name= [tempElementsDict objectForKey:@"name"];
                NSString *roomServerHouseID = [tempElementsDict objectForKey:@"house_id"];
                NSString *description= [tempElementsDict objectForKey:@"description"];
                NSString *parentRoomServerID = [tempElementsDict objectForKey:@"parent_room_id"];
                NSString *roomType = [tempElementsDict objectForKey:@"type"];
                NSString *roomServerTimeStamp = [tempElementsDict objectForKey:@"ServerTimeStamp"];
                
                NSString *houseLocalId = [self getLocalIDTable:@"House" ForID:roomServerHouseID];
                NSLog(@"hosueLocalID %@",houseLocalId );
                NSLog(@"parentRoomServerID %@",parentRoomServerID );

                
                for (int j=0; j<[roomLocalServerIds count]; j++) {
                    NSString *tempLocalServerID = [roomLocalServerIds objectAtIndex:j];
                    if ([tempLocalServerID intValue] == [roomServerID intValue]) {
                        
                        NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
                        [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Room where ServerId='%@'",roomServerID] resultsArray:syncDetails];
                    
                        NSLog(@"syncDetails %@", syncDetails);
                    
                        NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
                        if ([syncValue isEqualToString:@"Delete"]) {
                        
                        }else{
                            
                            if ([roomServerID isKindOfClass:[NSNull class]]) {
                                roomServerID =@"";
                            }
                            
                            if ([houseLocalId isKindOfClass:[NSNull class]]) {
                                houseLocalId =@"";
                            }
                            if ([name isKindOfClass:[NSNull class]]||(name.length==0)) {
                                name =@"";
                            }
                            if ([description isKindOfClass:[NSNull class]]||(description.length==0)) {
                                description =@"";
                            }if ([roomType isKindOfClass:[NSNull class]]) {
                                roomType =@"";
                            }
                            if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp== (id)[NSNull null]) {

//                            if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp.length==0) {
                                roomServerTimeStamp =@"";
                            }

                            name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            
                            [dbManager execute:[NSString stringWithFormat:@"Update Room set Name = '%@',Description = '%@',Type = '%@',syncStatus='%@',ServerTimeStamp='%@'  where ServerId = '%@'",name,description,roomType,@"Sync",roomServerTimeStamp,roomServerID]];
                        }
                        roomUpdated = YES;
                        break;
                    }else{
                        roomUpdated = NO;
                        continue;
                    }
                }
            
                if (roomUpdated == NO) {
                    
                    if ([roomServerID isKindOfClass:[NSNull class]]) {
                        roomServerID =@"";
                    }
                    
                    if ([houseLocalId isKindOfClass:[NSNull class]]) {
                        houseLocalId =@"";
                    }
                    if ([name isKindOfClass:[NSNull class]]||(name.length==0)) {
                        name =@"";
                    }
                    if ([description isKindOfClass:[NSNull class]]||(description.length==0)) {
                        description =@"";
                    }if ([roomType isKindOfClass:[NSNull class]]) {
                        roomType =@"";
                    }
                    if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp== (id)[NSNull null]) {

//                    if ([roomServerTimeStamp isKindOfClass:[NSNull class]]||roomServerTimeStamp.length==0) {
                        roomServerTimeStamp =@"";
                    }
                    
                    name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Room' (ServerID,ServerTimeStamp,HouseID,Name,Description,Type,SyncStatus)VALUES ('%@','%@','%@','%@','%@','%@','%@')",roomServerID,roomServerTimeStamp,houseLocalId,name,description,roomType,@"Sync"]];
                    roomInserted = YES;
                }
            }
        }
    }
    return YES;
}
- (void)removePdf:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:fileName error:&error];
    if (success) {
        NSLog(@"file deleted -:%@ ",[error localizedDescription]);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}


- (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:fileName error:&error];
    if (success) {
        NSLog(@"file deleted -:%@ ",[error localizedDescription]);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}


-(BOOL)insertItems:(NSDictionary *)resp{
   dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *itemsAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Item"] resultsArray:itemsAry];
    
    NSLog(@"itemsAry %@", itemsAry);

    if (itemsAry.count ==0) {
        NSArray *tempItemsAry = [resp valueForKey:@"Items"];
        for (int i=0; i<[tempItemsAry count]; i++) {
            NSDictionary *tempDict = [tempItemsAry objectAtIndex:i];
            
            NSLog(@"tempDict %@", tempDict);
           
            if ((tempDict == (id)[NSNull null]) ||(tempDict==nil)) {
            }else{
//                NSString *itemServerID = [tempDict objectForKey:@"item_id"];
                NSString *itemServerID = [tempDict objectForKey:@"id"];

                NSString *itemServerHouseID = [tempDict objectForKey:@"house_id"];
                NSString *itemServerRoomID = [tempDict objectForKey:@"room_id"];
            
                NSString *name= [tempDict objectForKey:@"name"];
                NSString *description= [tempDict objectForKey:@"description"];
                NSString *category =[tempDict objectForKey:@"category"];
                NSString *datePurchase =[tempDict objectForKey:@"date_purchase"];
                NSString *invoiceNum =[tempDict objectForKey:@"invoice_num"];
                NSString *manufacturer =[tempDict objectForKey:@"manufacturer"];
                NSString *cost =[tempDict objectForKey:@"cost"];
                NSString *brand =[tempDict objectForKey:@"brand"];
                NSString *model =[tempDict objectForKey:@"model"];
                NSString *condition =[tempDict objectForKey:@"item_condition"];
                NSString *quantity =[tempDict objectForKey:@"quantity"];
                NSString *status =[tempDict objectForKey:@"status"];
                NSString *size=[tempDict objectForKey:@"size"];//Divya
                NSString *yearMade=[tempDict objectForKey:@"year_made"];
                NSString *materialMade=[tempDict objectForKey:@"material_made"];
                NSString *shape=[tempDict objectForKey:@"shape"];
                NSString *color=[tempDict objectForKey:@"color"];
                NSString *isTaxable=[tempDict objectForKey:@"is_taxable"];
                NSString *isInsured=[tempDict objectForKey:@"is_insured"];
                NSString *soldTo=[tempDict objectForKey:@"sold_to"];
                NSString *soldDate=[tempDict objectForKey:@"sold_date"];
                NSString *soldPrice=[tempDict objectForKey:@"sold_price"];
                NSString *warrantyExpire=[tempDict objectForKey:@"warranty_expire"];
                NSString *warrantyInfo=[tempDict objectForKey:@"warranty_info"];
                NSString *insuredBy=[tempDict objectForKey:@"insured_by"];
                NSString *insuredPolicy=[tempDict objectForKey:@"insure_policy"];
                NSString *leaseStartDate=[tempDict objectForKey:@"lease_start"];
                NSString *leaseEndDate=[tempDict objectForKey:@"lease_end"];
                NSString *leaseDesc=[tempDict objectForKey:@"lease_description"];
                NSString *replacementCost=[tempDict objectForKey:@"replacement_cost"];
                NSString *serialNum=[tempDict objectForKey:@"serial_num"];
                NSString *placedInService=[tempDict objectForKey:@"placed_into_service"];
                NSString *usePercentage=[tempDict objectForKey:@"biz_use_percent"];
                NSString *salvageValue=[tempDict objectForKey:@"salvage_value"];
                NSString *depreciationMethod=[tempDict objectForKey:@"depreciation_method"];
                NSString *beneficiary=[tempDict objectForKey:@"beneficiary"];
                NSString *lifeInYears=[tempDict objectForKey:@"life_in_years"];
                NSString *comments=[tempDict objectForKey:@"comments"];
                NSString *currentValue= [tempDict objectForKey:@"current_value"];//Divya
                NSArray *itemImagesAry = [tempDict objectForKey:@"Images"];
                NSString *serverTimeStamp = [tempDict objectForKey:@"ServerTimeStamp"];
//                NSString *pdflink= [tempDict objectForKey:@"pdf"];//Divya

                
                NSString *houseLocalID = [self getLocalIDTable:@"House" ForID:itemServerHouseID];
                NSString *roomLocalID = [self getLocalIDTable:@"Room" ForID:itemServerRoomID];
            
                

                if ([itemServerID isKindOfClass:[NSNull class]]) {
                    itemServerID =@"";
                }
                
                if ([quantity isKindOfClass:[NSNull class]] || [quantity intValue]==0 ) {
                    quantity =@"";
                }
                
                
                if ([cost isKindOfClass:[NSNull class]]||[cost isEqualToString:@"0.00"] || [cost intValue] ==0) {
                    cost =@"";
                }
                
                if ([soldDate isKindOfClass:[NSNull class]]||([soldDate isEqualToString:@"0000-00-00"])) {
                    soldDate =@"";
                }
                
                if ([soldTo isKindOfClass:[NSNull class]]||(soldTo.length==0)) {
                    soldTo =@"";
                }
                
                if ([soldPrice isKindOfClass:[NSNull class]]||([soldPrice isEqual:@"0.00"])) {
                    soldPrice =@"";
                }
                
                if ([warrantyExpire isKindOfClass:[NSNull class]]||([warrantyExpire isEqualToString:@"0000-00-00"])) {
                    warrantyExpire =@"";
                }
                
                if ([warrantyInfo isKindOfClass:[NSNull class]]||(warrantyInfo.length==0)) {
                    warrantyInfo =@"";
                }
                
                if ([materialMade isKindOfClass:[NSNull class]]||(materialMade.length==0)) {
                    materialMade =@"";
                }
                
                if ([shape isKindOfClass:[NSNull class]]||(shape.length==0)) {
                    shape =@"";
                }
                
                if ([color isKindOfClass:[NSNull class]]||(color.length==0)) {
                    color =@"";
                }
                
                if ([size isKindOfClass:[NSNull class]]||(size.length==0)) {
                    size =@"";
                }
                
                if ([yearMade isKindOfClass:[NSNull class]]||([yearMade  isEqual: @"0"]) || [yearMade intValue] ==0) {
                    yearMade =@"";
                }
                
                if ([currentValue isKindOfClass:[NSNull class]]||[currentValue isEqualToString:@"0.00"] || [currentValue intValue] ==0) {
                    currentValue =@"";
                }
                
                if ([isInsured isKindOfClass:[NSNull class]]) {
                    isInsured =@"";
                }
                
                if ([isTaxable isKindOfClass:[NSNull class]]) {
                    isTaxable =@"";
                }
                
                if ([comments isKindOfClass:[NSNull class]]||(comments.length==0)) {
                    comments =@"";
                }
                
                if ([insuredBy isKindOfClass:[NSNull class]]||(insuredBy.length==0)) {
                    insuredBy =@"";
                }
                
                if ([insuredPolicy isKindOfClass:[NSNull class]]||(insuredPolicy.length==0)) {
                    insuredPolicy =@"";
                }
                
                if ([leaseStartDate isKindOfClass:[NSNull class]]||([leaseStartDate isEqualToString:@"0000-00-00"])) {
                    leaseStartDate =@"";
                }
                
                if ([leaseEndDate isKindOfClass:[NSNull class]]||([leaseEndDate isEqualToString:@"0000-00-00"])) {
                    leaseEndDate =@"";
                }
                
                if ([leaseDesc isKindOfClass:[NSNull class]]||(leaseDesc.length==0)) {
                    leaseDesc =@"";
                }
                
                if ([datePurchase isKindOfClass:[NSNull class]]||([datePurchase isEqualToString:@"0000-00-00"])) {
                    datePurchase =@"";
                }
                
                if ([replacementCost isKindOfClass:[NSNull class]]||([replacementCost isEqual:@"0.00"])) {
                    replacementCost =@"";
                }
                
                if ([serialNum isKindOfClass:[NSNull class]]||(serialNum.length==0)) {
                    serialNum =@"";
                }
                
                if ([placedInService isKindOfClass:[NSNull class]]||(placedInService.length==0)) {
                    placedInService =@"";
                }
                
                if ([usePercentage isKindOfClass:[NSNull class]]||([usePercentage  isEqual: @"0"]) || [usePercentage intValue] ==0) {
                    usePercentage =@"";
                }
                if ([salvageValue isKindOfClass:[NSNull class]]||([salvageValue isEqual:@"0"]) || [salvageValue intValue] ==0) {
                    salvageValue =@"";
                }
                if ([depreciationMethod isKindOfClass:[NSNull class]]||([depreciationMethod isEqual:@"0"]) || [depreciationMethod intValue] ==0) {
                    depreciationMethod =@"";
                }
                if ([beneficiary isKindOfClass:[NSNull class]]||(beneficiary.length==0)) {
                    beneficiary =@"";
                }
                if ([lifeInYears isKindOfClass:[NSNull class]]||([lifeInYears isEqual:@"0"]) || [lifeInYears intValue]==0) {
                    lifeInYears =@"";
                }
                
                if ([serverTimeStamp isKindOfClass:[NSNull class]]) {
                    serverTimeStamp =@"";
                }
//                if ([pdflink isKindOfClass:[NSNull class]]) {
//                    pdflink =@"";
//                }
                
                if (datePurchase.length !=0){
                    [self formatResponseDate:datePurchase];
                    datePurchase =formattedRespDateStr;
                }if (soldDate.length !=0){
                    [self formatResponseDate:soldDate];
                    soldDate =formattedRespDateStr;
                }if (warrantyExpire.length !=0){
                    [self formatResponseDate:warrantyExpire];
                    warrantyExpire =formattedRespDateStr;
                }if(leaseStartDate.length !=0){
                    [self formatResponseDate:leaseStartDate];
                    leaseStartDate =formattedRespDateStr;
                }
                if(leaseEndDate.length !=0){
                    [self formatResponseDate:leaseEndDate];
                    leaseEndDate =formattedRespDateStr;
                }
                name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                manufacturer = [manufacturer stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                soldTo = [soldTo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                insuredBy = [insuredBy stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
       
                invoiceNum = [invoiceNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                brand = [brand stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                model = [model stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                quantity = [quantity stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                size = [size stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                shape = [shape stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                color = [color stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                warrantyInfo = [warrantyInfo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                insuredPolicy = [insuredPolicy stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                serialNum = [serialNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                placedInService = [placedInService stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                salvageValue = [salvageValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                depreciationMethod = [depreciationMethod stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                beneficiary = [beneficiary stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                comments = [comments stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                materialMade = [materialMade stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item' (ServerID,RoomID,HouseID,Name,Description,Category,DatePurchase,InvoiceNum,Manufacturer,Cost,Brand,Model,Condition,Quantity,Status,Size,YearMade,MaterialMade,Shape,Color,IsTaxable,IsInsured,SoldTo,SoldDate,SoldPrice,WarrantyExpire,WarrantyInfo,InsuredBy,InsuredPolicy,LeaseStartDate,LeaseEndDate,LeaseDesc,ReplacementCost,SerialNum,PlacedInService,UsePercentage,SalvageValue,DepreciationMethod,Beneficiary,LifeInYears,Comments,CurrentValue,SyncStatus,ServerTimeStamp)VALUES ('%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",itemServerID,roomLocalID,houseLocalID,name,description,category,datePurchase,invoiceNum,manufacturer,cost,brand,model,condition,quantity,status,size,yearMade,materialMade,shape,color,isTaxable,isInsured,soldTo,soldDate,soldPrice,warrantyExpire,warrantyInfo,insuredBy,insuredPolicy,leaseStartDate,leaseEndDate,leaseDesc,replacementCost,serialNum,placedInService,usePercentage,salvageValue,depreciationMethod,beneficiary,lifeInYears,comments,currentValue,@"Sync",serverTimeStamp]];//Divya
                if (itemImagesAry.count >0 || itemImagesAry.count !=0) {
                    [self insertImages:itemImagesAry WithItemServerID:itemServerID];
                }
            }
        }
    }else{
        NSMutableArray *itemServerIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM Item"] resultsArray:itemServerIDAry];
        NSLog(@"itemServerIDAry %@", itemServerIDAry);

        NSMutableArray *itemLocalServerIds = [[NSMutableArray alloc]init];

        
        for (int i=0; i<[itemLocalServerIds count]; i++) {
            NSDictionary *tempLocalServerIDDict = [itemLocalServerIds objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [itemLocalServerIds addObject:localServerId];
        }

        NSArray *tempStaticRespItemArray = [[NSArray alloc]init];
        tempStaticRespItemArray = [resp objectForKey:@"Items"];
        NSMutableArray *tempRespItemArray = [tempStaticRespItemArray mutableCopy];
        NSMutableArray *remainingItemArray = [[NSMutableArray alloc]init];

        for (int i =0; i<[tempRespItemArray count]; i++) {
            NSDictionary *tempDict = [tempRespItemArray  objectAtIndex:i];
             if ((tempDict == (id)[NSNull null]) ||(tempDict==nil)) {//Divya
            }else{//Divya
            NSString *updatedRecordStatus = [tempDict objectForKey:@"Status"];
            NSString *serverID = [tempDict objectForKey:@"ServerID"];
            NSString *localID = [tempDict objectForKey:@"ID"];
            NSString *curdValue = [tempDict objectForKey:@"CRUD"];
            NSArray *itemImagesAry = [tempDict objectForKey:@"Images"];
            NSString *serverTimeStamp = [tempDict objectForKey:@"ServerTimeStamp"];

            itemSuccessUpdated = NO;
            
            if ([updatedRecordStatus isEqualToString:@"Success"]) {
                

                if ([curdValue isEqualToString:@"D"]) {
                    NSString *itemLocalID = [self getLocalIDTable:@"Item" ForID:serverID];

                    [dbManager execute:[NSString stringWithFormat:@"Delete From Item where ServerId = '%@'",serverID]];
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ItemId = '%@'",itemLocalID]];

                }else if([curdValue isEqualToString:@"C"]){
                    
                    if ([localID isKindOfClass:[NSNull class]]) {
                        localID =@"";
                    }
                    if ([serverID isKindOfClass:[NSNull class]]) {
                        serverID =@"";
                    }
                    
                    [dbManager execute:[NSString stringWithFormat:@"Update Item set ServerId = '%@',syncStatus='%@',ServerTimeStamp='%@' where ID = '%@'",serverID,@"Sync",serverTimeStamp,localID]];
                    
                    

                    
                }else if ([curdValue isEqualToString:@"U"]){
                    
                    if ([serverID isKindOfClass:[NSNull class]]) {
                        serverID =@"";
                    }
                    [dbManager execute:[NSString stringWithFormat:@"Update Item set syncStatus='%@',ServerTimeStamp='%@' where ServerId = '%@'",@"Sync",serverTimeStamp,serverID]];
                }
                
                if (itemImagesAry.count >0) {
                    [self insertImages:itemImagesAry WithItemServerID:serverID];
                }

                
            }else if ([updatedRecordStatus isEqualToString:@"Deleted"]){
                
                NSString *itemLocalID = [self getLocalIDTable:@"Item" ForID:serverID];
                [dbManager execute:[NSString stringWithFormat:@"Delete From Item where ServerId = '%@'",serverID]];
                [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ItemId = '%@'",itemLocalID]];

            }else if ([updatedRecordStatus isEqualToString:@"Fail"]){
               
                if (itemImagesAry.count >0) {
                    [self insertImages:itemImagesAry WithItemServerID:serverID];
                }

            }else{
                if ([updatedRecordStatus isEqualToString:@""]) {
                    if ([curdValue isEqualToString:@"R"]) {
                        NSLog(@"Crud operation");
                    }else{
                        [remainingItemArray addObject:tempDict];
                    }
                }else{
                    [remainingItemArray addObject:tempDict];
                }
            }
        }
    }
        
        
        NSMutableArray *afterUpdateItemServerIDAry = [[NSMutableArray alloc]init];
    
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM Item"] resultsArray:afterUpdateItemServerIDAry];
        NSLog(@"serverIDAry %@", itemServerIDAry);
        
        itemLocalServerIds = [[NSMutableArray alloc]init];
        
        for (int i=0; i<[afterUpdateItemServerIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [afterUpdateItemServerIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [itemLocalServerIds addObject:localServerId];
        }
        
        NSLog(@"itemLocalServerIds %@", itemLocalServerIds);

        
        for (int i=0; i<[remainingItemArray count]; i++) {
            
            NSDictionary *tempElementsDict = [remainingItemArray  objectAtIndex:i];
            
            // all id's
            NSString *itemServerID = [tempElementsDict objectForKey:@"id"];//Divya
//            NSString *itemServerID = [tempElementsDict objectForKey:@"item_id"];//Divya
            NSString *itemServerHouseID = [tempElementsDict objectForKey:@"house_id"];
            NSString *itemServerRoomID = [tempElementsDict objectForKey:@"room_id"];
            
            NSString *name= [tempElementsDict objectForKey:@"name"];
            NSString *description= [tempElementsDict objectForKey:@"description"];
            NSString *category =[tempElementsDict objectForKey:@"category"];
            NSString *datePurchase =[tempElementsDict objectForKey:@"date_purchase"];
            NSString *invoiceNum =[tempElementsDict objectForKey:@"invoice_num"];
            NSString *manufacturer =[tempElementsDict objectForKey:@"manufacturer"];
            NSString *cost =[tempElementsDict objectForKey:@"cost"];
            NSString *brand =[tempElementsDict objectForKey:@"brand"];
            NSString *model =[tempElementsDict objectForKey:@"model"];
            NSString *condition =[tempElementsDict objectForKey:@"item_condition"];
            NSString *quantity =[tempElementsDict objectForKey:@"quantity"];
            NSString *status =[tempElementsDict objectForKey:@"status"];
            NSString *size=[tempElementsDict objectForKey:@"size"];//Divya
            NSString *yearMade=[tempElementsDict objectForKey:@"year_made"];
            NSString *materialMade=[tempElementsDict objectForKey:@"material_made"];
            NSString *shape=[tempElementsDict objectForKey:@"shape"];
            NSString *color=[tempElementsDict objectForKey:@"color"];
            NSString *isTaxable=[tempElementsDict objectForKey:@"is_taxable"];
            NSString *isInsured=[tempElementsDict objectForKey:@"is_insured"];
            NSString *soldTo=[tempElementsDict objectForKey:@"sold_to"];
            NSString *soldDate=[tempElementsDict objectForKey:@"sold_date"];
            NSString *soldPrice=[tempElementsDict objectForKey:@"sold_price"];
            NSString *warrantyExpire=[tempElementsDict objectForKey:@"warranty_expire"];
            NSString *warrantyInfo=[tempElementsDict objectForKey:@"warranty_info"];
            NSString *insuredBy=[tempElementsDict objectForKey:@"insured_by"];
            NSString *insuredPolicy=[tempElementsDict objectForKey:@"insure_policy"];
            NSString *leaseStartDate=[tempElementsDict objectForKey:@"lease_start"];
            NSString *leaseEndDate=[tempElementsDict objectForKey:@"lease_end"];
            NSString *leaseDesc=[tempElementsDict objectForKey:@"lease_description"];
            NSString *replacementCost=[tempElementsDict objectForKey:@"replacement_cost"];
            NSString *serialNum=[tempElementsDict objectForKey:@"serial_num"];
            NSString *placedInService=[tempElementsDict objectForKey:@"placed_into_service"];
            NSString *usePercentage=[tempElementsDict objectForKey:@"biz_use_percent"];
            NSString *salvageValue=[tempElementsDict objectForKey:@"salvage_value"];
            NSString *depreciationMethod=[tempElementsDict objectForKey:@"depreciation_method"];
            NSString *beneficiary=[tempElementsDict objectForKey:@"beneficiary"];
            NSString *lifeInYears=[tempElementsDict objectForKey:@"life_in_years"];
            NSString *comments=[tempElementsDict objectForKey:@"comments"];
            NSString *currentValue= [tempElementsDict objectForKey:@"current_value"];//Divya
            NSString *serverTimeStamp = [tempElementsDict objectForKey:@"ServerTimeStamp"];

//            NSString *pdflink= [tempElementsDict objectForKey:@"pdf"];//Divya

            
            if ([itemServerID isKindOfClass:[NSNull class]]) {
                itemServerID =@"";
            }
            
            if ([quantity isKindOfClass:[NSNull class]] || [quantity intValue]==0 ) {
                quantity =@"";
            }
            
            
            if ([cost isKindOfClass:[NSNull class]]||[cost isEqualToString:@"0.00"] || [cost intValue] ==0) {
                cost =@"";
            }
            
            if ([soldDate isKindOfClass:[NSNull class]]||([soldDate isEqualToString:@"0000-00-00"])) {
                soldDate =@"";
            }
            
            if ([soldTo isKindOfClass:[NSNull class]]||(soldTo.length==0)) {
                soldTo =@"";
            }
            
            if ([soldPrice isKindOfClass:[NSNull class]]||([soldPrice isEqual:@"0.00"])) {
                soldPrice =@"";
            }
            
            if ([warrantyExpire isKindOfClass:[NSNull class]]||([warrantyExpire isEqualToString:@"0000-00-00"])) {
                warrantyExpire =@"";
            }
            
            if ([warrantyInfo isKindOfClass:[NSNull class]]||(warrantyInfo.length==0)) {
                warrantyInfo =@"";
            }
            
            if ([materialMade isKindOfClass:[NSNull class]]||(materialMade.length==0)) {
                materialMade =@"";
            }
            
            if ([shape isKindOfClass:[NSNull class]]||(shape.length==0)) {
                shape =@"";
            }
            
            if ([color isKindOfClass:[NSNull class]]||(color.length==0)) {
                color =@"";
            }
            
            if ([size isKindOfClass:[NSNull class]]||(size.length==0)) {
                size =@"";
            }
            
            if ([yearMade isKindOfClass:[NSNull class]]||([yearMade  isEqual: @"0"]) || [yearMade intValue] ==0) {
                yearMade =@"";
            }
            
            if ([currentValue isKindOfClass:[NSNull class]]||[currentValue isEqualToString:@"0.00"] || [currentValue intValue] ==0) {
                currentValue =@"";
            }
            
            if ([isInsured isKindOfClass:[NSNull class]]) {
                isInsured =@"";
            }
            
            if ([isTaxable isKindOfClass:[NSNull class]]) {
                isTaxable =@"";
            }
            
            if ([comments isKindOfClass:[NSNull class]]||(comments.length==0)) {
                comments =@"";
            }
            
            if ([insuredBy isKindOfClass:[NSNull class]]||(insuredBy.length==0)) {
                insuredBy =@"";
            }
            
            if ([insuredPolicy isKindOfClass:[NSNull class]]||(insuredPolicy.length==0)) {
                insuredPolicy =@"";
            }
            
            if ([leaseStartDate isKindOfClass:[NSNull class]]||([leaseStartDate isEqualToString:@"0000-00-00"])) {
                leaseStartDate =@"";
            }
            
            if ([leaseEndDate isKindOfClass:[NSNull class]]||([leaseEndDate isEqualToString:@"0000-00-00"])) {
                leaseEndDate =@"";
            }
            
            if ([leaseDesc isKindOfClass:[NSNull class]]||(leaseDesc.length==0)) {
                leaseDesc =@"";
            }
            
            if ([datePurchase isKindOfClass:[NSNull class]]||([datePurchase isEqualToString:@"0000-00-00"])) {
                datePurchase =@"";
            }
            
            if ([replacementCost isKindOfClass:[NSNull class]]||([replacementCost isEqual:@"0.00"])) {
                replacementCost =@"";
            }
            
            if ([serialNum isKindOfClass:[NSNull class]]||(serialNum.length==0)) {
                serialNum =@"";
            }
            
            if ([placedInService isKindOfClass:[NSNull class]]||(placedInService.length==0)) {
                placedInService =@"";
            }
            
            if ([usePercentage isKindOfClass:[NSNull class]]||([usePercentage  isEqual: @"0"]) || [usePercentage intValue] ==0) {
                usePercentage =@"";
            }
            if ([salvageValue isKindOfClass:[NSNull class]]||([salvageValue isEqual:@"0"]) || [salvageValue intValue] ==0) {
                salvageValue =@"";
            }
            if ([depreciationMethod isKindOfClass:[NSNull class]]||([depreciationMethod isEqual:@"0"]) || [depreciationMethod intValue] ==0) {
                depreciationMethod =@"";
            }
            if ([beneficiary isKindOfClass:[NSNull class]]||(beneficiary.length==0)) {
                beneficiary =@"";
            }
            if ([lifeInYears isKindOfClass:[NSNull class]]||([lifeInYears isEqual:@"0"]) || [lifeInYears intValue]==0) {
                lifeInYears =@"";
            }
            
            if ([serverTimeStamp isKindOfClass:[NSNull class]]) {
                serverTimeStamp =@"";
            }
//            if ([pdflink isKindOfClass:[NSNull class]]) {
//                pdflink =@"";
//            }
            
            if (datePurchase.length !=0){
                [self formatResponseDate:datePurchase];
                datePurchase =formattedRespDateStr;
            }if (soldDate.length !=0){
                [self formatResponseDate:soldDate];
                soldDate =formattedRespDateStr;
            }if (warrantyExpire.length !=0){
                [self formatResponseDate:warrantyExpire];
                warrantyExpire =formattedRespDateStr;
            }if(leaseStartDate.length !=0){
                [self formatResponseDate:leaseStartDate];
                leaseStartDate =formattedRespDateStr;
            }
            if(leaseEndDate.length !=0){
                [self formatResponseDate:leaseEndDate];
                leaseEndDate =formattedRespDateStr;
            }
            
            NSString *houseLocalID = [self getLocalIDTable:@"House" ForID:itemServerHouseID];
            NSString *roomLocalID = [self getLocalIDTable:@"Room" ForID:itemServerRoomID];
            NSArray *itemImagesAry = [tempElementsDict objectForKey:@"Images"];

            
            for (int j=0; j<[itemLocalServerIds count]; j++) {
                NSString *tempLocalServerID = [itemLocalServerIds objectAtIndex:j];
                if ([tempLocalServerID intValue] == [itemServerID intValue]) {
                    
                    
                    
                    NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
                    [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Item where ServerId='%@'",itemServerID] resultsArray:syncDetails];
                    
                    NSLog(@"syncDetails %@", syncDetails);
                    
                    NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
                    if ([syncValue isEqualToString:@"Delete"]) {
                        
                    }else{
                        
                        NSMutableArray *pdfPathAry = [[NSMutableArray alloc]init];
                        [dbManager execute:[NSString stringWithFormat:@"SELECT PdfPath FROM Item Where ServerId = '%@' ",itemServerID] resultsArray:pdfPathAry];
                        NSLog(@"pdfPathAry %@", pdfPathAry);
                        
                        NSString *pdfPath;
                        if ([pdfPathAry count] !=0) {
                            NSDictionary *tempDict = [pdfPathAry objectAtIndex:0];
                            pdfPath = [tempDict valueForKey:@"PdfPath"];
                            NSLog(@"pdfPathAry %@", pdfPath);
                            if (pdfPath.length !=0) {
                                [self removePdf:pdfPath];
                            }
                        }
                        
                        
                        name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        manufacturer = [manufacturer stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        soldTo = [soldTo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        insuredBy = [insuredBy stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                        
                        invoiceNum = [invoiceNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        brand = [brand stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        model = [model stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                        quantity = [quantity stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        size = [size stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                        shape = [shape stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        color = [color stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        warrantyInfo = [warrantyInfo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        insuredPolicy = [insuredPolicy stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        serialNum = [serialNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                        placedInService = [placedInService stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                        salvageValue = [salvageValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                        depreciationMethod = [depreciationMethod stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        beneficiary = [beneficiary stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        comments = [comments stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        materialMade = [materialMade stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

                        [dbManager execute:[NSString stringWithFormat:@"Update Item set Name = '%@',Description='%@',Category='%@',DatePurchase='%@', InvoiceNum='%@',Manufacturer='%@',Cost='%@',Brand='%@', Model='%@',Condition ='%@',Quantity='%@',Status='%@',Size='%@',YearMade='%@',MaterialMade='%@',Shape='%@',Color='%@',IsTaxable='%@',IsInsured='%@',SoldTo='%@',SoldDate='%@',SoldPrice='%@',WarrantyExpire='%@',WarrantyInfo='%@',InsuredBy='%@',InsuredPolicy='%@',LeaseStartDate='%@',LeaseEndDate='%@',LeaseDesc='%@',ReplacementCost='%@',SerialNum='%@',PlacedInService='%@',UsePercentage='%@',SalvageValue='%@',DepreciationMethod='%@',Beneficiary='%@',LifeInYears='%@', SyncStatus='%@',Comments='%@',CurrentValue='%@',ServerTimeStamp='%@'    where ServerId = '%@'",name,description,category,datePurchase,invoiceNum,manufacturer,cost,brand,model,condition,quantity,status,size,yearMade,materialMade,shape,color,isTaxable,isInsured,soldTo,soldDate,soldPrice,warrantyExpire,warrantyInfo,insuredBy,insuredPolicy,leaseStartDate,leaseEndDate,leaseDesc,replacementCost,serialNum,placedInService,usePercentage,salvageValue,depreciationMethod,beneficiary,lifeInYears,@"Sync",comments,currentValue,serverTimeStamp,itemServerID]];
                        
                        if(itemImagesAry.count > 0 || itemImagesAry.count !=0){
                            [self insertImages:itemImagesAry WithItemServerID:itemServerID];
                        }else{
                            
                            NSLog(@"remove local images ");
                            NSString *itemLocalId = [self getLocalIDTable:@"Item" ForID:itemServerID];
                            
                            
                            dbManager = [DataBaseManager dataBaseManager];
                            NSMutableArray *imagePathAry = [[NSMutableArray alloc]init];
                            [dbManager execute:[NSString stringWithFormat:@"Select ImagePath,Id From Images where ItemID = '%@'",itemLocalId] resultsArray:imagePathAry];
                            
                            if(imagePathAry.count !=0){
                                
                                for(int i=0; i<[imagePathAry count]; i++){
                                    NSString *imgPath = [[imagePathAry objectAtIndex:i]valueForKey:@"ImagePath"];
                                    NSString *imgId = [[imagePathAry objectAtIndex:i]valueForKey:@"ID"];
                                  
                                    if(imgPath.length !=0){
                                        [self removeImage:imgPath];
                                        [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ID = '%@'",imgId]];
                                        
                                    }

                                }
                    
                                
                            }

                            
                            
                            
                            
//                            for (int localIdIndex=0; localIdIndex<[localServerIds count]; localIdIndex++) {
//                                BOOL imageAvailableInServer = NO;
//                                NSString *localIDValue = [localServerIds objectAtIndex:localIdIndex];
//                                for (int serverIdIndex=0; serverIdIndex<[imagesAry count]; serverIdIndex++) {
//                                    NSString *serverIDValue = [[imagesAry objectAtIndex:serverIdIndex] objectForKey:@"ServerID"];
//                                    if ([localIDValue intValue] == [serverIDValue intValue]) {
//                                        imageAvailableInServer = YES;
//                                        break;
//                                    }else{
//                                        imageAvailableInServer = NO;
//                                        continue;
//                                    }
//                                }
//                                if (imageAvailableInServer == NO) {
//                                    dbManager = [DataBaseManager dataBaseManager];
//                                    NSMutableArray *imagePathAry = [[NSMutableArray alloc]init];
//                                    [dbManager execute:[NSString stringWithFormat:@"Select ImagePath From Images where ServerID = '%@'",localIDValue] resultsArray:imagePathAry];
//                                    
//                                    if(imagePathAry.count !=0){
//                                        NSString *imgPath = [[imagePathAry objectAtIndex:0]valueForKey:@"ImagePath"];
//                                        if(imgPath.length !=0){
//                                            [self removeImage:imgPath];
//                                        }
//                                    }
//                                    [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ServerID = '%@'",localIDValue]];
//                                }
//                            }

                            
                        }
                            

                    }
                         //                    [dbManager execute:[NSString stringWithFormat:@"Update Item set Name = '%@',Description = '%@',Type = '%@',syncStatus='%@'  where ServerId = '%@'",name,description,roomType,@"Sync",roomServerID]];
                    itemUpdated = YES;
                    break;
                }else{
                    itemUpdated = NO;
                    continue;
                }
            }
            
            if (itemUpdated == NO) {
              //  [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item' (ServerID,RoomID,HouseID,Name,Description,Category,DatePurchase,InvoiceNum,Manufacturer,Cost,Brand,Model,Condition,Quantity,Status,YearMade,MaterialMade,Shape,Color,IsTaxable,IsInsured,SoldTo,SoldDate,SoldPrice,WarrantyExpire,WarrantyInfo,InsuredBy,InsuredPolicy,LeaseStartDate,LeaseEndDate,LeaseDesc,ReplacementCost,SerialNum,PlacedInService,UsePercentage,SalvageValue,DepreciationMethod,Beneficiary,LifeInYears,Comments,SyncStatus)VALUES ('%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",itemServerID,roomLocalID,houseLocalID,name,description,category,datePurchase,invoiceNum,manufacturer,cost,brand,model,condition,quantity,status,yearMade,materialMade,shape,color,isTaxable,isInsured,soldTo,soldDate,soldPrice,warrantyExpire,warrantyInfo,insuredBy,insuredPolicy,leaseStartDate,leaseEndDate,leaseDesc,replacementCost,serialNum,placedInService,usePercentage,salvageValue,depreciationMethod,beneficiary,lifeInYears,comments,@"Sync"]];//Divya
                
                
                
                name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                description = [description stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                manufacturer = [manufacturer stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                soldTo = [soldTo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                insuredBy = [insuredBy stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                invoiceNum = [invoiceNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                brand = [brand stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                model = [model stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                quantity = [quantity stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                size = [size stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                shape = [shape stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                color = [color stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                warrantyInfo = [warrantyInfo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                insuredPolicy = [insuredPolicy stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                serialNum = [serialNum stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                placedInService = [placedInService stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                salvageValue = [salvageValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                depreciationMethod = [depreciationMethod stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                beneficiary = [beneficiary stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                comments = [comments stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                materialMade = [materialMade stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

                
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item' (ServerID,RoomID,HouseID,Name,Description,Category,DatePurchase,InvoiceNum,Manufacturer,Cost,Brand,Model,Condition,Quantity,Status,Size,YearMade,MaterialMade,Shape,Color,IsTaxable,IsInsured,SoldTo,SoldDate,SoldPrice,WarrantyExpire,WarrantyInfo,InsuredBy,InsuredPolicy,LeaseStartDate,LeaseEndDate,LeaseDesc,ReplacementCost,SerialNum,PlacedInService,UsePercentage,SalvageValue,DepreciationMethod,Beneficiary,LifeInYears,CurrentValue,Comments,SyncStatus,ServerTimeStamp)VALUES ('%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",itemServerID,roomLocalID,houseLocalID,name,description,category,datePurchase,invoiceNum,manufacturer,cost,brand,model,condition,quantity,status,size,yearMade,materialMade,shape,color,isTaxable,isInsured,soldTo,soldDate,soldPrice,warrantyExpire,warrantyInfo,insuredBy,insuredPolicy,leaseStartDate,leaseEndDate,leaseDesc,replacementCost,serialNum,placedInService,usePercentage,salvageValue,depreciationMethod,beneficiary,lifeInYears,currentValue,comments,@"Sync",serverTimeStamp]];//Divya
                if (itemImagesAry.count >0 || itemImagesAry.count !=0) {
                    [self insertImages:itemImagesAry WithItemServerID:itemServerID];
                }

                itemInserted = YES;
            }
        }
    }
    return YES;
}


-(BOOL)insertImages:(NSArray *)imagesAry WithItemServerID:(NSString*)itemID{
    NSString *localItemID = [self getLocalIDTable:@"Item" ForID:itemID];

    
    NSLog(@"imagesAry %@", imagesAry);
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *localImgAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images Where ItemId='%@'",localItemID] resultsArray:localImgAry];

    if (localImgAry.count ==0) {
        for (int i=0; i<[imagesAry count]; i++) {
            NSDictionary *tempDict = [imagesAry objectAtIndex:i];
            NSString *serverID = [tempDict objectForKey:@"ServerID"];
            NSString *tempFileUrl= [tempDict objectForKey:@"FileURL"];
            
            
//            NSString *tempFile = [tempDict objectForKey:@"FileURL"];
//            NSString *tempFileUrl = [tempFile stringByReplacingOccurrencesOfString:@"rhm.mlx.com" withString:@"192.168.137.20"];


            NSMutableArray *itemHouseID = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat: @"SELECT HouseID FROM Item Where ID = '%@'",localItemID] resultsArray:itemHouseID];
            NSLog(@"itemHouseID %@", itemHouseID);
            
            if ([itemHouseID count] !=0) {
                NSString *houseID = [[itemHouseID objectAtIndex:0]valueForKey:@"HouseID"];
                
                NSMutableArray *itemRoomID = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat: @"SELECT RoomID FROM Item Where ID = '%@'",localItemID] resultsArray:itemRoomID];
                NSLog(@"itemHouseID %@", itemRoomID);
                NSString *roomID = [[itemRoomID objectAtIndex:0]valueForKey:@"RoomID"];
                
                if ([tempFileUrl isKindOfClass:[NSNull class]]||(tempFileUrl.length==0)) {
                    tempFileUrl =@"";
                }if ([serverID isKindOfClass:[NSNull class]]) {
                    serverID =@"";
                }if ([houseID isKindOfClass:[NSNull class]]) {
                    houseID =@"";
                }
                if ([roomID isKindOfClass:[NSNull class]]) {
                    roomID =@"";
                }if ([localItemID isKindOfClass:[NSNull class]]) {
                    localItemID =@"";
                }
                
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (ServerPath, ServerId,HouseID,RoomID,ItemID,SyncStatus)VALUES ('%@','%@','%@','%@','%@','%@')",tempFileUrl,serverID,houseID,roomID,localItemID,@"Sync"]];
            }
        }
    }else{
        
        NSMutableArray *serverIDAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM Images Where ItemID = '%@'",localItemID] resultsArray:serverIDAry];
        NSLog(@"serverIDAry %@", serverIDAry);
        
        NSMutableArray *localServerIds = [[NSMutableArray alloc]init];
        NSMutableArray *respServerIds = [[NSMutableArray alloc]init];
        NSLog(@"respServerIds %@", respServerIds);

        for (int i=0; i<[serverIDAry count]; i++) {
            NSDictionary *tempLocalServerIDDict = [serverIDAry objectAtIndex:i];
            NSString *localServerId = [tempLocalServerIDDict objectForKey:@"ServerID"];
            [localServerIds addObject:localServerId];
        }
        NSMutableArray *remainingImagesArray = [[NSMutableArray alloc]init];

        
        
        for (int i =0; i<[imagesAry count]; i++) {
            NSDictionary *tempDict = [imagesAry  objectAtIndex:i];
            
            NSString *updatedRecordStatus = [tempDict objectForKey:@"Status"];
            NSString *serverID = [tempDict objectForKey:@"ServerID"];
            NSString *localID = [tempDict objectForKey:@"ID"];
            NSString *curdValue = [tempDict objectForKey:@"CRUD"];
            NSString *fileUrl = [tempDict objectForKey:@"FileURL"];
            NSLog(@"fileUrl %@", fileUrl);

            imageSuccessUpdated = NO;

            if ([updatedRecordStatus isEqualToString:@"Success"]) {
                
                if ([curdValue isEqualToString:@"D"]) {
                    [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ServerID = '%@'",serverID]];
                    
                }else if([curdValue isEqualToString:@"C"]){
                    
                    if ([localID isKindOfClass:[NSNull class]]) {
                        localID =@"";
                    }
                    if ([serverID isKindOfClass:[NSNull class]]) {
                        serverID =@"";
                    }
                    [dbManager execute:[NSString stringWithFormat:@"Update Images set ServerId = '%@',syncStatus='%@'  where ID = '%@'",serverID,@"Sync",localID]];
                    
                }else if ([curdValue isEqualToString:@"U"]){
                   
                    if ([serverID isKindOfClass:[NSNull class]]) {
                        serverID =@"";
                    }
                    [dbManager execute:[NSString stringWithFormat:@"Update Images set syncStatus='%@'  where ServerId = '%@'",@"Sync",serverID]];
                }else if ([curdValue isEqualToString:@"R"]){
                    if ([localID isKindOfClass:[NSNull class]]) {
                        localID =@"";
                    }
                    if ([serverID isKindOfClass:[NSNull class]]) {
                        serverID =@"";
                    }
                    [dbManager execute:[NSString stringWithFormat:@"Update Images set syncStatus='%@'  where ServerId = '%@'",@"Sync",serverID]];
                }
                
                
            }else if ([updatedRecordStatus isEqualToString:@"Deleted"]){
                [dbManager execute:[NSString stringWithFormat:@"Delete From Images where HouseID = '%@'",serverID]];
                
            } else{
                if ([updatedRecordStatus isEqualToString:@""]) {
                    if ([curdValue isEqualToString:@"R"]) {
                        
                    }else{
                        [remainingImagesArray addObject:tempDict];
                    }
                }else{
                    [remainingImagesArray addObject:tempDict];
                }
            }
            
        }
        
        
        for (int localIdIndex=0; localIdIndex<[localServerIds count]; localIdIndex++) {
            BOOL imageAvailableInServer = NO;
            NSString *localIDValue = [localServerIds objectAtIndex:localIdIndex];
            for (int serverIdIndex=0; serverIdIndex<[imagesAry count]; serverIdIndex++) {
                NSString *serverIDValue = [[imagesAry objectAtIndex:serverIdIndex] objectForKey:@"ServerID"];
                if ([localIDValue intValue] == [serverIDValue intValue]) {
                    imageAvailableInServer = YES;
                    break;
                }else{
                    imageAvailableInServer = NO;
                    continue;
                }
            }
            if (imageAvailableInServer == NO) {
                dbManager = [DataBaseManager dataBaseManager];
                NSMutableArray *imagePathAry = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat:@"Select ImagePath From Images where ServerID = '%@'",localIDValue] resultsArray:imagePathAry];
                
                if(imagePathAry.count !=0){
                    NSString *imgPath = [[imagePathAry objectAtIndex:0]valueForKey:@"ImagePath"];
                    if(imgPath.length !=0){
                        [self removeImage:imgPath];
                    }
                }
                [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ServerID = '%@'",localIDValue]];
            }
        }

        
        
        for (int i=0; i<[remainingImagesArray count]; i++) {
            
            NSDictionary *tempElementsDict = [remainingImagesArray  objectAtIndex:i];
            NSString *tempServerId = [tempElementsDict objectForKey:@"ServerID"];
            NSString *tempFileUrl = [tempElementsDict objectForKey:@"FileURL"];
            
            for (int j=0; j<[localServerIds count]; j++) {
                NSString *tempLocalServerID = [localServerIds objectAtIndex:j];
                //                if ([tempLocalServerID isEqualToString:tempServerId]) {
                if ([tempLocalServerID intValue] == [tempServerId intValue]) {
                    if ([tempFileUrl isKindOfClass:[NSNull class]]||(tempFileUrl.length==0)) {
                        tempFileUrl =@"";
                    }
                    if ([tempServerId isKindOfClass:[NSNull class]]) {
                        tempServerId =@"";
                    }
                    
                    [dbManager execute:[NSString stringWithFormat:@"Update Images set ServerPath = '%@',syncStatus ='%@' where ServerId = '%@'",tempFileUrl,@"Sync",tempServerId]];
                    
                    imageUpdated = YES;
                    break;
                }else{
                    imageUpdated = NO;
                    continue;
                }
            }
            
            if (imageUpdated == NO) {
                
                NSMutableArray *itemHouseID = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat: @"SELECT HouseID FROM Item Where ID = '%@'",localItemID] resultsArray:itemHouseID];
                NSLog(@"itemHouseID %@", itemHouseID);
                NSString *houseID = [[itemHouseID objectAtIndex:0]valueForKey:@"HouseID"];
                
                NSMutableArray *itemRoomID = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat: @"SELECT RoomID FROM Item Where ID = '%@'",localItemID] resultsArray:itemRoomID];
                NSLog(@"itemHouseID %@", itemRoomID);
                NSString *roomID = [[itemRoomID objectAtIndex:0]valueForKey:@"RoomID"];

                if ([tempFileUrl isKindOfClass:[NSNull class]]||(tempFileUrl.length==0)) {
                    tempFileUrl =@"";
                }if ([tempServerId isKindOfClass:[NSNull class]]) {
                    tempServerId =@"";
                }if ([houseID isKindOfClass:[NSNull class]]) {
                    houseID =@"";
                }
                if ([roomID isKindOfClass:[NSNull class]]) {
                    roomID =@"";
                }if ([localItemID isKindOfClass:[NSNull class]]) {
                    localItemID =@"";
                }
                
                [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (ServerPath, ServerId,HouseID,RoomID,ItemID,SyncStatus)VALUES ('%@','%@','%@','%@','%@','%@')",tempFileUrl,tempServerId,houseID,roomID,localItemID,@"Sync"]];
                imageInserted = YES;
            }
        }
        
    }
    return YES;
}


-(NSString *)getServerIDTable:(NSString *)table ForID:(NSString *)localID{
    dbManager = [DataBaseManager dataBaseManager];
    NSLog(@"tableName %@, localRoomID %@",table,localID);
    NSMutableArray *serverIDAry = [[NSMutableArray alloc]init];
   [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM %@ Where ID = '%@' ",table,localID] resultsArray:serverIDAry];
    NSLog(@"serverIDAry %@", serverIDAry);
    NSString *serverID;
    if ([serverIDAry count] !=0) {
        NSDictionary *tempDict = [serverIDAry objectAtIndex:0];
        serverID = [tempDict valueForKey:@"ServerID"];
        NSLog(@"serverID %@", serverID);
    }
    return serverID;
}

-(NSString *)getLocalIDTable:(NSString *)table ForID:(NSString *)serverID{
    NSLog(@"tableName %@, localRoomID %@",table,serverID);
    NSMutableArray *localIDAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
   [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM %@ Where ServerID = '%@' ",table,serverID] resultsArray:localIDAry];
    NSLog(@"localIDAry %@", localIDAry);
    NSString *localID;
    if ([localIDAry count] !=0) {
        NSDictionary *tempDict = [localIDAry objectAtIndex:0];
        localID = [tempDict valueForKey:@"ID"];
        NSLog(@"localID %@", localID);
    }
    return localID;
}

-(BOOL)formatResponseDate:(NSString *)responseString{
    
    NSString *dateStr = [NSString stringWithFormat: @"%@",responseString];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-mm-dd"];    //Divya
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"mm/dd/yyyy"];//Divya
    NSDate *currentDate = [formate dateFromString:dateStr];
    NSString *formattedDateStr = [dateFormat stringFromDate:currentDate];
    NSLog(@" unFormattedDateStr:%@",responseString);
    NSLog(@" formattedDateStr:%@",formattedDateStr);
    formattedRespDateStr =formattedDateStr;
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
