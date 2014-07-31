//
//  ViewController.m
//  HomeBook
//
//  Created by Manulogix on 13/06/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *standardUserDefaults1 = [NSUserDefaults standardUserDefaults];
    isLaunching = [standardUserDefaults1 objectForKey:@"IsLaunching"];
    houseImage = [[UIImageView alloc] init];
    
    if ([isLaunching isEqualToString:@"YES"]) {
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            [houseImage setFrame:CGRectMake(0, 290+40, 1024, 440)];
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            [houseImage setFrame:CGRectMake(0, 290, 768, 440)];
        }
        [houseImage setImage:[UIImage imageNamed:@"house.jpg"]];
        [self.view addSubview:houseImage];
    }else{
        loginSubView.hidden = NO;
        
        if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            [houseImage setFrame:CGRectMake(0, 577, 768, 440)];
        }
        [houseImage setImage:[UIImage imageNamed:@"house.jpg"]];
        [self.view addSubview:houseImage];
    }
    
    [userNameField setValue:[UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [passwordField setValue:[UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];

	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)demoBtnClicked:(id)sender{
    
    userNameField.text=@"";
    passwordField.text=@"";
    [self loginBtnClicked:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    isDemoAc = NO;
    [self showImage];
}

-(void)showImage{
    if ([isLaunching isEqualToString:@"YES"]) {
        sleep(2);
        loginSubView.hidden = NO;
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view]      cache:YES];
            [houseImage setFrame:CGRectMake(houseImage.frame.origin.x,577,768,houseImage.frame.size.height)];
            [UIView commitAnimations];
            houseImage.hidden = YES;
            
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view]      cache:YES];
            [houseImage setFrame:CGRectMake(houseImage.frame.origin.x,577,768,houseImage.frame.size.height)];
            [UIView commitAnimations];
        }
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults) {
            [standardUserDefaults setObject:@"NO" forKey:@"IsLaunching"];
            [standardUserDefaults synchronize];
        }
        
    }else{
        loginSubView.hidden = NO;
        if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            [houseImage setFrame:CGRectMake(0, 577, 768, 440)];
        }
        [houseImage setImage:[UIImage imageNamed:@"house.jpg"]];
        [self.view addSubview:houseImage];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        svos = loginSubView.contentOffset;
        CGPoint pt;
        CGRect rc = [textField bounds];
        rc = [textField convertRect:rc toView:loginSubView];
        pt = rc.origin;
        pt.x = 0;
        pt.y -= 40;
        [loginSubView setContentOffset:pt animated:YES];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [loginSubView setContentOffset:svos animated:YES];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //    NSLog(@"textFieldDidEndEditing");
}
-(IBAction)signUpBtnClicked:(id)sender{
    [self performSegueWithIdentifier:@"SegueToSignUp" sender:self];
}
-(IBAction)loginBtnClicked:(id)sender{
    [self.view endEditing:YES];
    dbManager = [DataBaseManager dataBaseManager];
    
    NSString *tempUserName;
    NSString *tempPassword;
    
    if (sender == nil) {
        isDemoAc = YES;
        tempUserName = DEMO_USERNAME;
        tempPassword = DEMO_PASSWORD;
    }else{
        isDemoAc = NO;
        tempUserName = userNameField.text;
        tempPassword = passwordField.text;
        
    }
    if (tempUserName.length == 0) {
        
        [FAUtilities showAlert:@"Please Enter Username"];
        loginSuccess = NO;
        return;
    }else if (tempPassword.length == 0){
        [FAUtilities showAlert:@"Please Enter Password"];
        loginSuccess = NO;
        return;
    }else{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSError* error = nil;
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
        
        if (![fileManager fileExistsAtPath:rhmDir]){
            [fileManager createDirectoryAtPath:rhmDir withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
        rhmDir =[rhmDir stringByAppendingPathComponent:CurrentUser_ID];
        if (CurrentUser_ID) {
            
            if (![fileManager fileExistsAtPath:rhmDir]){
                [fileManager createDirectoryAtPath:rhmDir withIntermediateDirectories:NO attributes:nil error:&error];
            }else {
            }
            rhmDir= [rhmDir stringByAppendingPathComponent:@"Image"];
        }
        if (![fileManager fileExistsAtPath:rhmDir]){
            [fileManager createDirectoryAtPath:rhmDir withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        
        NSMutableArray *localLoginDetails = [[NSMutableArray alloc]init];
        dbManager = [DataBaseManager dataBaseManager];
        
        [dbManager execute:[NSString stringWithFormat:@"Update LoginDetails set CurrentUser = 'OFF'"]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (defaults) {
            [defaults setObject:@"NoDemo" forKey:@"DemoLogout"];
            [defaults setObject:@"" forKey:@"viewType"];
            [defaults setObject:@"" forKey:@"Type"];
            [defaults setObject:@"" forKey:@"EditHouseNameArray"];
            [defaults setObject:@"" forKey:@"EditRoomNameArray"];
            [defaults setObject:@"" forKey:@"Searching"];
            [defaults setObject:@"" forKey:@"SearchValue"];
            [defaults setObject:@"" forKey:@"ID"];
            [defaults setObject:@"" forKey:@"HouseID"];
            [defaults setObject:@"" forKey:@"RowID"];
            [defaults setObject:@"" forKey:@"HousesAryONAddhouse"];
            [defaults setObject:@"" forKey:@"SearchHousesArray"];
            [defaults setObject:@"" forKey:@"SearchRoomsArray"];
            [defaults setObject:@"" forKey:@"serchedItemAry"];
            [defaults setObject:@"" forKey:@"RoomID"];
            [defaults setObject:@"" forKey:@"MakeTextFieldEmpty"];
            [defaults setObject:@"" forKey:@"CurrentHouseName"];
            [defaults setObject:@"" forKey:@"Name"];
            [defaults setObject:@"" forKey:@"SectionID"];
            [defaults setObject:@"" forKey:@"UserServerID"];
            [defaults setObject:@"" forKey:@"CURRENT_USER_LOCAL_ID"];
            
        }

        
        
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails"] resultsArray:localLoginDetails];
//        NSLog(@"localLoginDetails %@", localLoginDetails);
        if (localLoginDetails.count !=0) {
            for (int i = 0; i<[localLoginDetails count]; i++) {
                NSDictionary *currentDict = [localLoginDetails objectAtIndex:i];
                NSString *loginUserName = [currentDict objectForKey:@"LoginUserName"];
                
                if ([loginUserName isEqualToString:tempUserName]) {
//                    NSLog(@"login table contains records");
                    isFistLogin = NO;
                    break;
                }else{
//                    NSLog(@"login table not contains records");
                    isFistLogin = YES;
                }
                
            }
            
            [self postRequest:LOGIN_TYPE];
            
        }else{
            //            [self performSegueWithIdentifier:@"SegueLoginToDashboard" sender:self];
//            NSLog(@"login table not contains records");
            isFistLogin = YES;
            [self postRequest:LOGIN_TYPE];
        }
    }
}

-(void)postRequest:(NSString *)reqType{
    
    [self.view endEditing:YES];
    NSString *requestURL;
    NSString *formattedBodyStr;
    
    if ([reqType isEqualToString:LOGIN_TYPE]) {//Divya
        formattedBodyStr= [self jsonFormat:LOGIN_TYPE withDictionary:nil];
        requestURL =LOGIN_REQUEST_URL;//Divya
    } else if ([reqType isEqualToString:LOOKUP_TYPE]){
        formattedBodyStr= [self jsonFormat:LOOKUP_TYPE withDictionary:nil];
        requestURL =SYNC_REQ_URL;
    }
    
    NSData *postJsonData = [formattedBodyStr dataUsingEncoding:NSUTF8StringEncoding];
    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
    webServiceInterface.delegate =self;
    
    

    [webServiceInterface sendRequest:formattedBodyStr PostJsonData:postJsonData Req_Type:reqType Req_url:requestURL];
    
    
//    formattedBodyStr = @"{\"JsonData\":\"{\"CRUD\":\"R\",\"Type\":\"TriggerSettings\",\"SAFE_ID\":2}\"}";
//    NSData *postJsonData = [formattedBodyStr dataUsingEncoding:NSUTF8StringEncoding];
//    [webServiceInterface sendRequest:formattedBodyStr PostJsonData:postJsonData Req_Type:reqType Req_url:@"http://192.168.137.15/CETSVC/CETService.svc/ProcessRequest"];

    
}


-(NSString*)jsonFormat:(NSString *)type withDictionary:(NSMutableDictionary *)formatDict{
    NSString *bodyStr;
    if ([type isEqualToString:LOGIN_TYPE]) {
        if (isDemoAc==YES) {
            bodyStr= [NSString stringWithFormat:@"{\"Type\":\"%@\",\"Username\":\"%@\",\"Password\":\"%@\"}", type,DEMO_USERNAME,DEMO_PASSWORD];
        }else{
            bodyStr= [NSString stringWithFormat:@"{\"Type\":\"%@\",\"Username\":\"%@\",\"Password\":\"%@\"}", type,userNameField.text, passwordField.text];
        }
    }else if ([type isEqualToString:LOOKUP_TYPE]){
        bodyStr= [NSString stringWithFormat:@"{\"Type\":\"%@\",\"UserID\":\"%@\"}", type, @""];
    }
    return bodyStr;
}



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //    if ( loginSuccess == YES) {
    //        return YES;
    //    }else{
    return NO;
    //    }
}


-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([respType isEqualToString:LOGIN_TYPE]) {
        if (resp == NULL) {
            [FAUtilities showAlert:[resp valueForKey:@"Unable to Login"]];
        }else if ([[resp valueForKey:@"Status"] isEqualToString:@"Fail"]) {
            loginSuccess = NO;
            [FAUtilities showAlert:[resp valueForKey:@"Message"]];
        }else{
            loginSuccess = YES;
            
            
            NSString *familyName = [resp valueForKey:@"Family"];
            if(familyName.length==0||[familyName isKindOfClass:[NSNull class]]){
                familyName = @"";
            }
            
            NSMutableDictionary *defaultsTest = [[NSMutableDictionary alloc]init];
            
            if (isDemoAc ==YES) {
                [defaultsTest setObject:DEMO_USERNAME forKey:@"Username"];
                [defaultsTest setObject:DEMO_PASSWORD forKey:@"Password"];
                
            }else{
                [defaultsTest setObject:userNameField.text forKey:@"Username"];
                [defaultsTest setObject:passwordField.text forKey:@"Password"];
            }
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (userDefaults) {
                [userDefaults setObject:defaultsTest forKey:@"LoginDetails"];
                [userDefaults synchronize];
            }
            
            NSDictionary *test = [resp objectForKey:@"Data"];
            NSArray *tempAry = [test valueForKey:@"Houses"];
            
            
            
            if (standardUserDefaults) {
                [standardUserDefaults setObject:tempAry forKey:@"Houses"];
                [standardUserDefaults synchronize];
            }
            NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
            dbManager = [DataBaseManager dataBaseManager];
            
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails"] resultsArray:loginDetails];
            
            for (int i=0; i<[loginDetails count]; i++) {
                NSDictionary *testDict = [loginDetails objectAtIndex:i];
                NSString *localUserName = [testDict objectForKey:@"LoginUserName"];
                
                if ([localUserName isEqualToString:userNameField.text]) {
                    UpdateUser = YES;
                    break;
                }else{
                    if (isDemoAc==YES) {
                        UpdateUser = YES;
                        break;
                    }else{
                        UpdateUser = NO;
                    }
                }
            }
            
            if (UpdateUser == YES) {
                
                if ([userNameField.text isKindOfClass:[NSNull class]]||(userNameField.text.length==0)) {
                    userNameField.text =@"";
                }
                if ([passwordField.text isKindOfClass:[NSNull class]]||(passwordField.text.length==0)) {
                    passwordField.text =@"";
                }
                
                if(isDemoAc==YES){
                    
                    NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
                    NSMutableArray *loginTempDetails = [[NSMutableArray alloc]init];

                    dbManager = [DataBaseManager dataBaseManager];
                    
                    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails"] resultsArray:loginDetails];
                    
                    for (int i=0; i<[loginDetails count]; i++) {
                        NSDictionary *testDict = [loginDetails objectAtIndex:i];
                        NSString *localUserName = [testDict objectForKey:@"LoginUserName"];
                        [loginTempDetails addObject:localUserName];
                    }
                    
                    if ([loginTempDetails containsObject:DEMO_USERNAME]) {
                        [dbManager execute:[NSString stringWithFormat: @"Update 'LoginDetails' set LoginUserName = '%@',Password ='%@',CurrentUser ='%@', UserID='%@',User_Type='%@',Family='%@' where LoginUserName = '%@'",DEMO_USERNAME,DEMO_PASSWORD,@"ON",[resp valueForKey:@"UserID"],DEMO_USERTYPE,familyName,DEMO_USERNAME]];
                    }else{
                        [dbManager execute:[NSString stringWithFormat: @"Delete FROM LoginDetails where User_Type='%@'",DEMO_USERTYPE]];
                        [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'LoginDetails' (LoginUserName, Password,CurrentUser,UserID,User_Type,Family)VALUES ('%@', '%@','%@','%@','%@','%@')",DEMO_USERNAME,DEMO_PASSWORD,@"ON",[resp valueForKey:@"UserID"],DEMO_USERTYPE,familyName]];
                    }
                    
                    currentDemoUserIdAry =[[NSMutableArray alloc]init];
                    [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM LoginDetails where LoginUserName = '%@'",DEMO_USERNAME] resultsArray:currentDemoUserIdAry];
                    
                    if ([currentDemoUserIdAry count]>0) {
                        [standardUserDefaults setObject:[[currentDemoUserIdAry valueForKey:@"ID"] objectAtIndex:0] forKey:@"CURRENT_USER_LOCAL_ID"];
                        
                    }
                    [standardUserDefaults setObject:[resp valueForKey:@"UserID"] forKey:@"UserServerID"];
                }else{
                    [dbManager execute:[NSString stringWithFormat: @"Update 'LoginDetails' set LoginUserName = '%@',Password ='%@',CurrentUser ='%@', UserID='%@',User_Type='%@',Family='%@' where LoginUserName = '%@'",userNameField.text,passwordField.text,@"ON",[resp valueForKey:@"UserID"],LOGIN_USERTYPE,familyName,userNameField.text]];
                    currentUserIdAry =[[NSMutableArray alloc]init];
                    [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM LoginDetails where LoginUserName = '%@'",userNameField.text] resultsArray:currentUserIdAry];
                    
                    if ([currentUserIdAry count]>0) {
                        [standardUserDefaults setObject:[[currentUserIdAry valueForKey:@"ID"] objectAtIndex:0] forKey:@"CURRENT_USER_LOCAL_ID"];
                    }
                    [standardUserDefaults setObject:[resp valueForKey:@"UserID"] forKey:@"UserServerID"];
                }
            }else{
                
                if ([userNameField.text isKindOfClass:[NSNull class]]||(userNameField.text.length==0)) {
                    userNameField.text =@"";
                }

                if ([passwordField.text isKindOfClass:[NSNull class]]||(passwordField.text.length==0)) {
                    passwordField.text =@"";
                }
                
                if(isDemoAc==YES){
                    [dbManager execute:[NSString stringWithFormat: @"Delete FROM LoginDetails where User_Type='%@'",DEMO_USERTYPE]];
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'LoginDetails' (LoginUserName, Password,CurrentUser,UserID,User_Type,Family)VALUES ('%@', '%@','%@','%@','%@','%@')",DEMO_USERNAME,DEMO_PASSWORD,@"ON",[resp valueForKey:@"UserID"],DEMO_USERTYPE,familyName]];
                    currentInsertDemoUserIdAry =[[NSMutableArray alloc]init];
                    [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM LoginDetails where LoginUserName = '%@'",DEMO_USERNAME] resultsArray:currentInsertDemoUserIdAry];
                    if ([currentInsertDemoUserIdAry count]>0) {
                        [standardUserDefaults setObject:[[currentInsertDemoUserIdAry valueForKey:@"ID"] objectAtIndex:0] forKey:@"CURRENT_USER_LOCAL_ID"];
                        
                    }
                    [standardUserDefaults setObject:[resp valueForKey:@"UserID"] forKey:@"UserServerID"];
                    
                }else{
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'LoginDetails' (LoginUserName, Password,CurrentUser,UserID,User_Type,Family)VALUES ('%@', '%@','%@','%@','%@','%@')",userNameField.text,passwordField.text,@"ON",[resp valueForKey:@"UserID"],LOGIN_USERTYPE,familyName]];
                    currentInsertUserIdAry =[[NSMutableArray alloc]init];
                    [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM LoginDetails where LoginUserName = '%@'",userNameField.text] resultsArray:currentInsertUserIdAry];
                    if ([currentInsertUserIdAry count]>0) {
                        [standardUserDefaults setObject:[[currentInsertUserIdAry valueForKey:@"ID"] objectAtIndex:0] forKey:@"CURRENT_USER_LOCAL_ID"];
                        
                    }
                    [standardUserDefaults setObject:[resp valueForKey:@"UserID"] forKey:@"UserServerID"];
                    
                }
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
            
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
            NSString *serverID= [standardUserDefaults valueForKey:@"UserServerID"];

            NSLog(@"serverID:%d",[serverID integerValue]);

            rhmDir =[rhmDir stringByAppendingPathComponent:CurrentUser_ID];
            if (CurrentUser_ID) {
                
                if (![fileManager fileExistsAtPath:rhmDir]){
                    [fileManager createDirectoryAtPath:rhmDir withIntermediateDirectories:NO attributes:nil error:&error];
                }else {
                }
                
                
                rhmDir= [rhmDir stringByAppendingPathComponent:@"Image"];
            }
            if (![fileManager fileExistsAtPath:rhmDir]){
                [fileManager createDirectoryAtPath:rhmDir withIntermediateDirectories:NO attributes:nil error:&error];
            }else {
            }
            //            }
            //lookups
            [self postRequest:LOOKUP_TYPE];
            
            
            if (isFistLogin == YES) {
                webServiceUtils = [[WebServiceUtils alloc]initWithVC:self];
                webServiceUtils.delegate =self;
                BOOL val = [webServiceUtils postRequest:SYNC_HOUSE_TYPE withHouseID:nil];
                NSLog(@"val %d", val);
                
            }else{
                [self performSegueWithIdentifier:@"SegueLoginToDashboard" sender:self];
            }
        }
    }
    else if ([respType isEqualToString:LOOKUP_TYPE]) {
        if (resp == NULL) {
            [FAUtilities showAlert:[resp valueForKey:@"Unable to Get Lookups"]];
        }else if ([[resp valueForKey:@"Status"] isEqualToString:@"Fail"]) {
            [FAUtilities showAlert:[resp valueForKey:@"Message"]];
        }else{
            dbManager = [DataBaseManager dataBaseManager];
            [dbManager execute:[NSString stringWithFormat:@"DELETE FROM RoomType"]];
            [dbManager execute:[NSString stringWithFormat:@"DELETE FROM Item_Category"]];
            [dbManager execute:[NSString stringWithFormat:@"DELETE FROM Item_Condition"]];
            [dbManager execute:[NSString stringWithFormat:@"DELETE FROM Item_Status"]];
            
            
            NSMutableArray *item_CategoriesArray =[[NSMutableArray alloc]init];
            item_CategoriesArray =[resp valueForKey:@"ItemCategory"];
            
            NSMutableArray *item_ConditionArray =[[NSMutableArray alloc]init];
            item_ConditionArray =[resp valueForKey:@"ItemCondition"];
            
            NSMutableArray *room_TypeArray =[[NSMutableArray alloc]init];
            room_TypeArray =[resp valueForKey:@"RoomType"];
            
            NSMutableArray *item_StatusArray =[[NSMutableArray alloc]init];
            item_StatusArray =[resp valueForKey:@"ItemStatus"];
            
            if (room_TypeArray.count !=0) {
                for (int i=0; i<[room_TypeArray count]; i++) {
                    NSDictionary *room_Type_Dict = [room_TypeArray objectAtIndex:i];
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'RoomType' (Type,Description,RoomType_ID)VALUES ('%@','%@','%@')",[room_Type_Dict valueForKey:@"type"],[room_Type_Dict valueForKey:@"description"],[room_Type_Dict valueForKey:@"id"]]];
                }
            }if (item_CategoriesArray.count !=0) {
                for (int j=0; j<[item_CategoriesArray count]; j++) {
                    NSDictionary *item_Category_Dict = [item_CategoriesArray objectAtIndex:j];
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item_Category' (Name,Description,Category_ID)VALUES ('%@','%@','%@')",[item_Category_Dict valueForKey:@"name"],[item_Category_Dict valueForKey:@"description"],[item_Category_Dict valueForKey:@"cat_id"]]];
                }
            }
            if (item_ConditionArray.count !=0) {
                for (int k=0; k<[item_ConditionArray count]; k++) {
                    NSDictionary *item_Condition_Dict = [item_ConditionArray objectAtIndex:k];
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item_Condition' (Type,Description,Condition_ID)VALUES ('%@','%@','%@')",[item_Condition_Dict valueForKey:@"type"],[item_Condition_Dict valueForKey:@"description"],[item_Condition_Dict valueForKey:@"id"]]];
                }
            }
            if (item_StatusArray.count !=0) {
                for (int k=0; k<[item_StatusArray count]; k++) {
                    NSDictionary *item_Status_Dict = [item_StatusArray objectAtIndex:k];
                    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item_Status' (Status,Status_ID)VALUES ('%@','%@')",[item_Status_Dict valueForKey:@"status"],[item_Status_Dict valueForKey:@"id"]]];
                }
            }
        }
        
    }
}


-(void)getStatus:(NSDictionary *)status{
    
    NSString *houseResp = [status objectForKey:SYNC_HOUSE_TYPE];
    NSString *roomResp = [status objectForKey:SYNC_ROOM_TYPE];
    NSString *itemResp = [status objectForKey:SYNC_ITEM_TYPE];
    
    
    if ([houseResp isEqualToString:@"Complete"] && [roomResp isEqualToString:@"Complete"] && [itemResp isEqualToString:@"Complete"]) {
        
    }else if([houseResp isEqualToString:@"HouseFailed"]){
        
    }else if ([roomResp isEqualToString:@"RoomFailed"]){
        
    }else if ([itemResp isEqualToString:@"ItemFailed"]){
        
    }
    if (houseResp.length !=0 && roomResp.length !=0 && itemResp.length !=0) {
        [self performSegueWithIdentifier:@"SegueLoginToDashboard" sender:self];
    }
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view endEditing:YES];
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        houseImage.hidden = NO;
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        houseImage.hidden = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
