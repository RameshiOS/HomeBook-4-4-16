//
//  DashBoardViewController.m
//  RoyalHouseManagement
//
//  Created by Manulogix on 29/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "DashBoardViewController.h"

@interface DashBoardViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end


@implementation DashBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    bgTask = 0;

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(logOutBtnClicked:)];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f]];
    
    
    UIFont *font = [UIFont boldSystemFontOfSize:22];
 
    [item setTitleTextAttributes:@{NSFontAttributeName: font}
                                     forState:UIControlStateNormal];

    
    [item setTintColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f]]; // Change to your colour

//    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: font}
//                                                          forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = item;

    [self.revealButtonItem setTintColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f]]; // Change to your colour

    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector( revealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *houseName = [defaults objectForKey:@"CurrentHouseName"];
    [defaults synchronize];
    dbManager = [DataBaseManager dataBaseManager];
    if (houseName.length == 0) {
        NSMutableArray *houseNameAry = [[NSMutableArray alloc]init];
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
//        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House"] resultsArray:houseNameAry];
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus !='Delete' and UserID='%@'",user_Server_ID] resultsArray:houseNameAry];

        
        NSLog(@"houseNameAry %@", houseNameAry);
        if (houseNameAry.count >0) {
            houseName = [[houseNameAry objectAtIndex:0]valueForKey:@"Name"];
        }
    }
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbarpotrait.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
//    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
//    titleView.backgroundColor = [UIColor clearColor];
//    titleView.font = [UIFont boldSystemFontOfSize:20.0];
//    titleView.textColor = [FAUtilities getUIColorObjectFromHexString:@"#6F4925" alpha:1]; // Your color here
//    titleView.text =@"Royal House Management";
//    self.navigationItem.titleView = titleView;
    
//    [titleView sizeToFit];
    containerForRoom.hidden = YES;
    containerForHouse.hidden = NO;
}


-(void)viewWillAppear:(BOOL)animated{
   
}


-(IBAction)SyncBtnClicked:(id)sender{
//    webServiceUtils = [[WebServiceUtils alloc]initWithVC:self];
//    webServiceUtils.delegate =self;
//    [webServiceUtils postRequest:SYNC_HOUSE_TYPE];
}



-(void)getStatus:(NSDictionary *)status{
}


-(void)logOutBtnClicked:(id)sender{
   dbManager = [DataBaseManager dataBaseManager];
   
    NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails"] resultsArray:loginDetails];
    
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTask != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        NSLog(@"end bgTask");
    }
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
    
    NSLog(@"user_Server_ID %@", user_Server_ID);

    NSString *bodyStr = [NSString stringWithFormat:@"{\"Type\":\"%@\",\"UserID\":\"%@\"}", @"Logout",user_Server_ID];
    NSData *postJsonData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
    webServiceInterface.delegate =self;
    [webServiceInterface sendRequest:bodyStr PostJsonData:postJsonData Req_Type:LOGOUT_TYPE Req_url:LOGOUT_REQUEST_URL];
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
    
//    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:vc animated:YES completion:nil];
}

- (void)removeDemo:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
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
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbarpotrait.png"] forBarMetrics:UIBarMetricsDefault];
        
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
        
    }
}

-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{

    NSLog(@"Resp %@", resp);

    if ([[resp valueForKey:@"Status"] isEqualToString:@"Success"]) {
       dbManager = [DataBaseManager dataBaseManager];
        NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails"] resultsArray:loginDetails];

        for (int i=0; i<[loginDetails count]; i++) {
            NSDictionary *testDict = [loginDetails objectAtIndex:i];
            NSString *currentUser = [testDict valueForKey:@"CurrentUser"];
            NSString *User_Type = [testDict valueForKey:@"User_Type"];
            NSLog(@"User_Type %@", User_Type);

            
            if ([currentUser isEqualToString:@"ON"]) {
                    [dbManager execute:[NSString stringWithFormat:@"Update LoginDetails set CurrentUser = 'OFF' where ID = '%d'", [[testDict valueForKey:@"ID"] intValue]]];
            }
        }

        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (defaults) {
            [defaults setObject:@"" forKey:@"viewType"];
            [defaults synchronize];
        }

        ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:vc animated:YES completion:nil];

    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
