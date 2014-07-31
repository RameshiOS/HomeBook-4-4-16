//
//  ContainerViewController.m
//  RoyalHouseManagement
//
//  Created by Manulogix on 22/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "ContainerViewController.h"
#import "AddItemViewController.h"
//#import "ItemUploadsViewController.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController
@synthesize checkedIndexPath;
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
    sleep(0.5);
    //    containerScrollView.layer.borderColor = [[UIColor redColor]CGColor];
    //    containerScrollView.layer.borderWidth = 1;
    
    dbManager = [DataBaseManager dataBaseManager];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
    
    houseSettingsList =[[NSMutableArray alloc]initWithObjects:@"Upload House Images",@"Edit House",@"Add Room",@"Delete House", nil];
    optionsListAry = [[NSMutableArray alloc]initWithObjects:@"Add Item",@"Delete Room",@"Edit Room", nil];
    
    deleteHouseImgBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
    
    deleteItemBtn= [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
    emailItemBtn= [[UIButton alloc]initWithFrame:CGRectMake(45, 5, 35, 35)];
    viewPdfItemButton= [[UIButton alloc]initWithFrame:CGRectMake(85, 5, 35, 35)];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    typeStr = [defaults objectForKey:@"Type"];
    nameStr = [defaults objectForKey:@"Name"];
    
    
    NSString *isSearching = [defaults objectForKey:@"Searching"];
    NSString *searchValue = [defaults objectForKey:@"SearchValue"];
    
    isSearcingItem      = [defaults objectForKey:@"Searching"];
    itemSearchedString  = searchValue;
    
    NSString  *viewType = [defaults objectForKey:@"viewType"];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbarpotrait.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f]];
    
    if ([typeStr isEqualToString:@"Room"]) {
        roomIdStr = [defaults objectForKey:@"ID"];
        houseIdStr = [defaults objectForKey:@"HouseID"];
        
        NSString *rowID  = [defaults objectForKey:@"RowID"];
        int multiple = [rowID intValue]-1;
        float contentOffsetht =(float)multiple*210;
        
        [containerScrollView setContentOffset:CGPointMake(containerScrollView.frame.origin.x,contentOffsetht) animated:YES];
        //        [containerScrollView scrollRectToVisible:CGRectMake(containerScrollView.frame.origin.x, contentOffsetht, containerScrollView.frame.size.width, containerScrollView.frame.size.height+contentOffsetht) animated:YES];
        
    }
    else{
        houseIdStr = [defaults objectForKey:@"ID"];
    }
    
    [defaults synchronize];
    
    // house details
    
    houseDetails = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *totalhouses = [[NSMutableArray alloc]init];
    
    if (houseIdStr.length ==0) {
        
        if ([viewType isEqualToString:@"AddHouse"]) {
            NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
            houseDetails = [tempDefaults objectForKey:@"HousesAryONAddhouse"];
            
        }else if ([viewType isEqualToString:@"EditHouse"]) {
            
            NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
            editHouseNameDetails = [tempDefaults objectForKey:@"EditHouseNameArray"];
            
            NSLog(@"Name = '%@'  where House ID = '%@' ",[[editHouseNameDetails valueForKey:@"Name"]objectAtIndex:0],[[editHouseNameDetails valueForKey:@"ID"]objectAtIndex:0]);
            
            
            [dbManager execute:[NSString stringWithFormat:@"Update House set SyncStatus='Update' where ID = '%@'",[[editHouseNameDetails valueForKey:@"ID"]objectAtIndex:0]]];
            
            houseDetails =editHouseNameDetails;
            isHouseUpdated = YES;
            updateHouseID =[NSString stringWithFormat:@"%@",houseIdStr];
            [self addHouseBtnClicked:nil];
            
        }else if ([viewType isEqualToString:@"EditRoom"]) {
            NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
            editRoomNameDetails = [tempDefaults objectForKey:@"EditRoomNameArray"];
            
            NSLog(@"Name = '%@'  where Room ID = '%@',HouseID='%@'",[[editRoomNameDetails valueForKey:@"Name"]objectAtIndex:0],[[editRoomNameDetails valueForKey:@"ID"]objectAtIndex:0],[[editRoomNameDetails valueForKey:@"HouseID"]objectAtIndex:0]);
            [dbManager execute:[NSString stringWithFormat:@"Update Room set SyncStatus='Update'  where ID = '%@' and HouseID='%@'",[[editRoomNameDetails valueForKey:@"ID"]objectAtIndex:0],[[editRoomNameDetails valueForKey:@"HouseID"]objectAtIndex:0]]];
            
            roomsArray =editRoomNameDetails;
            updateRoomID =[NSString stringWithFormat:@"%@",[[editRoomNameDetails valueForKey:@"ID"]objectAtIndex:0]];
            isRoomUpdated = YES;
            [self addRoomBtnClicked:nil];
        }else{
            
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus != 'Delete' and UserID='%@'",user_Server_ID] resultsArray:totalhouses];
        }
        
        if (totalhouses.count >0) {
            houseIdStr = [[totalhouses objectAtIndex:0] valueForKey:@"ID"];
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where ID = '%@' AND (SyncStatus = 'Sync' or SyncStatus = 'New' or SyncStatus = 'Update')",houseIdStr] resultsArray:houseDetails];
        }
    }
    else{
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where ID = '%@'  AND (SyncStatus = 'Sync' or SyncStatus = 'New' or SyncStatus = 'Update')",houseIdStr] resultsArray:houseDetails];
    }
    
    
    NSMutableArray *roomsAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Room Where HouseID = '%@' AND (SyncStatus = 'Sync' or SyncStatus = 'New' or SyncStatus = 'Update')",houseIdStr] resultsArray:roomsAry];
    
    if ([isSearching isEqualToString:@"1"]) {
        roomsAry = (NSMutableArray *)[defaults objectForKey:@"SearchRoomsArray"];
    }
    
    
    if (roomsAry.count  ==0 || roomsAry == nil ) {
        containerScrollView.hidden = YES;
    }else{
        containerScrollView.hidden = NO;
    }
    
    
    if ([houseDetails count] > 0) {
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:[houseDetails objectAtIndex:0] forKey:@"HouseDetails"];
        [standardUserDefaults synchronize];
        
        houseNameField.hidden = NO;
        houseAddrField.hidden = NO;
        houseDescTextView.hidden = NO;
        houseSettingsBtn.hidden = NO;
        houseSyncBtn.hidden = NO;
        scrollImgBgView.hidden = NO;
        globalSyncBtn.hidden = YES;
        houseIdStr = [[houseDetails objectAtIndex:0] valueForKey:@"ID"];
        
        
        houseNameField.text = [[houseDetails objectAtIndex:0] valueForKey:@"Name"];
        houseAddrField.text = [[houseDetails objectAtIndex:0] valueForKey:@"Address"];
        houseDescTextView.text = [[houseDetails objectAtIndex:0] valueForKey:@"Description"];
        
        NSString *houseAdress= houseAddrField.text;
        NSString *houseDesc = houseDescTextView.text;
        houseAdress=[houseAdress stringByReplacingOccurrencesOfString:@"\r" withString:@""];//multiLine Text
        houseAdress=[houseAdress stringByReplacingOccurrencesOfString:@"\n" withString:@""];//multiLine Text
        
        houseDesc=[houseDesc stringByReplacingOccurrencesOfString:@"\r" withString:@""];//multiLine Text
        houseDesc=[houseDesc stringByReplacingOccurrencesOfString:@"\n" withString:@""];//multiLine Text
        
        houseAddrField.text =houseAdress;
        houseDescTextView.text =houseDesc;
        
        NSLog(@"HouseDescText:%@",houseDescTextView.text);
        
        //        [self setupScrollView];
        //        [self drawAttchmentsView];
        
        if ([viewType isEqualToString:@"AddHouse"]) {
            [self addHouseBtnClicked:nil];
        }
        else if ([viewType isEqualToString:@"EditHouse"]) {
            
            NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
            editHouseNameDetails = [tempDefaults objectForKey:@"EditHouseNameArray"];
            
            NSLog(@"Name = '%@'  where House ID = '%@' ",[[editHouseNameDetails valueForKey:@"Name"] objectAtIndex:0],[[editHouseNameDetails valueForKey:@"ID"]objectAtIndex:0]);
            [dbManager execute:[NSString stringWithFormat:@"Update House set SyncStatus='Update' where ID = '%@'",[[editHouseNameDetails valueForKey:@"ID"]objectAtIndex:0]]];
            
            houseDetails =editHouseNameDetails;
            isHouseUpdated = YES;
            updateHouseID =[NSString stringWithFormat:@"%@",houseIdStr];
            [self addHouseBtnClicked:nil];
            
        }
        else if ([viewType isEqualToString:@"EditRoom"]) {
            NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
            editRoomNameDetails = [tempDefaults objectForKey:@"EditRoomNameArray"];
            
            NSLog(@"Name = '%@'  where Room ID = '%@',HouseID='%@'",[[editRoomNameDetails valueForKey:@"Name"]objectAtIndex:0],[[editRoomNameDetails valueForKey:@"ID"]objectAtIndex:0],[[editRoomNameDetails valueForKey:@"HouseID"]objectAtIndex:0]);
            [dbManager execute:[NSString stringWithFormat:@"Update Room set SyncStatus='Update'  where ID = '%@' and HouseID='%@'",[[editRoomNameDetails valueForKey:@"ID"]objectAtIndex:0],[[editRoomNameDetails valueForKey:@"HouseID"]objectAtIndex:0]]];
            
            roomsArray =editRoomNameDetails;
            updateRoomID =[NSString stringWithFormat:@"%@",[[editRoomNameDetails valueForKey:@"ID"]objectAtIndex:0]];
            isRoomUpdated = YES;
            [self addRoomBtnClicked:nil];
            
        }
        else if ([viewType isEqualToString:@"AddHouseShowAlert"]){
            [FAUtilities showAlert:@"You can add only 3 Houses"];
        }
        
    }
    else{
        globalSyncBtn.hidden = NO;
        houseNameField.hidden = YES;
        houseAddrField.hidden = YES;
        houseDescTextView.hidden = YES;
        houseSettingsBtn.hidden = YES;
        houseSyncBtn.hidden = YES;
        scrollImgBgView.hidden = YES;
        if ([viewType isEqualToString:@"AddHouse"]) {
            [self addHouseBtnClicked:nil];
        }else if ([viewType isEqualToString:@"AddHouseShowAlert"]){
            [FAUtilities showAlert:@"You can add only 3 Houses"];
        }
    }
    
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(handleGesture:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); // For Saving in libarary
    
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    
    NSLog(@"libraryPaths %@",libraryPaths);
    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *dataPath;
    NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError* error = nil;
    
    NSString *currentUser_IDVal= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
    
    dataPath= [rhmDir stringByAppendingPathComponent:currentUser_IDVal];
    
    if (currentUser_IDVal) {
        
        if (![fileManager fileExistsAtPath:dataPath]){
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        
        dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
    }
    
    
    housePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseIdStr]];
    
    
	if (![fileManager fileExistsAtPath:housePath]){
        [fileManager createDirectoryAtPath:housePath withIntermediateDirectories:NO attributes:nil error:&error];
	}else {
	}
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *roomUserDefaults = [NSUserDefaults standardUserDefaults];
    if (roomUserDefaults) {
        [roomUserDefaults setObject:@"" forKey:@"selectedRoomID"];
        [roomUserDefaults synchronize];
    }
    
	// Do any additional setup after loading the view.
}

//- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated{
//
//}
-(void)callAfterSixtySecond:(NSTimer *)timer{
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        pdfWebView.frame=CGRectMake(0, 0, 1024, 768);
        NSLog(@"land cal");
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        pdfWebView.frame=CGRectMake(0, 0, 768,1024);
        NSLog(@"pot cal");
        
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_View_1024x1024.png"]];
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawAttchmentsView];
    
    [self setupScrollView];
    if ([typeStr isEqualToString:@"Room"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *rowID  = [defaults objectForKey:@"RowID"];
        int multiple = [rowID intValue]-1;
        float contentOffsetht =(float)multiple*210;
        
        [containerScrollView setContentOffset:CGPointMake(containerScrollView.frame.origin.x,contentOffsetht) animated:YES];
        
        NSString *tempStr = [NSString stringWithFormat:@"%d",1];
        [defaults setObject:tempStr forKey:@"RowID"];
    }
}

/* Methods For Buttons*/
-(IBAction)houseSettingsBtnClicked:(id)sender{
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    
    [self addRoomCancelBtnClicked:nil];
    [self addHouseCancelBtnClicked:nil];
    
    [deleteHouseImgBtn removeFromSuperview];
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    UIButton *houseSettings = (UIButton *)sender;
    
    UIViewController* popoverContent = [[UIViewController alloc]init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 160)];
    //    popoverView.backgroundColor = [UIColor blackColor];
    
    houseListTableViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 250, 160)];
    houseListTableViewMenu.delegate = self;
    houseListTableViewMenu.dataSource = self;
    houseListTableViewMenu.rowHeight = 32;
    houseListTableViewMenu.tag = 1;
    [popoverView addSubview:houseListTableViewMenu];
    popoverContent.view = popoverView;
    //    popoverContent.contentSizeForViewInPopover = CGSizeMake(140, 102);
    popoverContent.preferredContentSize = CGSizeMake(250, 160);
    
    self.houseSettingsPopOver = [[UIPopoverController alloc]
                                 initWithContentViewController:popoverContent];
    self.houseSettingsPopOver.delegate =self;
    if ([self.houseSettingsPopOver isPopoverVisible]) {
        [self.houseSettingsPopOver dismissPopoverAnimated:YES];
    }
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.houseSettingsPopOver  presentPopoverFromRect:CGRectMake(0, 0, 133, 29)
                                                inView:houseSettings permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

-(IBAction)uploadHouseImagesBtnClicked:(id)sender{
    [deleteHouseImgBtn removeFromSuperview];
    [self.view endEditing:YES];
    
    NSMutableArray *houseImagesAry = [[NSMutableArray alloc]init];
    
    dbManager = [DataBaseManager dataBaseManager];
    
    
    [dbManager execute:[NSString stringWithFormat:@"SELECT Id FROM Images where HouseID= '%@' and  RoomID IS NULL and ItemID IS NULL AND SyncStatus != 'Delete'",houseIdStr] resultsArray:houseImagesAry];
    
    
    if ([houseImagesAry count]>=3) {
        [FAUtilities showAlertMessage:@"You can add only 3 House Images"];
    }else{
        photoSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camere Roll",@"Camera",nil];
        photoSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [photoSheet showFromRect:CGRectMake(houseSettingsBtn.frame.origin.x,houseSettingsBtn.frame.origin.y,100,100) inView:[self view] animated:YES];
        [photoSheet showInView:[self view]];
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    if (buttonIndex == 0) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoPopOver = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        photoPopOver.delegate =self;
        if ([photoPopOver isPopoverVisible]) {
            [photoPopOver dismissPopoverAnimated:YES];
        }
        [photoPopOver presentPopoverFromRect:CGRectMake(houseSettingsBtn.frame.origin.x,houseSettingsBtn.frame.origin.y,100,80) inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (buttonIndex == 1) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
       
//        BOOL isMainThread = [NSThread isMainThread];

//        if (![NSThread isMainThread]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:imagePicker animated:YES completion:NULL];
//            });
//        }else{
//            [self presentViewController:imagePicker animated:YES completion:NULL];
//        }
        
    }
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    [picker dismissViewControllerAnimated:NO completion:nil];
    

    
    UIImage *tempChosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    // for handling memory pressure handle images having more than 1000 width, with aspect ratio of height
    
    CGFloat width = tempChosenImage.size.width;
    CGFloat height = tempChosenImage.size.height;
    
    
    NSLog(@"Width:%f, Height:%f",width,height);
    
    
    UIImage *chosenImage;
    
    if (width >800) {
        float scaleFactor = 800 / width;
        float newHeight = height * scaleFactor;
        float newWidth = width * scaleFactor;
        chosenImage =[self imageWithImage:tempChosenImage scaledToSize:CGSizeMake(newWidth,newHeight)];
        NSData *reducedImageData = UIImageJPEGRepresentation(chosenImage, 0.8);;
        NSLog(@"reduced length %lu",(unsigned long)[reducedImageData length]);
    }else{
        chosenImage = tempChosenImage;
    }

    NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    
    NSLog(@"metadata %@", metadata);
    NSData *imgData;
    
    if (metadata != NULL) {
        imgData = UIImageJPEGRepresentation(chosenImage, 0.5);
    }else{
        imgData = [NSData dataWithData:UIImagePNGRepresentation(chosenImage)];
    }
    
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *houseImagesAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images where HouseID= '%@' and RoomID IS NULL and ItemID IS NULL AND SyncStatus != 'Delete'",houseIdStr] resultsArray:houseImagesAry];
    
    if ([houseImagesAry count]>=3) {
        [FAUtilities showAlert:@"You can add only 3 House Images"];
    }else{
        NSUInteger len = imgData.length;
        uint8_t *bytesAry = (uint8_t *)[imgData bytes];
        NSMutableString *imageByteAryresult = [NSMutableString stringWithCapacity:len * 3];
        NSMutableArray *bytesAryTest = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < len; i++) {
            if (i) {
                [imageByteAryresult appendString:@","];
            }
            [bytesAryTest addObject:[NSString stringWithFormat:@"%d",bytesAry[i]]];
            [imageByteAryresult appendFormat:@"%d", bytesAry[i]];
        }
        
        int currentID =[self lastInsertedRowID];
        
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
        NSString *fileName;
        NSString *storePath;
        if (CurrentUser_ID) {
            int unixtime = [[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] integerValue];
            NSLog(@"unixtime:%d",unixtime);
            fileName = [NSString stringWithFormat:@"%@_%d_%d.png",houseIdStr,currentID,unixtime];
            
            // fileName = [NSString stringWithFormat:@"%@_%d.png",houseIdStr,currentID];
            storePath = [housePath stringByAppendingPathComponent:fileName];
            [imgData writeToFile:storePath atomically:YES];
        }
        NSString* filePath = [storePath stringByAppendingPathComponent:fileName];
        imgData = [NSData dataWithContentsOfFile:filePath];
        
        
        //    [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (HouseID,ImagePath,ImageData,SyncStatus)VALUES ('%@','%@','%@','%@')",houseIdStr,storePath,imageByteAryresult,@"New"]];
        
        
        if ([houseIdStr isKindOfClass:[NSNull class]]) {
            houseIdStr =@"";
        }
        
        if ([fileName isKindOfClass:[NSNull class]]||(fileName.length==0)) {
            fileName =@"";
        }
        if ([storePath isKindOfClass:[NSNull class]]||(storePath.length==0)) {
            storePath =@"";
        }
        
        NSLog(@"StorePath:%@",storePath);
        
        //    if ([imageByteAryresult isKindOfClass:[NSNull class]]||(imageByteAryresult.length==0)) {
        //        imageByteAryresult =@"";
        //    }
        
        
        [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (HouseID,ImagePath,ImageData,FileName,ServerID,ServerPath,SyncStatus)VALUES ('%@','%@','%@','%@','%@','%@','%@')",houseIdStr,storePath,imageByteAryresult,fileName,@"",@"",@"New"]];
        
        
        NSMutableArray *syncStatusAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM House where ID='%@'",houseIdStr] resultsArray:syncStatusAry];
        NSLog(@"syncStatusAry %@", syncStatusAry);
        NSString *syncValue = [[syncStatusAry objectAtIndex:0] valueForKey:@"SyncStatus"];
        //    [self showSimple:nil];
        
        if ([syncValue isEqualToString:@"Sync"]) {
            if ([houseIdStr isKindOfClass:[NSNull class]]) {
                houseIdStr =@"";
            }
            
            
            [dbManager execute:[NSString stringWithFormat:@"Update House set syncStatus='Update' where ID = '%@'",houseIdStr]];
        }
        
        [self setupScrollView];
        [FAUtilities showAlert:@"Image Added"];
    }
    
    //    UIImage *reducedNewImage =[self imageWithImage:chosenImage scaledToSize:CGSizeMake(125,125)];
    //    NSData *reducedData  = UIImageJPEGRepresentation(reducedNewImage, 0);
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


-(void) setupScrollView {
    
    NSMutableArray *imagesAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    [dbManager execute:[NSString stringWithFormat:@"SELECT ID,ImagePath,ServerPath FROM Images where HouseID= '%@' and RoomID IS NULL and ItemID IS NULL AND (SyncStatus = 'Sync' or SyncStatus = 'New')",houseIdStr] resultsArray:imagesAry];
    
    UIImageView *noImage;
    if ([imagesAry count]== 0) {
        for (UIView *v in [scrollImgView subviews]) {
            [v removeFromSuperview];
        }
        noImage = [[UIImageView alloc] init];
        
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            noImage.frame=CGRectMake((1000-125)/2, 0,125,125);
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            noImage.frame=CGRectMake((scrollImgView.frame.size.width-125)/2, 0,125,125);
        }
        
        noImage.image = [UIImage imageNamed:@"no_image.jpg"];
        noImage.contentMode = UIViewContentModeScaleAspectFit;
        //        noImage.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"houseFrame.png"]] CGColor];
        //        noImage.layer.borderWidth = 10.0f;
        [scrollImgView addSubview:noImage];
    }else{
        for (UIView *v in [scrollImgView subviews]) {
            [v removeFromSuperview];
        }
        scrollImgView.pagingEnabled = YES;
        [scrollImgView setAlwaysBounceVertical:NO];
        //setup internal views
        NSInteger numberOfViews = [imagesAry count];
        for (int i = 0; i < numberOfViews; i++) {
            CGFloat xOrigin = i * 127;
            
            UIButton *imgBtn = [[UIButton alloc]initWithFrame:
                                CGRectMake(xOrigin, 0,
                                           125,
                                           125)];
            
            
            imgBtn.backgroundColor = [UIColor clearColor];
            
            //            imgBtn.layer.borderColor = [[UIColor blackColor] CGColor];
            //            imgBtn.layer.borderWidth = 1;
            
            NSMutableDictionary *tempDict = [imagesAry objectAtIndex:i];
            //            NSString *valStr = [tempDict valueForKey:@"ImageData"];
            NSString *currentImgId = [tempDict valueForKey:@"ID"];
            NSString *currentImgURL = [tempDict valueForKey:@"ServerPath"];
            NSString *imgLocalUrl = [tempDict valueForKey:@"ImagePath"];
            
            //            UIImage *img;
            
            if (imgLocalUrl.length !=0) {
                [imgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgLocalUrl] forState:UIControlStateNormal];
            }else{
                if (currentImgURL.length !=0) {
                    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgBtn.frame.size.width, imgBtn.frame.size.width)];
                    
                    [imgBtn addSubview:animatedImageView];
                    
                    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                                         [UIImage imageNamed:@"Loading_1.png"],
                                                         [UIImage imageNamed:@"Loading_2.png"],
                                                         [UIImage imageNamed:@"Loading_3.png"],
                                                         [UIImage imageNamed:@"Loading_4.png"],
                                                         [UIImage imageNamed:@"Loading_5.png"],
                                                         [UIImage imageNamed:@"Loading_6.png"],
                                                         [UIImage imageNamed:@"Loading_7.png"],
                                                         [UIImage imageNamed:@"Loading_8.png"],
                                                         [UIImage imageNamed:@"Loading_9.png"],
                                                         [UIImage imageNamed:@"Loading_10.png"],
                                                         [UIImage imageNamed:@"Loading_11.png"],nil];
                    animatedImageView.animationDuration = 1.0f;
                    animatedImageView.animationRepeatCount = 0;
                    [animatedImageView startAnimating];
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        // the slow stuff to be done in the background
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSFileManager* fileManager = [NSFileManager defaultManager];
                        NSError* error = nil;
                        
                        NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
                        NSString *dataPath;
                        
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
                        dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
                        if (CurrentUser_ID) {
                            
                            if (![fileManager fileExistsAtPath:dataPath]){
                                [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
                            }else {
                            }
                            dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
                        }
                        NSString *localHousePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseIdStr]];
                        
                        
                        if (![fileManager fileExistsAtPath:localHousePath]){
                            [fileManager createDirectoryAtPath:localHousePath withIntermediateDirectories:NO attributes:nil error:&error];
                        }else {
                        }
                        
                        NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
                        NSString *imageFilePath;
                        if (CurrentUser_ID) {
                            
                            imageFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
                            if (![fileManager fileExistsAtPath:imageFilePath]){
                                [fileManager createDirectoryAtPath:imageFilePath withIntermediateDirectories:NO attributes:nil error:&error];
                            }else {
                            }
                            imageFilePath = [imageFilePath stringByAppendingPathComponent:@"Image"];
                        }
                        NSString *tempHousePath = [imageFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseIdStr]];
                        
                        NSString *fileName;
                        NSString *storePath;
                        if (CurrentUser_ID) {
                            fileName = [NSString stringWithFormat:@"/%@_%@.png",houseIdStr,currentImgId];
                            storePath = [tempHousePath stringByAppendingString:fileName];
                            
                            NSString* webStringURL = [currentImgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                            // for handling memory pressure handle images having more than 1000 width, with aspect ratio of height
                            
                            UIImage *tempImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]]];
                            CGFloat width = tempImg.size.width;
                            CGFloat height = tempImg.size.height;
                            
                            float bytes =[[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]] length];
                            float kb = bytes/1024;
                            
                            NSLog(@"Size of Image(bytes):%f",bytes);
                            NSLog(@"Size of Image(kb):%f",kb);
                            NSLog(@"Image Url %@",webStringURL);
                            NSLog(@"Width:%f, Height:%f",width,height);
                            

                            if (width >800) {
                                float scaleFactor = 800 / width;
                                float newHeight = height * scaleFactor;
                                float newWidth = width * scaleFactor;
                                UIImage *reducedNewImage =[self imageWithImage:tempImg scaledToSize:CGSizeMake(newWidth,newHeight)];
                                NSData *reducedImageData = UIImageJPEGRepresentation(reducedNewImage, 0.8);;
                                [reducedImageData writeToFile:storePath atomically:YES];
                                NSLog(@"reduced length %lu",(unsigned long)[reducedImageData length]);
                            }else{
                                [[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]] writeToFile:storePath atomically:YES];
                            }

                            
                            [[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]] writeToFile:storePath atomically:YES];

//                            [[NSData dataWithContentsOfURL:[NSURL URLWithString:currentImgURL]] writeToFile:storePath atomically:YES];
                        }
                        
                        NSFileManager *filemanager=[NSFileManager defaultManager];
                        BOOL fileExists = [filemanager fileExistsAtPath:storePath];
                        
                        
                        [animatedImageView removeFromSuperview];
                        [imgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:storePath] forState:UIControlStateNormal];
                        dbManager= [DataBaseManager dataBaseManager];
                        if ([storePath isKindOfClass:[NSNull class]]||(storePath.length==0)) {
                            storePath =@"";
                        }
                        //                        if ([currentImgId isKindOfClass:[NSNull class]]||(currentImgId==0)) {
                        //                            currentImgId =@"";
                        //                          }
                        
                        if (fileExists == YES) {
                            [dbManager execute:[NSString stringWithFormat:@"Update Images set ImagePath='%@' where ID = '%@'",storePath,currentImgId]];
                            sleep(0.1);
                        }else{
                            [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ID = '%@'",currentImgId]];
                            sleep(0.1);
                            [self setupScrollView];
                            //                            [dbManager execute:[NSString stringWithFormat:@"Update Images set ImagePath='%@' where ID = '%@'",storePath,currentImgId]];
                        }
                    });
                }
            }
            
            UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
            [gestureRecognizer addTarget:self action:@selector(imgLongPressed:)];
            [imgBtn addGestureRecognizer: gestureRecognizer];
            
            [imgBtn addTarget:self action:@selector(showHouseImage:) forControlEvents:UIControlEventTouchUpInside];
            //            imgBtn.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"houseFrame.png"]] CGColor];
            //            imgBtn.layer.borderWidth = 10.0f;
            imgBtn.layer.borderColor = [[UIColor grayColor] CGColor];
            imgBtn.layer.borderWidth = 1.0f;
            imgBtn.tag = [currentImgId integerValue];
            [scrollImgView addSubview:imgBtn];
        }
        //set the scroll view content size
        scrollImgView.backgroundColor = [UIColor clearColor];
        scrollImgView.contentSize = CGSizeMake(125 *
                                               numberOfViews,
                                               scrollImgView.frame.size.height);
    }
    
    scrollImgView.layer.borderColor = [UIColor blackColor].CGColor;
    scrollImgView.layer.borderWidth = 1.0f;
    scrollImgView.layer.cornerRadius=2.0f;
    [scrollImgBgView addSubview:scrollImgView];
    
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

-(int)lastInsertedRoomRowID{
    
    NSMutableArray *idAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * from SQLITE_SEQUENCE;"] resultsArray:idAry];
    NSLog(@"ID Ary %@", idAry);
    
    NSString *seqVal;
    for (int i=0; i<[idAry count]; i++) {
        NSDictionary *tempDict = [idAry objectAtIndex:i];
        if ([[tempDict valueForKey:@"name"] isEqualToString:@"Room"]) {
            seqVal = [[idAry objectAtIndex:i] valueForKey:@"seq"];
        }
    }
    int rowID = [seqVal intValue];
    return rowID;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    // Here pass new size you need
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



- (void) itemNameLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer
{
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    NSLog(@"itemNameLongPressed");
    
    if (isEditItemPopOverPresent == NO) {
        UILabel *itemNameLabel = (UILabel *)[gestureRecognizer view];
        
        NSLog(@"itemNameLongPressed NO");
        
        int currentEditingitemID = itemNameLabel.tag ;
        
        NSMutableArray *itemNameAry = [[NSMutableArray alloc]init];
        dbManager = [DataBaseManager dataBaseManager];
        [dbManager execute:[NSString stringWithFormat:@"SELECT Name FROM Item Where ID = '%d'",currentEditingitemID] resultsArray:itemNameAry];
        NSString* itemName = [[itemNameAry objectAtIndex:0]valueForKey:@"Name"];
        
        
        UIViewController* popoverContent = [[UIViewController alloc]init];
        UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 140)];
        itemNameEditTextView = [[UITextView alloc]initWithFrame:CGRectMake(25, 10, 200, 80)];
        //        itemNameEditTextView.backgroundColor = [UIColor grayColor];
        itemNameEditTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        itemNameEditTextView.layer.borderWidth = 1;
        itemNameEditTextView.text = itemName;
        itemNameEditTextView.autocapitalizationType =UITextAutocapitalizationTypeWords;
        itemNameEditTextView.delegate =self;
        [popoverView addSubview:itemNameEditTextView];
        
        
        UIButton *itemNameSaveBtn = [[UIButton alloc]initWithFrame:CGRectMake(75, 100, 100, 20)];
        [itemNameSaveBtn setTitle:@"Save" forState:UIControlStateNormal];
        [itemNameSaveBtn setTitleColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        
        [itemNameSaveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [itemNameSaveBtn addTarget:self action:@selector(saveItemNameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        itemNameSaveBtn.tag =currentEditingitemID;
        
        [popoverView addSubview:itemNameSaveBtn];
        
        popoverContent.view = popoverView;
        popoverContent.preferredContentSize = CGSizeMake(250, 140);
        
        
        self.itemNameEditPopOver = [[UIPopoverController alloc]
                                    initWithContentViewController:popoverContent];
        self.itemNameEditPopOver.delegate = self;
        //present the popover view non-modal with a
        //refrence to the toolbar button which was pressed
        if ([self.itemNameEditPopOver isPopoverVisible]) {
            [self.itemNameEditPopOver dismissPopoverAnimated:YES];
        }
        [self.itemNameEditPopOver  presentPopoverFromRect:CGRectMake(0, 0, 133, 29)
                                                   inView:itemNameLabel permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        
        isEditItemPopOverPresent = YES;
    }else{
        NSLog(@"itemNameLongPressed YES");
    }
    
}


- (void) saveItemNameBtnClicked:(id)sender{
    
    UIButton *saveBtn = (UIButton *)sender;
    
    if (itemNameEditTextView.text.length >0) {
        NSLog(@"save item btn clicked");
        NSLog(@"itemNameTextView %@",itemNameEditTextView);
        
        NSString *updatedSyncStatus;
        NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
        dbManager = [DataBaseManager dataBaseManager];
        [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Item where ID='%ld'",(long)saveBtn.tag] resultsArray:syncDetails];
        NSLog(@"syncDetails %@", syncDetails);
        
        NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
        
        if ([syncValue isEqualToString:@"Sync"] || [syncValue isEqualToString:@"Update"]) {
            updatedSyncStatus = @"Update";
        }else{
            updatedSyncStatus = @"New";
        }
        
        if ([itemNameEditTextView.text isKindOfClass:[NSNull class]]||(itemNameEditTextView.text.length==0)) {
            itemNameEditTextView.text =@"";
        }
        if ([updatedSyncStatus isKindOfClass:[NSNull class]]||(updatedSyncStatus.length==0)) {
            updatedSyncStatus =@"";
        }
        //        if ([saveBtn.tag isKindOfClass:[NSNull class]]||(saveBtn.tag.length==0)) {
        //            saveBtn.tag =@"";
        //        }
        
        NSString *tempItemNameStr =[itemNameEditTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        //        itemNameEditTextView.text = [itemNameEditTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        [dbManager execute:[NSString stringWithFormat:@"Update Item set Name='%@', SyncStatus='%@' where ID = '%ld'",tempItemNameStr,updatedSyncStatus, (long)saveBtn.tag]];
        [self drawAttchmentsView];
        isEditItemPopOverPresent = NO;
        [self.itemNameEditPopOver dismissPopoverAnimated:YES];
    }else{
        [FAUtilities showAlert:@"Please enter item name"];
    }
}
- (void) itemLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer
{
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    [deleteHouseImgBtn removeFromSuperview];
    
    [addHouseSubView removeFromSuperview];
    [addRoomSubView removeFromSuperview];
    
    
    UIButton *button = (UIButton *)[gestureRecognizer view];
    UIImage *buttonImage = [UIImage imageNamed:@"deleteButton.png"];
    deleteItemBtn.tag = button.tag;
    [deleteItemBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [deleteItemBtn addTarget:self action:@selector(deleteItemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage *buttonImage1 = [UIImage imageNamed:@"Email.png"];
    emailItemBtn.tag = button.tag;
    [emailItemBtn setBackgroundImage:buttonImage1 forState:UIControlStateNormal];
    [emailItemBtn addTarget:self action:@selector(emailItemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage *buttonPdfImage = [UIImage imageNamed:@"pdf.png"];
    viewPdfItemButton.tag = button.tag;
    [viewPdfItemButton setBackgroundImage:buttonPdfImage forState:UIControlStateNormal];
    [viewPdfItemButton addTarget:self action:@selector(viewPdfBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [button addSubview:viewPdfItemButton];
    [button addSubview:emailItemBtn];
    [button addSubview:deleteItemBtn];
}

-(IBAction)viewPdfBtnClicked:(id)sender{
    NSLog(@"subviews %@", [self.view subviews]);
    isItemPdfClicked = NO;
    
    UIButton *pdfButton = (UIButton *)sender;
    NSLog(@"pdfButton Tag:%ld",(long)pdfButton.tag);
    viewPdfBtnTag = pdfButton.tag;
    NSLog(@"House id %@", houseIdStr);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    tapTimer = nil;
    [tapTimer invalidate];
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(callAfterSixtySecond:) userInfo:nil repeats:YES];
    
    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *dataPath;
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
    dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:dataPath]){
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
    }
    NSString *localHousePdfPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseIdStr]];
    
    if (![fileManager fileExistsAtPath:localHousePdfPath]){
        [fileManager createDirectoryAtPath:localHousePdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *roomIdAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT RoomID,Name FROM Item Where ID = '%ld'",(long)pdfButton.tag] resultsArray:roomIdAry];
    NSString  *roomId = [[roomIdAry objectAtIndex:0]valueForKey:@"RoomID"];
    NSString  *itemName = [[roomIdAry objectAtIndex:0]valueForKey:@"Name"];
    NSString *localRoomPdfPath = [localHousePdfPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",roomId]];
    
    if (![fileManager fileExistsAtPath:localRoomPdfPath]){
        [fileManager createDirectoryAtPath:localRoomPdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else{
    }
    
    NSString *localItemPdfPath = [localRoomPdfPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)pdfButton.tag]];
    
    if (![fileManager fileExistsAtPath:localItemPdfPath]){
        [fileManager createDirectoryAtPath:localItemPdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *pdfFilePath;
    
    
    pdfFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
    
    if (CurrentUser_ID) {
        if (![fileManager fileExistsAtPath:pdfFilePath]){
            [fileManager createDirectoryAtPath:pdfFilePath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        
        pdfFilePath = [pdfFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Image"]];
        
    }
    
    NSString *tempHousePath = [pdfFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseIdStr]];
    NSString *tempRoomPath = [tempHousePath stringByAppendingString:[NSString stringWithFormat:@"/%@",roomId]];
    NSString *tempItemPath = [tempRoomPath stringByAppendingString:[NSString stringWithFormat:@"/%ld",(long)pdfButton.tag]];
    
    NSString *fileName = [NSString stringWithFormat:@"/%@_%@_%ld_%ld.pdf",houseIdStr,roomId,(long)pdfButton.tag,(long)pdfButton.tag];
    NSString *storePath = [tempItemPath stringByAppendingString:fileName];
    
    NSFileManager *filemanager=[NSFileManager defaultManager];
    
    BOOL fileExists = [filemanager fileExistsAtPath:storePath];
    
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:storePath])
    {
        //file not exits in Document Directories
    }
    else
    {
        //file exist in Document Directories
    }
    
    if (fileExists == NO) {
        dbManager = [DataBaseManager dataBaseManager];
//        NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
        
        //        NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USERID"];
        NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
        
        //        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails where ID=%@",CurrentUser_ID] resultsArray:loginDetails];
        
        //        NSDictionary *currentUser = [loginDetails objectAtIndex:0];
        //        NSString *userID = [currentUser valueForKey:@"UserID"];
        NSLog(@"user_Server_ID %@", user_Server_ID);
        
//        NSString *User_Type = [currentUser valueForKey:@"User_Type"];
//        NSLog(@"Container ViewController User_Type %@", User_Type);
        
//        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *tempHouseAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT ServerID FROM House Where ID = '%@' and UserID = '%@'",houseIdStr,user_Server_ID] resultsArray:tempHouseAry];
        
        NSLog(@"tempHouseAry %@",tempHouseAry);
        NSString *tempHouseServerID;
        for (int i = 0; i<[tempHouseAry count]; i++) {
            tempHouseServerID = [[tempHouseAry valueForKey:@"ServerID"] objectAtIndex:0];
        }
        
        NSString *itemServerId =@"";
        NSString *roomServerId = @"";
        NSString *tempItemId=@"";
        NSString *tempRoomId=@"";
        
        for (int i=0; i<[houseDetailsAry count]; i++) {
            NSDictionary *houseDict = [houseDetailsAry objectAtIndex:i];
            //            itemServerId = [ houseDict valueForKey:@"ItemServerId"];
            tempItemId = [houseDict valueForKey:@"ItemId"];
            tempRoomId = [houseDict valueForKey:@"RoomId"];
            
            if ([[NSString stringWithFormat:@"%ld",(long)pdfButton.tag] isEqualToString:tempItemId] &&[roomId isEqualToString:tempRoomId] ) {
                itemServerId = [ houseDict valueForKey:@"ItemServerId"];
                roomServerId = [ houseDict valueForKey:@"RoomServerId"];
                break;
            }
        }
        
        NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Item where ID='%@'",tempItemId] resultsArray:syncDetails];
        NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
        
        //        if (itemServerId.length ==0) {
        if ([syncValue isEqualToString:@"Update"] || [syncValue isEqualToString:@"New"]) {
            [self houseSyncButtonClick:nil];
            isItemPdfClicked = YES;
            itemPdfClickedBtn =pdfButton;
        }else{
            
            
            
            //            if ([syncValue isEqualToString:@"Update"]) {
            //                [self houseSyncButtonClick:nil];
            //                isItemPdfClicked = YES;
            //                itemPdfClickedBtn =pdfButton;
            //
            //            }else{
            NSLog(@"temp H_ServerID =%@",tempHouseServerID);
            NSLog(@"temp R_ServerID =%@",roomServerId);
            NSLog(@"temp I_ServerID =%@",itemServerId);
            
            
            NSString *formattedStr = [NSString stringWithFormat:@"{\"ID\":\"%ld\",\"ServerID\":\"%@\",\"RoomID\":\"%@\",\"HouseID\":\"%@\"}",(long)pdfButton.tag,itemServerId,roomServerId,tempHouseServerID];
            NSString *aryKey =@"Itempdf";
            
            NSString *reqTypeStr = [NSString stringWithFormat:@"\"Type\":\"%@\"",ITEMPDF_TYPE];
            NSString *userIDStr = [NSString stringWithFormat:@"\"UserID\":\"%@\"",user_Server_ID];
            NSString *tempTableStr = [NSString stringWithFormat:@"\"%@\":%@",aryKey,formattedStr];
            
//            NSLog(@"tempTableStr %@", tempTableStr);
            
            NSString *postString = [NSString stringWithFormat:@"{%@,%@,%@}",reqTypeStr,userIDStr,tempTableStr];
            
//            NSLog(@"postString %@", postString);
            NSData *postJsonData = [postString dataUsingEncoding:NSUTF8StringEncoding];
            
            webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
            webServiceInterface.delegate =self;
            [webServiceInterface sendRequest:postString PostJsonData:postJsonData Req_Type:ITEMPDF_TYPE Req_url:ITEMPDF_REQUEST_URL];
            
            //            }
            
            
        }
    }else{
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            pdfWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,10,1024,768)];
            
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            pdfWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,10,768,1024)];
        }
        //        pdfWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
        
        [pdfWebView setScalesPageToFit:YES];
        pdfWebView.contentMode = UIViewContentModeScaleToFill;
        NSURL *filePathURL = [NSURL fileURLWithPath:storePath];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:filePathURL];
        [pdfWebView setUserInteractionEnabled:YES];
        [pdfWebView setDelegate:self];
        pdfWebView.scalesPageToFit = YES;
        [[pdfWebView.subviews objectAtIndex:0] setBounces:NO]; //to stop bouncing
        [pdfWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",(int)self.view.frame.size.width]];
        
        pdfWebView.scalesPageToFit = YES;
        pdfWebView.multipleTouchEnabled = YES;
        pdfWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [pdfWebView loadRequest:requestObj];
        //        [pdfWebView addSubview:cancelButton];
        
        pdfcontroller = [[UIViewController alloc] init];
        pdfcontroller.view = pdfWebView;
        //        [pdfcontroller.view addSubview:pdfWebView];
        
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelBtn:)];
        
        UIBarButtonItem *rightBarbuttonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBtn:)];
        
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pdfcontroller];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        pdfcontroller.navigationItem.leftBarButtonItem = leftBarButton;
        pdfcontroller.navigationItem.rightBarButtonItem = rightBarbuttonItem;
        pdfcontroller.navigationItem.title = itemName;
        
        [self presentViewController:navigationController animated:YES completion:NULL];
        
        
        //        UINavigationBar *yourBar = [[UINavigationBar alloc] init];
        //        [pdfcontroller.view addSubview:yourBar];
        //        [self presentViewController:pdfcontroller animated:YES completion:nil];
        
        //        [self.view addSubview:pdfWebView];
    }
    
    NSLog(@"subviews %@", [self.view subviews]);
    
}
-(void)cancelPdf:(id)Sender{
    tapTimer = nil;

    [tapTimer invalidate];
    [pdfcontroller dismissViewControllerAnimated:YES completion:nil];
    
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    //    [pdfWebView removeFromSuperview];
}
-(void)emailItemBtnClicked:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    dbManager = [DataBaseManager dataBaseManager];
    
    NSMutableArray *roomIdAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT RoomID,Name FROM Item Where ID = '%ld'",(long)button.tag] resultsArray:roomIdAry];
    NSString  *roomId = [[roomIdAry objectAtIndex:0]valueForKey:@"RoomID"];
    NSString  *itemName = [[roomIdAry objectAtIndex:0]valueForKey:@"Name"];
    
    
    NSMutableArray *roomNameAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat: @"Select Name From Room Where ID = '%@'",roomId] resultsArray:roomNameAry];
    NSLog(@"roomNameAry %@",roomNameAry);
    NSString *roomName = [[roomNameAry objectAtIndex:0]valueForKey:@"Name"];
    
    
    NSMutableArray *houseNameAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat: @"Select Name From House Where ID = '%@'",houseIdStr] resultsArray:houseNameAry];
    NSLog(@"houseNameAry %@",houseNameAry);
    NSString *houseName = [[houseNameAry objectAtIndex:0]valueForKey:@"Name"];
    
    
    NSString *tempFilename = [NSString stringWithFormat:@"/%@_%@.pdf",roomName,itemName];
    
    
    NSLog(@"Emial Test");
    
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    //    [mailComposer setSubject:@"Test mail"];
    
    [mailComposer setSubject:[NSString stringWithFormat:@"Information on %@ in %@ of your %@",itemName,roomName,houseName]];
    
    
    
    
    //    [mailComposer setMessageBody:@"Testing message for the test mail" isHTML:NO];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); // For Saving in libarary
    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *dataPath;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
    dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:dataPath]){
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
    }
    NSString *localHousePdfPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseIdStr]];
    
    
    
    if (![fileManager fileExistsAtPath:localHousePdfPath]){
        [fileManager createDirectoryAtPath:localHousePdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    
    
    
    
    NSString *localRoomPdfPath = [localHousePdfPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",roomId]];
    
    if (![fileManager fileExistsAtPath:localRoomPdfPath]){
        [fileManager createDirectoryAtPath:localRoomPdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *localItemPdfPath = [localRoomPdfPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)button.tag]];
    
    if (![fileManager fileExistsAtPath:localItemPdfPath]){
        [fileManager createDirectoryAtPath:localItemPdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *pdfFilePath;
    
    pdfFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:pdfFilePath]){
            [fileManager createDirectoryAtPath:pdfFilePath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        pdfFilePath = [pdfFilePath stringByAppendingPathComponent:@"Image"];
    }
    NSString *tempHousePath = [pdfFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseIdStr]];
    NSString *tempRoomPath = [tempHousePath stringByAppendingString:[NSString stringWithFormat:@"/%@",roomId]];
    NSString *tempItemPath = [tempRoomPath stringByAppendingString:[NSString stringWithFormat:@"/%ld",(long)button.tag]];
    
    NSString *fileName = [NSString stringWithFormat:@"/%@_%@_%ld_%ld.pdf",houseIdStr,roomId,(long)button.tag,(long)button.tag];
    NSString *storePath = [tempItemPath stringByAppendingString:fileName];
    
    NSFileManager *tempFilemanager=[NSFileManager defaultManager];
    
    BOOL pdfFileExists = [tempFilemanager fileExistsAtPath:storePath];
    
    if (pdfFileExists == NO) {
        isEmailPdfClicked = YES;
        [self viewPdfBtnClicked:button];
        emailPdfClickedBtn = button;
    }else{
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:storePath] mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@.pdf",tempFilename]];
        if (mailComposer == nil) {
            [FAUtilities showAlert:@"Please setup your email account"];
        }else{
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        
    }
    
    //    [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"]] writeToFile:storePath atomically:YES];
    
    
    
    
    //    [self presentModalViewController:mailComposer animated:YES];
    
    
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        NSLog(@"Result : %d",result);
        if (result == MFMailComposeResultSent) {
            [FAUtilities showAlert:@"Mail Sent Succesufully"];
            tapTimer = nil;

            [tapTimer invalidate];
        }
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    //    [self dismissModalViewControllerAnimated:YES];
    //    [self dismissModalViewControllerAnimated:NO completion:NULL];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
}
-(void)deleteItemBtnClicked:(id)sender{
    UIButton *longPressRoomBtn = (UIButton *)sender;
    
    deletedItemID = longPressRoomBtn.tag;
    deletedItemServerID = [self getServerIDTable:@"Item" ForID:[NSString stringWithFormat:@"%d",deletedItemID]];
    
    NSString *alertMsg = [NSString stringWithFormat:@"Are you sure your want to delete this Item?"];
    deleteItemAlertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                     message:alertMsg
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    [deleteItemAlertView show];
}
-(NSString *)getServerIDTable:(NSString *)table ForID:(NSString *)localID{
    
    NSLog(@"tableName %@, localRoomID %@",table,localID);
    NSMutableArray *serverIDAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
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
- (void) showHouseImage:(id)sender{
    
    //    [self showSimple:nil];
    UIButton *button = (UIButton *)sender;
    NSString *btnID = [NSString stringWithFormat:@"%ld",(long)button.tag];
    [deleteHouseImgBtn removeFromSuperview];
    
    
    NSLog(@"btnID %@", btnID);
    
    UIViewController* popoverContent = [[UIViewController alloc]init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    houseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath;
    NSError *err;
    
    NSLog(@"err %@", err);
    
    NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
    imageFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:imageFilePath]){
            [fileManager createDirectoryAtPath:imageFilePath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        imageFilePath = [imageFilePath stringByAppendingPathComponent:@"Image"];
        
    }
    NSMutableArray *imgSeverPathAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    [dbManager execute:[NSString stringWithFormat: @"Select ServerPath,ImagePath From Images Where ID = '%@'",btnID] resultsArray:imgSeverPathAry];  NSLog(@"imgSeverPathAry %@",imgSeverPathAry);
    NSLog(@"imgSeverPathAry objectAtIndex:0] %@",[imgSeverPathAry objectAtIndex:0]);
    NSLog(@"imgSeverPathAry ServerPath %@",[[imgSeverPathAry objectAtIndex:0]valueForKey:@"ServerPath"]);
    
    NSString *imgLocalPathVal = [[imgSeverPathAry objectAtIndex:0]valueForKey:@"ImagePath"];
    
    if (imgLocalPathVal.length !=0) {
        houseImageView.image = [UIImage imageWithContentsOfFile:imgLocalPathVal];
        
    }
    
    houseImageView.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"frame.png"]] CGColor];
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] init];
    [swipeLeft addTarget:houseImageView action:@selector(handleSwipe:)];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] init];
    [swipeRight addTarget:houseImageView action:@selector(handleSwipe:)];
    
    
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [houseImageView addGestureRecognizer:swipeLeft];
    [houseImageView addGestureRecognizer:swipeRight];
    
    
    
    
    [popoverView addSubview:houseImageView];
    popoverContent.view = popoverView;
    
    popoverContent.preferredContentSize = CGSizeMake(600, 600);
    
    self.houseImagePopOver = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    self.houseImagePopOver.delegate =self;
    
    if ([self.houseImagePopOver isPopoverVisible]) {
        [self.houseImagePopOver dismissPopoverAnimated:YES];
    }
    [self.houseImagePopOver  presentPopoverFromRect:CGRectMake(0, 0, 133, 29)
                                             inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //    loading.hidden = YES;
    
    
}
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
    }
    
}
- (void) imgLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer
{
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    
    [addHouseSubView removeFromSuperview];
    [addRoomSubView removeFromSuperview];
    
    
    UIButton *button = (UIButton *)[gestureRecognizer view];
    
    UIImage *buttonImage = [UIImage imageNamed:@"deleteButton.png"];
    deleteHouseImgBtn.tag = button.tag;
    [deleteHouseImgBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [deleteHouseImgBtn addTarget:self action:@selector(deleteHouseImgBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:deleteHouseImgBtn];
}
-(void)deleteHouseImgBtnClicked:(id)sender{
    UIButton *longPressRoomBtn = (UIButton *)sender;
    deletedHouseImgID = longPressRoomBtn.tag;
    
    deletedHouseImgServerID = [self getServerIDTable:@"Images" ForID:[NSString stringWithFormat:@"%d",deletedHouseImgID]];
    
    
    NSString *alertMsg = [NSString stringWithFormat:@"Are you sure your want to delete this Image?"];
    deleteHouseImgAlertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                         message:alertMsg
                               
                                                        delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles:@"Yes", nil];
    [deleteHouseImgAlertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [deleteHouseImgBtn removeFromSuperview];
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    dbManager = [DataBaseManager dataBaseManager];
    
    if (buttonIndex == 1){
        if (alertView == deleteHouseImgAlertView) {
            
            if ([deletedHouseImgServerID isEqualToString:@""]) {
                [dbManager execute:[NSString stringWithFormat:@"DELETE FROM Images where ID = '%d'",deletedHouseImgID]];
            }else{
                
                if (deletedHouseImgServerID.length ==0) {
                    [dbManager execute:[NSString stringWithFormat:@"DELETE FROM Images where ID = '%d'",deletedHouseImgID]];
                }else{
                    
                    if ([houseIdStr isKindOfClass:[NSNull class]]) {
                        houseIdStr =@"";
                    }
                    //                    if ([deletedHouseImgID isKindOfClass:[NSNull class]]||(deletedHouseImgID.length==0)) {
                    //                        deletedHouseImgID =@"";
                    //                    }
                    
                    [dbManager execute:[NSString stringWithFormat:@"Update House set SyncStatus='Update' where ID = '%@'",houseIdStr]];
                    [dbManager execute:[NSString stringWithFormat:@"Update Images set SyncStatus='Delete' where ID = '%d'",deletedHouseImgID]];
                }
            }
            
            NSMutableArray *imgPathAry = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT ImagePath FROM Images Where ID = '%d' ",deletedHouseImgID] resultsArray:imgPathAry];
            NSLog(@"imgPathAry %@", imgPathAry);
            
            NSString *imgPath;
            if ([imgPathAry count] !=0) {
                NSDictionary *tempDict = [imgPathAry objectAtIndex:0];
                imgPath = [tempDict valueForKey:@"ImagePath"];
                NSLog(@"imgPathAry %@", imgPath);
                if (imgPath.length !=0) {
                    [self removeImage:imgPath];
                }
            }
            
            //            [dbManager execute:imgQuery];
            [self setupScrollView];
        }else if(alertView == deleteItemAlertView){
            
            NSLog(@"delete item");
            NSLog(@"deleted item ID %d", deletedItemID);
            NSLog(@"deleted item server ID %@", deletedItemServerID);
            
            if (deletedItemServerID.length == 0) {
                NSString *itemQuery = [NSString stringWithFormat:@"DELETE FROM Item WHERE ID = %d", deletedItemID];
                [dbManager execute:itemQuery];
                
                NSString *imgQuery = [NSString stringWithFormat:@"DELETE FROM Images WHERE ItemID = %d", deletedItemID];
                [dbManager execute:imgQuery];
                
                [containerScrollView setContentOffset:CGPointMake(0,0) animated:YES];
                [self drawAttchmentsView];
            }else{
                [self postRequest:DELETE_ITEM];
            }
            
            
        }else if (alertView == deleteRoomAlertView){
            
            NSLog(@"delete room");
            NSLog(@"deleted Room ID %@", deleteRoomID);
            NSLog(@"deleted Room server ID %@", deleteRoomServerID);
            
            if (deleteRoomServerID.length == 0) {
                NSString *query = [NSString stringWithFormat:@"DELETE FROM Room WHERE ID = %@", deleteRoomID];
                [dbManager execute:query];
                
                NSString *itemQuery = [NSString stringWithFormat:@"DELETE FROM Item WHERE RoomID = %@", deleteRoomID];
                [dbManager execute:itemQuery];
                
                NSString *imgQuery = [NSString stringWithFormat:@"DELETE FROM Images WHERE RoomID = %@", deleteRoomID];
                [dbManager execute:imgQuery];
                [containerScrollView setContentOffset:CGPointMake(0,0) animated:NO];
                
                [self drawAttchmentsView];
            }else{
                [self postRequest:DELETE_ROOM];
            }
            
            
        }else if (alertView == deleteHouseAlertView){
            
            NSLog(@"delete house");
            NSLog(@"deleted House ID %@", deleteHouseID);
            NSLog(@"deleted House server ID %@", deleteHouseServerID);
            if (deleteHouseServerID.length ==0) {
                NSString *query = [NSString stringWithFormat:@"DELETE FROM House WHERE ID = %@", deleteHouseID];
                NSString *query1 = [NSString stringWithFormat:@"DELETE FROM Room WHERE HouseID = %@", deleteHouseID];
                NSString *query2 = [NSString stringWithFormat:@"DELETE FROM Item WHERE HouseID = %@", deleteHouseID];
                NSString *query3 = [NSString stringWithFormat:@"DELETE FROM Image WHERE HouseID = %@", deleteHouseID];
                [dbManager execute:query];
                [dbManager execute:query1];
                [dbManager execute:query2];
                [dbManager execute:query3];
               
                
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];

                NSMutableArray *housesAry = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus !='Delete' and UserID='%@'",user_Server_ID] resultsArray:housesAry];
                
            
                
                
                if ([housesAry count] >0) {
                    NSDictionary *tempDic = [housesAry objectAtIndex:0];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"House" forKey:@"Type"];
                    [defaults setObject:[tempDic objectForKey:@"Name"] forKey:@"Name"];
                    [defaults setObject:[tempDic objectForKey:@"ID"] forKey:@"ID"];
                }
                
                [self viewDidLoad];
                [self viewWillAppear:YES];
            }else{
                [self postRequest:DELETE_HOUSE];
            }
            
        }
    }else{
        [deleteHouseImgBtn removeFromSuperview];
    }
}
-(void)postRequest:(NSString *)reqType{
    //
    //    NSString *formattedBodyStr = [self jsonFormat:DELETE_HOUSE withDictionary:nil];
    //    NSData *postJsonData = [formattedBodyStr dataUsingEncoding:NSUTF8StringEncoding];
    //    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
    //    webServiceInterface.delegate =self;
    //    [webServiceInterface sendRequest:formattedBodyStr PostJsonData:postJsonData Req_Type:reqType Req_url:LOGIN_REQUEST_URL];
    dbManager = [DataBaseManager dataBaseManager];
    
    if ([reqType isEqualToString:DELETE_HOUSE]) {
        if ([deleteHouseServerID isKindOfClass:[NSNull class]]) {
            deleteHouseServerID =@"";
        }
        //        if ([houseLocalServerID isKindOfClass:[NSNull class]]||(houseLocalServerID.length==0)) {
        //            houseLocalServerID =@"";
        //        }
        
        
        [dbManager execute:[NSString stringWithFormat:@"Update House set syncStatus='Delete' where ServerID = '%@'",deleteHouseServerID]];
        NSString *houseLocalServerID = [self getLocalIDTable:@"House" ForID:deleteHouseServerID];
        [dbManager execute:[NSString stringWithFormat:@"Update Room set syncStatus='Delete' where HouseID = '%@'",houseLocalServerID]];
        [dbManager execute:[NSString stringWithFormat:@"Update Item set syncStatus='Delete' where HouseID = '%@'",houseLocalServerID]];
        [dbManager execute:[NSString stringWithFormat:@"Update Images set syncStatus='Delete' where HouseID = '%@'",houseLocalServerID]];
        
        
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
        
        NSMutableArray *housesAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus !='Delete' and UserID='%@'",user_Server_ID] resultsArray:housesAry];

        
//        NSMutableArray *housesAry = [[NSMutableArray alloc]init];
//        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus !='Delete'"] resultsArray:housesAry];
        
        if ([housesAry count] >0) {
            NSDictionary *tempDic = [housesAry objectAtIndex:0];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"House" forKey:@"Type"];
            [defaults setObject:[tempDic objectForKey:@"Name"] forKey:@"Name"];
            [defaults setObject:[tempDic objectForKey:@"ID"] forKey:@"ID"];
        }
        [self viewDidLoad];
        [self viewWillAppear:YES];
        
    }else if ([reqType isEqualToString:DELETE_ROOM]){
        NSString *roomLocalID = [self getLocalIDTable:@"Room" ForID:deleteRoomServerID];
        
        
        if ([deleteRoomServerID isKindOfClass:[NSNull class]]) {
            deleteRoomServerID =@"";
        }
        if ([roomLocalID isKindOfClass:[NSNull class]]) {
            roomLocalID =@"";
        }
        
        
        [dbManager execute:[NSString stringWithFormat:@"Update Room set syncStatus='Delete' where ServerID = '%@'",deleteRoomServerID]];
        [dbManager execute:[NSString stringWithFormat:@"Update Item set syncStatus='Delete' where RoomID = '%@'",roomLocalID]];
        
        [containerScrollView setContentOffset:CGPointMake(0,0) animated:NO];
        [self viewDidLoad];
        [self drawAttchmentsView];
        
    }else if ([reqType isEqualToString:DELETE_ITEM]){
        if ([deleteRoomServerID isKindOfClass:[NSNull class]]) {
            deleteRoomServerID =@"";
        }
        
        NSString *localItemID = [self getLocalIDTable:@"Item" ForID:deletedItemServerID];
        
        [dbManager execute:[NSString stringWithFormat:@"Update Item set syncStatus='Delete' where ServerID = '%@'",deletedItemServerID]];
        [dbManager execute:[NSString stringWithFormat:@"Update Images set syncStatus='Delete' where ItemID = '%@'",localItemID]];
        
        
        [containerScrollView setContentOffset:CGPointMake(0,0) animated:NO];
        
        [self viewDidLoad];
        [self drawAttchmentsView];
        
    }
    //    [self viewDidLoad];
}
-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    NSLog(@"resp type %@", respType);
    dbManager = [DataBaseManager dataBaseManager];
    
    if ([respType isEqualToString:DELETE_HOUSE]) {
        
        NSString *query = [NSString stringWithFormat:@"DELETE FROM House WHERE ServerID = %@", [resp valueForKey:@"ServerID"]];
        [dbManager execute:query];
        
    }
    
    if ([respType isEqualToString:ITEMPDF_TYPE]){
        
        NSString *status = [resp valueForKey:@"Status"];
        
        if ([status isEqualToString:@"Success"]) {
            NSDictionary *itemPdfDict = [resp valueForKey:@"ItemPDF"];
            pdfLink = [itemPdfDict valueForKey:@"pdf"];
            NSString *item_ID = [itemPdfDict valueForKey:@"item_id"];
            //            NSString *room_ID = [itemPdfDict valueForKey:@"room_id"];
            //            NSString *house_ID = [itemPdfDict valueForKey:@"house_id"];
            NSMutableArray *itemIdsArray = [[NSMutableArray alloc]init];
            
            if ([pdfLink isKindOfClass:[NSNull class]]||(pdfLink.length==0)) {
                pdfLink =@"";
            }
            if ([item_ID isKindOfClass:[NSNull class]]) {
                item_ID =@"";
            }
            
            
            [dbManager execute:[NSString stringWithFormat:@"Update Item set PdfLink='%@' where ServerID='%@'",pdfLink,item_ID]];//Divya
            [dbManager execute:[NSString stringWithFormat:@"Select ID,HouseID,RoomID FROM Item WHERE ServerID = %@", item_ID] resultsArray:itemIdsArray];
            NSLog(@"itemIdsAry:L%@",itemIdsArray);
            
            NSDictionary *itemIdsDict = [itemIdsArray objectAtIndex:0];
            NSString *roomLocalID =[itemIdsDict valueForKey:@"RoomID"];
            NSString *itemLocalID =[itemIdsDict valueForKey:@"ID"];
            NSString *houseLocalID =[itemIdsDict valueForKey:@"HouseID"];
            
            [self downloadPDFWithItemID:itemLocalID withRoomID:roomLocalID withHouseID:houseLocalID withDict:itemPdfDict];
        }else{
            [FAUtilities showAlert:ITEM_PDF_FAILED];
        }
        
    }
}
-(void)downloadPDFWithItemID:(NSString *)itemID withRoomID:(NSString *)roomID withHouseID:(NSString *)houseID withDict:(NSDictionary *)pdfDict{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); // For Saving in libarary
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *dataPath;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
    dbManager = [DataBaseManager dataBaseManager];
    dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:dataPath]){
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        dataPath = [dataPath stringByAppendingPathComponent:@"Image"];
    }
    NSString *localHousePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseID]];
    
    
    
    if (![fileManager fileExistsAtPath:localHousePath]){
        [fileManager createDirectoryAtPath:localHousePath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *localRoomPath = [localHousePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",roomID]];
    
    if (![fileManager fileExistsAtPath:localRoomPath]){
        [fileManager createDirectoryAtPath:localRoomPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *localItemPath = [localRoomPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",itemID]];
    
    if (![fileManager fileExistsAtPath:localItemPath]){
        [fileManager createDirectoryAtPath:localItemPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    
    NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *imageFilePath;
    
    imageFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
    if (![fileManager fileExistsAtPath:imageFilePath]){
        [fileManager createDirectoryAtPath:imageFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    imageFilePath = [imageFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Image"]];
    
    
    NSString *tempHousePath = [imageFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseID]];
    NSString *tempRoomPath = [tempHousePath stringByAppendingString:[NSString stringWithFormat:@"/%@",roomID]];
    NSString *tempItemPath = [tempRoomPath stringByAppendingString:[NSString stringWithFormat:@"/%@",itemID]];
    
    NSString *fileName = [NSString stringWithFormat:@"/%@_%@_%@_%@.pdf",houseID,roomID,itemID,itemID];
    NSString *storePath = [tempItemPath stringByAppendingString:fileName];
    
    NSString *tempPdfStr = [pdfDict valueForKey:@"pdf"];
    [[NSData dataWithContentsOfURL:[NSURL URLWithString:tempPdfStr]] writeToFile:storePath atomically:YES];
    
    
    
    
    NSMutableArray *itemNameAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"Select Name FROM Item WHERE ID = %@", itemID] resultsArray:itemNameAry];
    NSLog(@"itemNameAry%@",itemNameAry);
    
    NSDictionary *itemIdsDict = [itemNameAry objectAtIndex:0];
    NSString *itemNameStr =[itemIdsDict valueForKey:@"Name"];
    
    
    
    
    if ([storePath isKindOfClass:[NSNull class]]||(storePath.length==0)) {
        storePath =@"";
    }
    if ([itemID isKindOfClass:[NSNull class]]) {
        itemID =@"";
    }
    [dbManager execute:[NSString stringWithFormat:@"Update Item set PdfPath='%@' where ID = '%@'",storePath,itemID]];
    if (isEmailPdfClicked == YES) {
        [self emailItemBtnClicked:emailPdfClickedBtn];
    }else{
        if (storePath.length !=0) {
            pdfWebView = [[UIWebView alloc]init];
            
            if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                pdfWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,10,1024,768)];
                
                
            }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                pdfWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,10,768,1024)];
                
            }
            [pdfWebView setScalesPageToFit:YES];
            pdfWebView.contentMode = UIViewContentModeScaleAspectFit;
            
            [[pdfWebView.subviews objectAtIndex:0] setBounces:NO]; //to stop bouncing
            [pdfWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",(int)pdfWebView.frame.size.width]];
            NSURL *filePathURL = [NSURL fileURLWithPath:storePath];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:filePathURL];
            [pdfWebView setUserInteractionEnabled:YES];
            [pdfWebView setDelegate:self];
            [pdfWebView loadRequest:requestObj];
            
            
            pdfcontroller = [[UIViewController alloc] init];
            [pdfcontroller.view addSubview:pdfWebView];
            
            //            UINavigationBar *yourBar = [[UINavigationBar alloc] init];
            //            [pdfcontroller.view addSubview:yourBar];
            //            [self presentViewController:pdfcontroller animated:YES completion:nil];
            
            //            UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(revealMenu:)];
            
            UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelBtn:)];
            
            UIBarButtonItem *rightBarbuttonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBtn:)];
            
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pdfcontroller];
            pdfcontroller.navigationItem.leftBarButtonItem = leftBarButton;
            pdfcontroller.navigationItem.rightBarButtonItem = rightBarbuttonItem;
            pdfcontroller.navigationItem.title = itemNameStr;
            
            [self presentViewController:navigationController animated:YES completion:NULL];
            //            [self.view addSubview:pdfWebView];
        }
    }
}
-(void)cancelBtn:(id)Sender{
    tapTimer = nil;

    [tapTimer invalidate];
    [self removePdf:tempItemPdfStorePath];
    [pdfcontroller dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionBtn:(id)Sender{
    NSLog(@"Action Btn ");
    
    NSLog(@"House id %@", houseIdStr);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *dataPath;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
    
    dbManager = [DataBaseManager dataBaseManager];
    dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:dataPath]){
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        dataPath = [dataPath stringByAppendingPathComponent:@"Image"];
        
        
    }
    
    NSString *localHousePdfPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseIdStr]];
    
    
    
    if (![fileManager fileExistsAtPath:localHousePdfPath]){
        [fileManager createDirectoryAtPath:localHousePdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    
    
    NSMutableArray *roomIdAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT RoomID,Name FROM Item Where ID = '%d'",viewPdfBtnTag] resultsArray:roomIdAry];
    NSString  *roomId = [[roomIdAry objectAtIndex:0]valueForKey:@"RoomID"];
    NSString  *itemName = [[roomIdAry objectAtIndex:0]valueForKey:@"Name"];
    
    
    NSString *localRoomPdfPath = [localHousePdfPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",roomId]];
    
    if (![fileManager fileExistsAtPath:localRoomPdfPath]){
        [fileManager createDirectoryAtPath:localRoomPdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *localItemPdfPath = [localRoomPdfPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",viewPdfBtnTag]];
    
    if (![fileManager fileExistsAtPath:localItemPdfPath]){
        [fileManager createDirectoryAtPath:localItemPdfPath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    
    NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *pdfFilePath;
    
    
    
    NSString *demoPdfFilePath;
    if (![fileManager fileExistsAtPath:rhmFileDir]){
        [fileManager createDirectoryAtPath:demoPdfFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }else {
    }
    demoPdfFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
    if (CurrentUser_ID) {
        
        if (![fileManager fileExistsAtPath:demoPdfFilePath]){
            [fileManager createDirectoryAtPath:demoPdfFilePath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        
        
        demoPdfFilePath = [demoPdfFilePath stringByAppendingPathComponent:@"Image"];
    }
    pdfFilePath = demoPdfFilePath;
    NSString *tempHousePath = [pdfFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseIdStr]];
    NSString *tempRoomPath = [tempHousePath stringByAppendingString:[NSString stringWithFormat:@"/%@",roomId]];
    NSString *tempItemPath = [tempRoomPath stringByAppendingString:[NSString stringWithFormat:@"/%d",viewPdfBtnTag]];
    
    NSString *fileName = [NSString stringWithFormat:@"/%@_%@_%d_%d.pdf",houseIdStr,roomId,viewPdfBtnTag,viewPdfBtnTag];
    
    
    NSString *storePath = [tempItemPath stringByAppendingString:fileName];
    NSData *pdfData = [NSData dataWithContentsOfFile:storePath];
    
    
    NSMutableArray *roomNameAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat: @"Select Name From Room Where ID = '%@'",roomId] resultsArray:roomNameAry];
    NSLog(@"roomNameAry %@",roomNameAry);
    NSString *roomName = [[roomNameAry objectAtIndex:0]valueForKey:@"Name"];
    
    
    NSMutableArray *houseNameAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat: @"Select Name From House Where ID = '%@'",houseIdStr] resultsArray:houseNameAry];
    NSLog(@"houseNameAry %@",houseNameAry);
    NSString *houseName = [[houseNameAry objectAtIndex:0]valueForKey:@"Name"];
    
    
    NSString *tempFilename = [NSString stringWithFormat:@"/%@_%@.pdf",roomName,itemName];
    
    //    NSString *newString = [tempFilename stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //    NSString *tempFilename = @"/file.pdf";
    tempItemPdfStorePath = [tempItemPath stringByAppendingString:tempFilename];
    
    [pdfData writeToFile:tempItemPdfStorePath atomically:YES];
    
    
    //    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Test", pdfData] applicationActivities:nil];
    
    
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:tempItemPdfStorePath]] applicationActivities:nil];
    
    [self.activityViewController setValue:[NSString stringWithFormat:@"Information on %@ in %@ of your %@",itemName,roomName,houseName] forKey:@"subject"];
    //    [mailComposer addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"file.pdf"];
    
    
    self.sharePopOverController = [[UIPopoverController alloc] initWithContentViewController:self.activityViewController];
    self.sharePopOverController.delegate = self;
    
    if ([self.sharePopOverController isPopoverVisible]) {
        [self.sharePopOverController dismissPopoverAnimated:YES];
    }
    [self.sharePopOverController presentPopoverFromBarButtonItem:Sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    //    [self presentViewController:self.activityViewController animated:YES completion:nil];
    
    
    //    [self removePdf:tempStorePath];
    
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
-(NSString*)jsonFormat:(NSString *)type withDictionary:(NSMutableDictionary *)formatDict{
    
    NSMutableArray *loginDetails = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM LoginDetails Where CurrentUser = 'ON'"] resultsArray:loginDetails];
    NSDictionary *currentUser;
    NSString *User_Type;
    NSString *userID;
    if ([loginDetails count]>0) {
        currentUser = [loginDetails objectAtIndex:0];
        User_Type = [currentUser valueForKey:@"User_Type"];
        userID = [currentUser valueForKey:@"UserID"];
    }
    
    
    NSLog(@"userID %@", userID);
    NSLog(@"Container Json Format User_Type %@", User_Type);
    
    
    NSString *bodyStr = [NSString stringWithFormat:@"{\"Type\":\"%@\",\"UserID\":\"%@\",\"ServerID\":\"%@\"}", type,userID, deleteHouseServerID];
    return bodyStr;
}
-(IBAction)editHouseDescBtnClicked:(id)sender{
    [deleteHouseImgBtn removeFromSuperview];
    
    if ([cellValue isEqualToString:@"Edit House Desc"]) {
        //        [cellValue setTitle:@"Done" forState:UIControlStateNormal];
        houseDescTextView.userInteractionEnabled = YES;
        houseDescTextView.layer.borderWidth = 2.0f;
        houseDescTextView.delegate=self;
        //        houseDescTextView.layer.borderColor = [[UIColor grayColor] CGColor];
        houseDescTextView.layer.borderColor =[UIColor colorWithRed:130.0f/255.0f green:91.0f/255.0f blue:48.0f/255.0f alpha:1.0f].CGColor;
        houseSettingsList =[[NSMutableArray alloc]initWithObjects:@"Upload House Images",@"Done",@"Add Room", nil];
        [houseListTableViewMenu reloadData];
        
    }else if ([cellValue isEqualToString:@"Done"]){
        //        [editHouseDescBtn setTitle:@"Edit House Desc" forState:UIControlStateNormal];
        houseDescTextView.userInteractionEnabled = NO;
        houseDescTextView.layer.borderWidth = 0.0f;
        houseDescTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        dbManager = [DataBaseManager dataBaseManager];
        NSString *updatedSyncStatus;
        
        NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM House where ID='%@'",houseIdStr] resultsArray:syncDetails];
        
        NSLog(@"syncDetails %@", syncDetails);
        
        NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
        
        
        if ([syncValue isEqualToString:@"Sync"] || [syncValue isEqualToString:@"Update"]) {
            updatedSyncStatus = @"Update";
        }else{
            updatedSyncStatus = @"New";
        }
        
        //        houseDescTextView.text =[houseDescTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];//multiLine Text
        //        houseDescTextView.text =[houseDescTextView.text stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];//multiLine Text
        
        
        if ([houseDescTextView.text isKindOfClass:[NSNull class]]||(houseDescTextView.text.length==0)) {
            houseDescTextView.text =@"";
        }
        if ([updatedSyncStatus isKindOfClass:[NSNull class]]||(updatedSyncStatus.length==0)) {
            updatedSyncStatus =@"";
        }
        if ([houseIdStr isKindOfClass:[NSNull class]]) {
            houseIdStr =@"";
        }
        
        houseDescTextView.text = [houseDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        [dbManager execute:[NSString stringWithFormat:@"Update House set Description = '%@',syncStatus='%@'  where ID = '%@'",houseDescTextView.text,updatedSyncStatus,houseIdStr]];
        houseSettingsList =[[NSMutableArray alloc]initWithObjects:@"Upload House Images",@"Edit House Desc",@"Add Room", nil];
        [houseListTableViewMenu reloadData];
        
    }
}
-(IBAction)addRoomBtnClicked:(id)sender{
    [deleteHouseImgBtn removeFromSuperview];
    
    
    
    //    addRoomBtn.hidden = YES;
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        addRoomSubView = [[UIView alloc]initWithFrame:CGRectMake(230, 170, 550, 260)];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        addRoomSubView = [[UIView alloc]initWithFrame:CGRectMake(110, 250, 550, 260)];
    }
    //    addRoomSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"addRoomBgView.png"]];
    
    addRoomSubView.backgroundColor = [FAUtilities getUIColorObjectFromHexString:@"#262626" alpha:1];
    
    // heading view and label
    
    UIView *addRoomHeadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 550, 40)];
    addRoomHeadingView.backgroundColor = [UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
    UILabel *headingLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 510, 35)];
    
    if (isRoomUpdated == YES) {
        headingLabel.text = @"Edit Room";
    }else{
        headingLabel.text = @"Add Room";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        NSString *tempText = @"YES";
        [defaults setObject:tempText forKey:@"MakeTextFieldEmpty"];
        [defaults setObject:@"0" forKey:@"Searching"];
        [defaults setObject:@"" forKey:@"SearchValue"];
        
        
        isSearcingItem = @"0";
        itemSearchedString = @"";
        
    }
    
    
    headingLabel.textAlignment = NSTextAlignmentCenter;
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0f];
    [addRoomHeadingView addSubview:headingLabel];
    
    // labels and text fields
    
    UILabel *roomNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 120, 30)];
    roomNameLabel.text = @"Name:";
    roomNameLabel.textAlignment = NSTextAlignmentRight;
    roomNameLabel.textColor = [UIColor whiteColor];
    roomNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    
    
    UILabel *roomDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 110, 120, 30)];
    roomDescLabel.text = @"Description:";
    roomDescLabel.textAlignment = NSTextAlignmentRight;
    roomDescLabel.textColor = [UIColor whiteColor];
    roomDescLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    
    UILabel *roomTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 165, 120, 30)];
    roomTypeLabel.text = @"Type:";
    roomTypeLabel.textAlignment = NSTextAlignmentRight;
    roomTypeLabel.textColor = [UIColor whiteColor];
    roomTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    
    roomNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(150, 50, 350, 35)];
    roomNameTextField.textColor = [UIColor blackColor];
    roomNameTextField.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
    roomNameTextField.backgroundColor=[UIColor whiteColor];
    roomNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    roomNameTextField.autocapitalizationType =UITextAutocapitalizationTypeWords;
    roomNameTextField.delegate=self;
    
    roomDescTextView = [[UITextView alloc]initWithFrame:CGRectMake(150, 95, 350, 60)];
    roomDescTextView.textColor = [UIColor blackColor];
    roomDescTextView.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
    roomDescTextView.backgroundColor=[UIColor whiteColor];
    roomDescTextView.delegate=self;
    
    roomTypeBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 165, 350, 35)];
    [roomTypeBtn setBackgroundImage:[UIImage imageNamed:@"dropDownBtn.png"] forState:UIControlStateNormal];
    
    [roomTypeBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [roomTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    //    [roomTypeBtn setTitle:@"Select Room Type" forState:UIControlStateNormal];
    [roomTypeBtn addTarget:self action:@selector(roomTypeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addRoomCancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 210, 120, 30)];
    [addRoomCancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [addRoomCancelBtn setTitleColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [addRoomCancelBtn addTarget:self action:@selector(addRoomCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [addRoomCancelBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    
    
    
    UIButton *addRoomSaveBtn = [[UIButton alloc]initWithFrame:CGRectMake(280, 210, 150, 30)];
    [addRoomSaveBtn setTitleColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [addRoomSaveBtn addTarget:self action:@selector(addRoomSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [addRoomSaveBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    
    
    
    
    
    if (isRoomUpdated == YES) {
        
        dbManager = [DataBaseManager dataBaseManager];
        NSMutableArray *roomDetailsArray = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat: @"Select * FROM Room where ID='%@'",updateRoomID] resultsArray:roomDetailsArray];
        NSLog(@"roomDetailsArray:%@",roomDetailsArray);
        
        NSDictionary *currentRoomDictionary = [[NSDictionary alloc]init];
        currentRoomDictionary = [roomDetailsArray objectAtIndex:0];
        roomNameTextField.text =[currentRoomDictionary valueForKey:@"Name"];
        roomDescTextView.text = [currentRoomDictionary valueForKey:@"Description"];
        NSString *roomType = [currentRoomDictionary valueForKey:@"Type"];
        
        NSMutableArray *roomTypeArray = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat: @"Select * FROM RoomType where RoomType_ID='%@'",roomType] resultsArray:roomTypeArray];
        
        NSLog(@"roomTypeArray %@", roomTypeArray);
        NSString *typeVal;
        
        if (roomTypeArray.count >0) {
            NSDictionary *tempDict = [[NSDictionary alloc]init];
            tempDict = [roomTypeArray objectAtIndex:0];
            typeVal= [tempDict objectForKey:@"Type"];
        }
        
        
        
        [addRoomSaveBtn setTitle:@"Update Room" forState:UIControlStateNormal];
        if (typeVal.length ==0) {
            [roomTypeBtn setTitle:@"Select Room Type" forState:UIControlStateNormal];
        }else{
            [roomTypeBtn setTitle:typeVal forState:UIControlStateNormal];
        }
    }else{
        [addRoomSaveBtn setTitle:@"Add Room" forState:UIControlStateNormal];
        [roomTypeBtn setTitle:@"Select Room Type" forState:UIControlStateNormal];
        
    }
    
    [addRoomSubView addSubview:addRoomSaveBtn];
    [addRoomSubView addSubview:addRoomCancelBtn];
    [addRoomSubView addSubview:roomTypeBtn];
    [addRoomSubView addSubview:roomDescTextView];
    [addRoomSubView addSubview:roomNameTextField];
    [addRoomSubView addSubview:roomTypeLabel];
    [addRoomSubView addSubview:roomDescLabel];
    [addRoomSubView addSubview:roomNameLabel];
    [addRoomSubView addSubview:addRoomHeadingView];
    addRoomSubView.tag = 1000;
    [self.view addSubview:addRoomSubView];
}
-(IBAction)addHouseBtnClicked:(id)sender{
    [deleteHouseImgBtn removeFromSuperview];
    
    if ([houseDetails count] >= 3) {
        //        [FAUtilities showAlert:@"You can add only 3 house"];
        NSLog(@"You can add only 3 house");
    }else{
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            addHouseSubView = [[UIView alloc]initWithFrame:CGRectMake(230, 170, 550, 300)];
        }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            addHouseSubView = [[UIView alloc]initWithFrame:CGRectMake(110, 250, 550, 300)];
        }
        
        addHouseSubView.backgroundColor = [FAUtilities getUIColorObjectFromHexString:@"#262626" alpha:1];
        
        // heading view and label
        
        UIView *addHouseHeadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 550, 40)];
        addHouseHeadingView.backgroundColor = [UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
        UILabel *headingLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 510, 35)];
        if (isHouseUpdated == YES) {
            headingLabel.text = @"Edit House";
        }else{
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults synchronize];
            NSString *tempText = @"YES";
            [defaults setObject:tempText forKey:@"MakeTextFieldEmpty"];
            [defaults setObject:@"0" forKey:@"Searching"];
            [defaults setObject:@"" forKey:@"SearchValue"];
            
            isSearcingItem = @"0";
            itemSearchedString = @"";
            
            headingLabel.text = @"Add House";
        }
        
        
        
        headingLabel.textAlignment = NSTextAlignmentCenter;
        headingLabel.textColor = [UIColor whiteColor];
        headingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0f];
        [addHouseHeadingView addSubview:headingLabel];
        
        // labels and text fields
        
        UILabel *houseNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 120, 30)];
        houseNameLabel.text = @"Name:";
        houseNameLabel.textAlignment = NSTextAlignmentRight;
        houseNameLabel.textColor = [UIColor whiteColor];
        houseNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
        
        
        UILabel *houseAddrLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 110, 120, 30)];
        houseAddrLabel.text = @"Address:";
        houseAddrLabel.textAlignment = NSTextAlignmentRight;
        houseAddrLabel.textColor = [UIColor whiteColor];
        houseAddrLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
        
        UILabel *houseDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 165, 120, 30)];
        houseDescLabel.text = @"Description:";
        houseDescLabel.textAlignment = NSTextAlignmentRight;
        houseDescLabel.textColor = [UIColor whiteColor];
        houseDescLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
        
        
        
        
        addHouseNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(150, 50, 350, 35)];
        addHouseNameTextField.textColor = [UIColor blackColor];
        addHouseNameTextField.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
        addHouseNameTextField.backgroundColor=[UIColor whiteColor];
        addHouseNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        addHouseNameTextField.autocapitalizationType =UITextAutocapitalizationTypeWords;
        addHouseNameTextField.delegate =self;
        
        
        addHouseAddrTextView = [[UITextView alloc]initWithFrame:CGRectMake(150, 95, 350, 60)];
        addHouseAddrTextView.textColor = [UIColor blackColor];
        addHouseAddrTextView.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
        addHouseAddrTextView.backgroundColor=[UIColor whiteColor];
        addHouseAddrTextView.autocapitalizationType =UITextAutocapitalizationTypeWords;
        addHouseAddrTextView.delegate=self;
        
        addHouseDescTextView = [[UITextView alloc]initWithFrame:CGRectMake(150, 165, 350, 60)];
        addHouseDescTextView.textColor = [UIColor blackColor];
        addHouseDescTextView.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
        addHouseDescTextView.backgroundColor=[UIColor whiteColor];
        addHouseAddrTextView.delegate=self;
        
        
        UIButton *addHouseCancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 250, 120, 30)];
        [addHouseCancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [addHouseCancelBtn setTitleColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [addHouseCancelBtn addTarget:self action:@selector(addHouseCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [addHouseCancelBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
        
        
        UIButton *addHouseSaveBtn = [[UIButton alloc]initWithFrame:CGRectMake(280, 250, 150, 30)];
        
        [addHouseSaveBtn setTitle:@"Add House" forState:UIControlStateNormal];
        
        [addHouseSaveBtn setTitleColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [addHouseSaveBtn addTarget:self action:@selector(addHouseSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [addHouseSaveBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
        
        if (isHouseUpdated == YES) {
            NSDictionary *tempHouseDict = [houseDetails objectAtIndex:0];
            addHouseNameTextField.text = [tempHouseDict objectForKey:@"Name"];
            addHouseDescTextView.text =[tempHouseDict objectForKey:@"Description"];
            addHouseAddrTextView.text=[tempHouseDict objectForKey:@"Address"];
            [addHouseSaveBtn setTitle:@"Update House" forState:UIControlStateNormal];
            
        }
        
        [addHouseSubView addSubview:addHouseSaveBtn];
        [addHouseSubView addSubview:addHouseCancelBtn];
        [addHouseSubView addSubview:addHouseAddrTextView];
        [addHouseSubView addSubview:addHouseDescTextView];
        [addHouseSubView addSubview:addHouseNameTextField];
        [addHouseSubView addSubview:houseAddrLabel];
        [addHouseSubView addSubview:houseDescLabel];
        [addHouseSubView addSubview:houseNameLabel];
        [addHouseSubView addSubview:addHouseHeadingView];
        addHouseSubView.tag = 1001;
        [self.view addSubview:addHouseSubView];
        
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int newLength = [textField.text length] + [string length] - range.length;
    NSLog(@"length %d",newLength);
    
    if (newLength == 1) {
        string = [string uppercaseString];
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    
    if (textField == addHouseNameTextField ||textField==roomNameTextField) {
        if ([string isEqualToString:@""]) {
            NSLog(@"back space");
        }else{
            NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-_'"] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
            //            int maxLength = 30;
            //            if (filtered) {
            //                if (maxLength == 0) {
            //                    return [string isEqualToString:filtered];
            //                }else{
            //                    if (newLength > maxLength) {//accessing max characters in textfield
            //                        [textField resignFirstResponder];
            ////                        [FAUtilities showAlert:[NSString stringWithFormat:INVALID_MAX_LENGTH, maxLength]];
            ////                        return NO;
            //                    }else{
            return [string isEqualToString:filtered];
            //                    }
            //                }
            //            }
        }
    }
    
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    
    int newLength = [textView.text length] + [string length] - range.length;
    NSLog(@"length %d",newLength);
    
    if (newLength == 1) {
        string = [string uppercaseString];
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    
    if (textView == itemNameEditTextView ||textView==itemNameTextView) {
        if ([string isEqualToString:@""]) {
            NSLog(@"back space");
        }else{
            NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-_'"] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
            //            int maxLength = 20;
            //            if (filtered) {
            //                if (maxLength == 0) {
            //                    return [string isEqualToString:filtered];
            //                }else{
            //                    if (newLength > maxLength) {//accessing max characters in textfield
            //                        [textView resignFirstResponder];
            ////                        [FAUtilities showAlert:[NSString stringWithFormat:INVALID_MAX_LENGTH, maxLength]];
            ////                        return NO;
            //                    }else{
            return [string isEqualToString:filtered];
            //                    }
            //                }
            //            }
        }
    }
    
    
    return YES;
}

//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//    return 1;
//}
//
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    return [roomTypeNames count];
//}
//
//
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSString *returnStr = @"";
////Divya
// NSArray* sortedArray = [roomTypeNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    NSLog(@"itemRoomNames sorted Array:%@",sortedArray);
//
//    returnStr = [sortedArray objectAtIndex:row];
//    NSLog(@"%ld Row ", (long)row);
////Divya
//    //returnStr = [roomTypeNames objectAtIndex:row];//Divya
//    [roomTypeBtn setTitle:returnStr forState:UIControlStateNormal];
////    currentRoomID = [roomTypeIds objectAtIndex:row];
//    return returnStr;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//
//    NSString *returnStr = @"";
//
//    if (pickerView == _roomTypePicker) {
//        NSArray* sortedArray = [roomTypeNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//        NSLog(@"itemTypeNames sorted Array:%@",sortedArray);
//
//        returnStr = [sortedArray objectAtIndex:row];//Divya
//        NSLog(@"%ld room Row ", (long)row);
//        NSMutableArray *room_TypeArray = [[NSMutableArray alloc]init];
//        [dbManager execute:[NSString stringWithFormat: @"Select RoomType_ID FROM RoomType where Type='%@'",returnStr] resultsArray:room_TypeArray];
//
//        NSLog(@"room_TypeArray %@", room_TypeArray);
//        NSString *typeVal;
//
//        if (room_TypeArray.count >0) {
//            NSDictionary *tempDict = [[NSDictionary alloc]init];
//            tempDict = [room_TypeArray objectAtIndex:0];
//            typeVal= [tempDict objectForKey:@"RoomType_ID"];
//        }
//
//        NSLog(@"%@ room typeVal ", typeVal);
//        [roomTypeBtn setTitle:returnStr forState:UIControlStateNormal];
//        if (typeVal.length >0) {
//            currentRoomID = typeVal;
//        }
//        NSLog(@"%@ status returnStr ", returnStr);
//        NSLog(@"%@ currentRoomID ", currentRoomID);
//    }
//}


-(void)addRoomCancelBtnClicked:(id)sender{
    //    addRoomBtn.hidden = NO;
    [addRoomSubView removeFromSuperview];
}

-(void)addRoomSaveBtnClicked:(id)sender{
    
    if (roomNameTextField.text.length == 0) {
        [FAUtilities showAlert:@"Please Enter Room Name"];
    }else{
        
        dbManager = [DataBaseManager dataBaseManager];
        int width;
        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
            width = 970;
        }else {
            width = 720;
        }
        
        if (isRoomUpdated == YES) {
            
            NSString *updatedSyncStatus;
            
            NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Room where ID='%@'",updateRoomID] resultsArray:syncDetails];
            
            NSLog(@"syncDetails %@", syncDetails);
            
            NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
            
            
            if ([syncValue isEqualToString:@"Sync"] || [syncValue isEqualToString:@"Update"]) {
                updatedSyncStatus = @"Update";
            }else{
                updatedSyncStatus = @"New";
            }
            
            if ([roomNameTextField.text isKindOfClass:[NSNull class]]||(roomNameTextField.text.length==0)) {
                roomNameTextField.text =@"";
            }
            if ([roomDescTextView.text isKindOfClass:[NSNull class]]||(roomDescTextView.text.length==0)) {
                roomDescTextView.text =@"";
            }
            //            if ([currentRoomID isKindOfClass:[NSNull class]]) {
            //                currentRoomID =@"";
            //            }
            
            if ([currentRoomID isKindOfClass:[NSNull class]]||currentRoomID.length==0||!currentRoomID) {
                currentRoomID=@"0";
            }
            
            if ([updatedSyncStatus isKindOfClass:[NSNull class]]||(updatedSyncStatus.length==0)) {
                updatedSyncStatus =@"";
            }
            
            
            if ([updateRoomID isKindOfClass:[NSNull class]]) {
                updateRoomID =@"";
            }
            
            NSString *tempRoomName = [roomNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempRoomDesc = [roomDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            //            roomNameTextField.text = [roomNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            //            roomDescTextView.text = [roomDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            [dbManager execute:[NSString stringWithFormat: @"Update Room set Name='%@',Description ='%@',Type ='%@',SyncStatus='%@'Where ID='%@'",tempRoomName,tempRoomDesc,currentRoomID,updatedSyncStatus,updateRoomID]];
            [FAUtilities showAlert:@"Room updated"];
            
            
            [self drawAttchmentsView];
            
        }else{
            BOOL isQuerySuccess;
            
            if ([houseIdStr isKindOfClass:[NSNull class]]) {
                houseIdStr =@"";
            }
            
            if ([roomNameTextField.text isKindOfClass:[NSNull class]]||(roomNameTextField.text.length==0)) {
                roomNameTextField.text =@"";
            }
            if ([roomDescTextView.text isKindOfClass:[NSNull class]]||(roomDescTextView.text.length==0)) {
                roomDescTextView.text =@"";
            }
            //            if ([currentRoomID isKindOfClass:[NSNull class]]) {
            //                currentRoomID =@"";
            //            }
            
            if ([currentRoomID isKindOfClass:[NSNull class]]||currentRoomID.length==0||!currentRoomID) {
                currentRoomID=@"0";
            }
            
            
            NSString *tempRoomName = [roomNameTextField.text  stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempRoomDesc = [roomDescTextView.text  stringByReplacingOccurrencesOfString:@"'" withString:@"'''"];
            
            //            roomNameTextField.text = [roomNameTextField.text  stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            //            roomDescTextView.text= [roomDescTextView.text  stringByReplacingOccurrencesOfString:@"'" withString:@"'''"];
            
            isQuerySuccess=[dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Room' (HouseID,Name, Description,Type,SyncStatus)VALUES ('%@','%@','%@','%@','%@')",houseIdStr,tempRoomName,tempRoomDesc,currentRoomID,@"New"]];
            if (isQuerySuccess==YES) {
                [FAUtilities showAlert:@"Room added"];
                
            }else{
                [FAUtilities showAlert:@"Room failed to add due to invalid text entry"];
                
            }
            containerScrollView.hidden = NO;
            
            [self drawAttchmentsView];
        }
        
        [self addRoomCancelBtnClicked:nil];
        
    }
}


- (void)removeImage:(NSString *)fileName
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


-(void)addHouseCancelBtnClicked:(id)sender{
    //    addRoomBtn.hidden = NO;
    [addHouseSubView removeFromSuperview];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [defaults setObject:@"" forKey:@"viewType"];
    
}


-(void)addHouseSaveBtnClicked:(id)sender{
    
    if (addHouseNameTextField.text.length == 0) {
        [FAUtilities showAlert:@"Please Enter House Name"];
    }else if (addHouseAddrTextView.text.length == 0) {
        [FAUtilities showAlert:@"Please Enter House Address"];
    }else{
        
        dbManager = [DataBaseManager dataBaseManager];
        BOOL isQuerySucess;
        
        if (isHouseUpdated == YES) {
            NSString *updatedSyncStatus;
            
            NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM House where ID='%@'",houseIdStr] resultsArray:syncDetails];
            NSLog(@"syncDetails %@", syncDetails);
            
            NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
            
            
            if ([syncValue isEqualToString:@"Sync"] || [syncValue isEqualToString:@"Update"]) {
                updatedSyncStatus = @"Update";
            }else{
                updatedSyncStatus = @"New";
            }
            
            if ([addHouseNameTextField.text isKindOfClass:[NSNull class]]||(addHouseNameTextField.text.length==0)) {
                addHouseNameTextField.text =@"";
            }
            if ([addHouseDescTextView.text isKindOfClass:[NSNull class]]||(addHouseDescTextView.text.length==0)) {
                addHouseDescTextView.text =@"";
            }
            if ([addHouseAddrTextView.text isKindOfClass:[NSNull class]]||(addHouseAddrTextView.text.length==0)) {
                addHouseAddrTextView.text =@"";
            } if ([updatedSyncStatus isKindOfClass:[NSNull class]]||(updatedSyncStatus.length==0)) {
                updatedSyncStatus =@"";
            }
            if ([houseIdStr isKindOfClass:[NSNull class]]) {
                houseIdStr =@"";
            }
            
            
            NSString *tempHouseNameStr = [addHouseNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempHouseDescStr = [addHouseDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempHouseAddrStr = [addHouseAddrTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            //            addHouseNameTextField.text = [addHouseNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            //            houseDescTextView.text = [houseDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            isQuerySucess=[dbManager execute:[NSString stringWithFormat: @"Update House set Name ='%@', Description = '%@',Address = '%@',SyncStatus='%@' where ID = '%@'",tempHouseNameStr,tempHouseDescStr,tempHouseAddrStr,updatedSyncStatus,houseIdStr]];
            if (isQuerySucess==YES) {
                [FAUtilities showAlert:@"House updated"];
            }else{
                [FAUtilities showAlert:@"House failed to update due to invalid text entry"];
                
            }
        }else{
            
            if ([addHouseNameTextField.text isKindOfClass:[NSNull class]]||(addHouseNameTextField.text.length==0)) {
                addHouseNameTextField.text =@"";
            }
            
            if ([addHouseDescTextView.text isKindOfClass:[NSNull class]]||(addHouseDescTextView.text.length==0)) {
                addHouseDescTextView.text =@"";
            }
            if ([addHouseAddrTextView.text isKindOfClass:[NSNull class]]||(addHouseAddrTextView.text.length==0)) {
                addHouseAddrTextView.text =@"";
            }
            
            
            
            NSString *tempHouseNameStr = [addHouseNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempHouseDescStr = [addHouseDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempHouseAddrStr = [addHouseAddrTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            //            addHouseNameTextField.text = [addHouseNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            //            addHouseDescTextView.text = [addHouseDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
            
            isQuerySucess=[dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'House' (Name, Description,Address,SyncStatus,UserID)VALUES ('%@','%@','%@','%@','%@')",tempHouseNameStr,tempHouseDescStr,tempHouseAddrStr,@"New",user_Server_ID]];
            if (isQuerySucess==YES) {
                [FAUtilities showAlert:@"House added"];
            }else{
                [FAUtilities showAlert:@"House failed to add due to invalid text entry"];
                
            }
        }
        
        
        
        
        
        [self addHouseCancelBtnClicked:nil];
        
        NSMutableArray *idAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT LAST_INSERT_ROWID()"] resultsArray:idAry];
        NSLog(@"ID Ary %@", idAry);
        
        
        NSString *currentHouseID =[[idAry objectAtIndex:0] valueForKey:@"LAST_INSERT_ROWID()"];
        
        NSMutableArray *housesAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House where ID ='%@' ",currentHouseID] resultsArray:housesAry];
        
        if ([housesAry count] >0) {
            NSDictionary *tempDic = [housesAry objectAtIndex:0];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"House" forKey:@"Type"];
            [defaults setObject:[tempDic objectForKey:@"Name"] forKey:@"Name"];
            [defaults setObject:[tempDic objectForKey:@"ID"] forKey:@"ID"];
            [defaults setObject:@"Details" forKey:@"viewType"];
            
        }
        
        [self viewDidLoad];
        [self viewWillAppear:YES];
    }
}




-(void)roomTypeBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    roomTypeAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM RoomType"] resultsArray:roomTypeAry];
    
    roomTypeIds = [[NSMutableArray alloc]init];
    roomTypeNames = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[roomTypeAry count]; i++) {
        NSDictionary *tempDict = [roomTypeAry objectAtIndex:i];
        [roomTypeNames addObject:[tempDict valueForKey:@"Type"]];
        [roomTypeIds addObject:[tempDict valueForKey:@"RoomType_ID"]];//Divya
    }
    UIButton *button = (UIButton *)sender;
    UIViewController* popoverContent = [[UIViewController alloc]init];
    
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 260)];
    
    UITableView *tblViewRoomTypeMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300, 260)];
    tblViewRoomTypeMenu.delegate = self;
    tblViewRoomTypeMenu.dataSource = self;
    tblViewRoomTypeMenu.rowHeight = 32;
    tblViewRoomTypeMenu.tag = 1001;
    [popoverView addSubview:tblViewRoomTypeMenu];
    popoverContent.view = popoverView;
    popoverContent.preferredContentSize = CGSizeMake( 300, 260);
    
    self.roomTypePopOverController = [[UIPopoverController alloc]
                                      initWithContentViewController:popoverContent];
    self.roomTypePopOverController.delegate =self;
    if ([self.roomTypePopOverController isPopoverVisible]) {
        [self.roomTypePopOverController dismissPopoverAnimated:YES];
    }
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.roomTypePopOverController  presentPopoverFromRect:button.bounds
                                                     inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    
}

//- (UIToolbar *)createPickerToolbarWithTitle:(NSString *)title  {
//
//    CGRect frame = CGRectMake(0, 0, 300, 44);
//    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame];
//    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
//    NSMutableArray *barItems = [[NSMutableArray alloc] init];
//    UIBarButtonItem *cancelBtn = [self createButtonWithType:UIBarButtonSystemItemCancel target:self action:@selector(actionPickerCancel:)];
//    [barItems addObject:cancelBtn];
//    UIBarButtonItem *flexSpace = [self createButtonWithType:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    [barItems addObject:flexSpace];
//    if (title){
//        UIBarButtonItem *labelButton = [self createToolbarLabelWithTitle:title];
//        [barItems addObject:labelButton];
//        [barItems addObject:flexSpace];
//    }
//    UIBarButtonItem *doneButton = [self createButtonWithType:UIBarButtonSystemItemDone target:self action:@selector(actionPickerDone:)];
//    [barItems addObject:doneButton];
//    [pickerToolbar setItems:barItems animated:YES];
//    return pickerToolbar;
//
//}
//
//- (UIBarButtonItem *)createButtonWithType:(UIBarButtonSystemItem)type target:(id)target action:(SEL)buttonAction {
//    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:type target:target action:buttonAction];
//}
//
//
//- (UIBarButtonItem *)createToolbarLabelWithTitle:(NSString *)aTitle {
//    UILabel *toolBarItemlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180,30)];
//    [toolBarItemlabel setTextAlignment:NSTextAlignmentCenter];
//    [toolBarItemlabel setTextColor:[UIColor whiteColor]];
//    [toolBarItemlabel setFont:[UIFont boldSystemFontOfSize:16]];
//    [toolBarItemlabel setBackgroundColor:[UIColor clearColor]];
//    toolBarItemlabel.text = aTitle;
//    UIBarButtonItem *buttonLabel = [[UIBarButtonItem alloc]initWithCustomView:toolBarItemlabel];
//    return buttonLabel;
//}


//- (IBAction)actionPickerDone:(id)sender {
//    if (self.roomTypePopOverController && self.roomTypePopOverController.popoverVisible)
//        [self.roomTypePopOverController dismissPopoverAnimated:YES];
//
//}
//
//- (IBAction)actionPickerCancel:(id)sender {
//    if (self.roomTypePopOverController && self.roomTypePopOverController.popoverVisible)
//        [self.roomTypePopOverController dismissPopoverAnimated:YES];
//}

/* Method to design Form folders */
- (BOOL)drawAttchmentsView{
    
    //    roomsArray = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    roomsArray = [[NSMutableArray alloc]init];
    itemArray = [[NSMutableArray alloc]init];
    itemImagesArray = [[NSMutableArray alloc]init];
   
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];

    if (houseIdStr.length ==0) {
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus != 'Delete' and UserID='%@'",user_Server_ID] resultsArray:houseDetails];
        if (houseDetails.count >0) {
            houseIdStr = [[houseDetails objectAtIndex:0] valueForKey:@"ID"];
        }
    }
    
    houseDetailsAry = [[NSMutableArray alloc]init];
    if ([isSearcingItem isEqualToString:@"1"] ) {
        //        select room.id as RoomId,room.name as RoomName,room.ServerId as RoomServerId,
        //        item.id as ItemId,item.name as ItemName, item.ServerId as ItemServerId,
        //        Images.Id as ImgId,Images.Id as ImgServerId,images.serverpath as ImgSerPath,images.ImagePath as LocalImgPath
        //        from room
        //        inner join item on item.roomid = room.id and item.SyncStatus != 'Delete' and item.name like '%ta%'
        //        left join images on images.itemid = item.id and images.SyncStatus != 'Delete'
        //        where room.houseid='1' and room.SyncStatus != 'Delete' order by room.id asc , item.id asc, images.id asc
        
        [dbManager execute:[NSString stringWithFormat:@" select room.id as RoomId,room.name as RoomName,room.ServerId as RoomServerId,item.id as ItemId,item.name as ItemName, item.ServerId as ItemServerId,Images.Id as ImgId,Images.Id as ImgServerId,images.serverpath as ImgSerPath,images.ImagePath as LocalImgPath from room inner join item on item.roomid = room.id and item.SyncStatus != 'Delete' and item.name like '%%%@%%' left join images on images.itemid = item.id and images.SyncStatus != 'Delete' where room.houseid='%@' and room.SyncStatus != 'Delete' order by room.id asc , item.id asc, images.id asc",itemSearchedString,houseIdStr] resultsArray:houseDetailsAry];
        
        //        MenuViewController *menuVC = [[MenuViewController alloc]init];
        //        [menuVC viewDidLoad];
        
        
    }else{
        [dbManager execute:[NSString stringWithFormat:@"select room.id as RoomId,room.name as RoomName,room.ServerId as RoomServerId,item.id as ItemId,item.name as ItemName, item.ServerId as ItemServerId,Images.Id as ImgId,Images.Id as ImgServerId,images.serverpath as ImgSerPath,images.ImagePath as LocalImgPath from room left join item on item.roomid = room.id and item.SyncStatus != 'Delete' left join images on images.itemid = item.id and images.SyncStatus != 'Delete' where room.houseid='%@' and room.SyncStatus != 'Delete' order by room.id asc , item.id asc, images.id asc",houseIdStr] resultsArray:houseDetailsAry];
    }
    
    
    
    //    [dbManager execute:[NSString stringWithFormat:@"select room.id as RoomId,room.name as RoomName,room.ServerId as RoomServerId,item.id as ItemId,item.name as ItemName, item.ServerId as ItemServerId,Images.Id as ImgId,Images.Id as ImgServerId,images.serverpath as ImgSerPath,images.ImagePath as LocalImgPath from room left join item on item.roomid = room.id and item.SyncStatus != 'Delete' left join images on images.itemid = item.id and images.SyncStatus != 'Delete' where room.houseid='%@' and room.SyncStatus != 'Delete' order by room.id asc , item.id asc, images.id asc",houseIdStr] resultsArray:houseDetailsAry];
    
    //    isSearcingItem
    //    itemSearchedString
    
    
    //    [dbManager execute:[NSString stringWithFormat:@"select room.id as RoomId,room.name as RoomName,room.ServerId as RoomServerId,item.id as ItemId,item.name as ItemName, item.ServerId as ItemServerId,Images.Id as ImgId,Images.Id as ImgServerId,images.serverpath as ImgSerPath,images.ImagePath as LocalImgPath from room left join item on item.roomid = room.id and item.SyncStatus != 'Delete' left join images on images.itemid = item.id and images.SyncStatus != 'Delete' where room.houseid='%@' and room.SyncStatus != 'Delete' order by room.id asc , item.id asc, images.ImagePath desc",houseIdStr] resultsArray:houseDetailsAry];
    
    
    
    CGFloat originX;
    CGFloat width =0;
    originX = 10;
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        width = 982;
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        width = 732;
    }
    
    originYForRoom = 30;
    CGFloat height = 200;
    
    for (UIView *view in containerScrollView.subviews) {
        [view removeFromSuperview];
    }
    int foldersContainEachRow = 1;
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        foldersContainEachRow = 1;
    }
    
    
    for (int i=0; i<[houseDetailsAry count]; i++) {
        NSString *roomId = [[houseDetailsAry objectAtIndex:i]valueForKey:@"RoomId"];
        NSString *roomName = [[houseDetailsAry objectAtIndex:i]valueForKey:@"RoomName"];
        NSString *roomServerId = [[houseDetailsAry objectAtIndex:i]valueForKey:@"RoomServerId"];
        
        [self loadRoomArray:roomId withName:roomName withServerID:roomServerId];
        
        NSString *itemId = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ItemId"];
        NSString *itemName = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ItemName"];
        NSString *itemServerId = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ItemServerId"];
        
        [self loadItemArray:itemId withName:itemName withServerID:itemServerId withRoomID:roomId];
        
        
        NSString *imgId = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ImgId"];
        NSString *imgSerPath = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ImgSerPath"];
        NSString *imgData = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ImgData"];
        NSString *imgServerId = [[houseDetailsAry objectAtIndex:i]valueForKey:@"ImgServerID"];
        NSString *imgLocalPath =[[houseDetailsAry objectAtIndex:i]valueForKey:@"LocalImgPath"];
        
        [self loadItemImagesArray:imgId withImgServerPath:imgSerPath withServerID:imgServerId withImgData:imgData withLocalImgPath:imgLocalPath withItemID:itemId withRoomID:roomId];
        
    }
    
    
    
    NSLog(@"roomsArray %@",roomsArray);
    NSLog(@"itemArray %@",itemArray);
    NSLog(@"itemImagesArray %@",itemImagesArray);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *isSearching = [defaults objectForKey:@"Searching"];
    NSString *searchValue = [defaults objectForKey:@"SearchValue"];
    
    NSLog(@"isSearching , isSearching %@ %@", isSearching,searchValue);
    
    //    if ([isSearching isEqualToString:@"1"]) {
    //        roomsArray = [defaults objectForKey:@"SearchRoomsArray"];
    //        itemArray =[defaults objectForKey:@"serchedItemAry"];
    //    }
    
    
    
    for (int i=0; i<[roomsArray count]; i++) {
        NSString *btnID =[[roomsArray objectAtIndex:i]valueForKey:@"RoomId"];
        [self addRoom:btnID withFrame:CGRectMake(originX, originYForRoom, width, height) WithUpdateY:YES];
    }
    return YES;
}
-(void)loadRoomArray:(NSString *)roomID withName:(NSString *)roomName withServerID:(NSString *)serverID{
    BOOL isRoomExists = NO;
    
    for (int i=0; i<[roomsArray count]; i++) {
        NSDictionary *tempDict = [roomsArray objectAtIndex:i];
        if ([[tempDict valueForKey:@"RoomId"] isEqualToString:roomID]) {
            isRoomExists = YES;
            break;
        }
    }
    if (isRoomExists == NO) {
        NSMutableDictionary *roomDictionary = [[NSMutableDictionary alloc]init];
        [roomDictionary setObject:roomID forKey:@"RoomId"];
        [roomDictionary setObject:roomName forKey:@"RoomName"];
        [roomDictionary setObject:serverID forKey:@"RoomServerId"];
        [roomsArray addObject:roomDictionary];
    }
}
-(void)loadItemArray:(NSString *)itemID withName:(NSString *)itemName withServerID:(NSString *)serverID withRoomID:(NSString *)itemRoomID{
    BOOL isItemExists = NO;
    
    for (int i=0; i<[itemArray count]; i++) {
        NSDictionary *tempDict = [itemArray objectAtIndex:i];
        if ([[tempDict valueForKey:@"ItemId"] isEqualToString:itemID]) {
            isItemExists = YES;
            break;
        }
    }
    
    
    if (isItemExists == NO) {
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc]init];
        
        [itemDictionary setObject:itemRoomID forKey:@"ItemRoomId"];
        [itemDictionary setObject:itemID forKey:@"ItemId"];
        [itemDictionary setObject:itemName forKey:@"ItemName"];
        [itemDictionary setObject:serverID forKey:@"ItemServerId"];
        [itemArray addObject:itemDictionary];
    }
}
-(void)loadItemImagesArray:(NSString *)imgID withImgServerPath:(NSString *)imgServerPath withServerID:(NSString *)serverID withImgData:(NSString *)imgData withLocalImgPath:(NSString *)localImgPath withItemID:(NSString *)itemID withRoomID:(NSString *)RoomID{
    
    
    BOOL isItemImageExists = NO;
    
    for (int i=0; i<[itemImagesArray count]; i++) {
        NSDictionary *tempDict = [itemImagesArray objectAtIndex:i];
        if ([[tempDict objectForKey:@"RoomID"] isEqualToString:RoomID] && [[tempDict objectForKey:@"ItemID"] isEqualToString:itemID]) {
            isItemImageExists = YES;
            break;
        }
    }
    
    if (isItemImageExists == NO && imgID.length >0) {
        NSMutableDictionary *itemImagesDictionary = [[NSMutableDictionary alloc]init];
        [itemImagesDictionary setObject:imgID forKey:@"ImgId"];
        [itemImagesDictionary setObject:imgServerPath forKey:@"ImgServerPath"];
        if (serverID.length !=0) {
            [itemImagesDictionary setObject:serverID forKey:@"ImgServerId"];
        }
        [itemImagesDictionary setObject:localImgPath forKey:@"LocalImgPath"];
        
        //        [itemImagesDictionary setObject:imgData forKey:@"ImgData"];
        [itemImagesDictionary setObject:itemID forKey:@"ItemID"];
        [itemImagesDictionary setObject:RoomID forKey:@"RoomID"];
        [itemImagesArray addObject:itemImagesDictionary];
    }
}
-(void)addRoom:(NSString *)roomID withFrame:(CGRect)rect WithUpdateY:(BOOL)isUpdate{
    
    UIView *folderView = [self createFolderViewForTag:[roomID intValue] withID:[roomID intValue] withFrame:rect];
    
    folderView.backgroundColor = [UIColor clearColor];
    folderView.tag =[roomID intValue];
    //    folderView.
    
    [containerScrollView addSubview:folderView];
    
    if (isUpdate == NO) {
        NSLog(@"Update No");
    }else{
        originYForRoom += rect.size.height+30;
//        NSLog(@"Update YES");
    }
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        containerScrollView.contentSize = CGSizeMake(0, originYForRoom+200+200);
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        containerScrollView.contentSize = CGSizeMake(0, originYForRoom+200+100);
    }
}

/* Method to create Form folders */
- (UIView*)createFolderViewForTag:(int)tag withID:(int)roomID withFrame:(CGRect)rect{
    UIView *folderVIew = [[UIView alloc]initWithFrame:rect];
    folderVIew.backgroundColor = [UIColor clearColor];
    
    containerSubView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 40)];
    containerSubView.tag = tag;
    
    UILabel *containerSubViewHeaderTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rect.size.width-200, 40)];
    containerSubViewHeaderTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    NSString *roomName;
    
    for (int i=0; i<[houseDetailsAry count]; i++) {
        NSString *temproomID = [[houseDetailsAry objectAtIndex:i]objectForKey:@"RoomId"];
        if ([temproomID isEqualToString:[NSString stringWithFormat:@"%d",roomID]]) {
            roomName =[[houseDetailsAry objectAtIndex:i]objectForKey:@"RoomName"];
            break;
        }else{
            continue;
        }
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *  highlightType = [defaults objectForKey:@"Type"];
    
    if ([highlightType isEqualToString:@"Room"]) {
        if ([roomIdStr isEqualToString:[NSString stringWithFormat:@"%d",roomID]]) {
            //            folderVIew.layer.borderColor = [UIColor greenColor].CGColor;
            folderVIew.layer.borderColor = [[FAUtilities getUIColorObjectFromHexString:@"#1C1C1C" alpha:1] CGColor];
            folderVIew.layer.borderWidth = 3;
        }
    }
    
    
    containerSubViewHeaderTitleLabel.text = roomName;
    [containerSubViewHeaderTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
    containerSubViewHeaderTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    containerSubViewHeaderTitleLabel.numberOfLines = 0;
    //    containerSubViewHeaderTitleLabel.textColor = [UIColor whiteColor];
    containerSubViewHeaderTitleLabel.textColor = [UIColor blackColor];
    
    containerSubViewHeaderTitleLabel.backgroundColor =[UIColor colorWithRed:220.0f/255.0f green:221.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
    
    [containerSubView addSubview:containerSubViewHeaderTitleLabel];
    
    
    
    UILabel *containerSubViewRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(rect.size.width-200, 0, 150, 40)];
    containerSubViewRightLabel.textAlignment = NSTextAlignmentCenter;
    
    currentItemArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[itemArray count]; i++) {
        NSString *currentRoomId = [[itemArray objectAtIndex:i]valueForKey:@"ItemRoomId"];
        NSString *currentItemID =[[itemArray objectAtIndex:i]valueForKey:@"ItemId"];
        
        if ([currentRoomId isEqualToString:[NSString stringWithFormat:@"%d",roomID]]) {
            if (currentItemID.length !=0) {
                [currentItemArray addObject:[itemArray objectAtIndex:i]];
            }
        }
    }
    
    if ([currentItemArray count] == 1) {
        containerSubViewRightLabel.text = [NSString stringWithFormat:@"%lu item",(unsigned long)[currentItemArray count]];
    }else{
        containerSubViewRightLabel.text = [NSString stringWithFormat:@"%lu items",(unsigned long)[currentItemArray count]];
    }
    
    [containerSubViewRightLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:22.0]];
    containerSubViewRightLabel.lineBreakMode = NSLineBreakByWordWrapping;
    containerSubViewRightLabel.numberOfLines = 0;
    //    containerSubViewRightLabel.textColor = [UIColor whiteColor];
    containerSubViewRightLabel.textColor = [UIColor blackColor];
    
    containerSubViewRightLabel.backgroundColor =[UIColor colorWithRed:220.0f/255.0f green:221.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
    
    containerSubView.backgroundColor =[UIColor colorWithRed:220.0f/255.0f green:221.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
    [containerSubView addSubview:containerSubViewRightLabel];
    
    
    UIButton *optionsBtn = [[UIButton alloc]initWithFrame:CGRectMake(rect.size.width-200+containerSubViewRightLabel.frame.size.width, 5, 35, 35)];
    [optionsBtn setBackgroundImage:[UIImage imageNamed:@"blackSetting.png"] forState:UIControlStateNormal];
    [optionsBtn addTarget:self action:@selector(roomOptionsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    optionsBtn.tag = tag;
    
    [containerSubView addSubview:optionsBtn];
    
    UIView *itemsScrollBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, rect.size.width, 160)];
    UIScrollView *itemsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, rect.size.width, 160)];
    
    itemsScrollView.layer.borderColor= [[UIColor blackColor]CGColor];
    itemsScrollView.layer.borderWidth= 1;
    
    [self drawItemsAttchmentsViewWithBgView:itemsScrollBgView AndScrollView:itemsScrollView WithRoomTag:tag];
    [itemsScrollBgView addSubview:itemsScrollView];
    
    [folderVIew addSubview:itemsScrollBgView];
    
    
    [folderVIew addSubview:containerSubView];
    return folderVIew;
}
/* Method to design Items */
- (void)drawItemsAttchmentsViewWithBgView:(UIView *)bgView AndScrollView:(UIScrollView *)itemScrollView WithRoomTag:(int)roomtag{
    
    UIImageView *noImage;
    
    if ([currentItemArray count]== 0) {
        //        imageScrollView = [[UIScrollView alloc]init];.
        for (UIView *v in [itemScrollView subviews]) {
            [v removeFromSuperview];
        }
        
        noImage = [[UIImageView alloc] initWithFrame:
                   CGRectMake(304, 0,
                              125,
                              125)];
        
        noImage.image = [UIImage imageNamed:@"no_image.jpg"];
        noImage.contentMode = UIViewContentModeScaleAspectFit;
        //        noImage.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"frame.png"]] CGColor];
        //        noImage.layer.borderWidth = 10.0f;
        
    }else{
        
        for (UIView *v in [itemScrollView subviews]) {
            [v removeFromSuperview];
        }
        
        
        itemScrollView.pagingEnabled = YES;
        [itemScrollView setAlwaysBounceVertical:NO];
        //setup internal views
        
        originXForItem = 0;
        
        NSInteger numberOfViews = [currentItemArray count];
        for (int i = 0; i < numberOfViews; i++) {
            NSMutableDictionary *tempDict = [currentItemArray objectAtIndex:i];
            NSString *itemID = [tempDict objectForKey:@"ItemId"];
            NSString *roomID = [tempDict objectForKey:@"ItemRoomId"];
            
            //            -(void)addItemForRoomID:(NSString *)roomID AndItemID:(NSString *)itemID withFrame:(CGRect *)rect{
            
            [self addItemForRoomID:roomID AndItemID:itemID withItemScrollView:itemScrollView];
        }
        //set the scroll view content size
        itemScrollView.contentSize = CGSizeMake(127 *
                                                numberOfViews,
                                                itemScrollView.frame.size.height);
    }
    
    //    itemScrollView.layer.borderColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"frame.png"]].CGColor;
    itemScrollView.layer.borderColor = [UIColor blackColor].CGColor;
    itemScrollView.layer.borderWidth = 1.0f;
    itemScrollView.layer.cornerRadius=2.0f;
    
    
    [bgView addSubview:itemScrollView];
    
}


-(void)addItemForRoomID:(NSString *)roomID AndItemID:(NSString *)itemID withItemScrollView:(UIScrollView *)ScrollView{
    
    UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(originXForItem, 0, 125, 160)];
    UIButton *itemImgBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,125,125)];
    
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [gestureRecognizer addTarget:self action:@selector(itemLongPressed:)];
    [itemImgBtn addGestureRecognizer: gestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [itemImgBtn addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemBtnClicked:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    [itemImgBtn addGestureRecognizer:singleTap];

    itemImgBtn.tag = [itemID intValue];

    NSString *itemName;
    
    for (int i=0; i<[currentItemArray count]; i++) {
        NSString *tempItemID = [[currentItemArray objectAtIndex:i]objectForKey:@"ItemId"];
        if (itemID.length !=0) {
            if ([tempItemID isEqualToString:itemID]) {
                itemName =[[currentItemArray objectAtIndex:i]objectForKey:@"ItemName"];
                break;
            }else{
                continue;
            }
        }
    }

//    NSString *valStr;
    NSString *imgUrl;
    NSString *imgLocalPath;
    NSString *imgID;
    
    for (int i=0; i<[itemImagesArray count]; i++) {
        NSString *imgRoomID = [[itemImagesArray objectAtIndex:i]valueForKey:@"RoomID"];
        NSString *imgItemID = [[itemImagesArray objectAtIndex:i]valueForKey:@"ItemID"];
        imgID =[[itemImagesArray objectAtIndex:i]valueForKey:@"ImgId"];
        
        if (imgID.length == 0) {
            NSLog(@"igone dict");
        }else{
            if ([imgRoomID isEqualToString:roomID] && [imgItemID isEqualToString:itemID]) {
                imgUrl =[[itemImagesArray objectAtIndex:i]valueForKey:@"ImgServerPath"];
                
//                NSString *tempFile = [[itemImagesArray objectAtIndex:i]valueForKey:@"ImgServerPath"];
//                imgUrl = [tempFile stringByReplacingOccurrencesOfString:@"rhm.mlx.com" withString:@"192.168.137.20"];

                
                imgLocalPath = [[itemImagesArray objectAtIndex:i] valueForKey:@"LocalImgPath"];
                if (imgLocalPath.length != 0) {
                    [itemImgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgLocalPath] forState:UIControlStateNormal];
                }else{
                    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemImgBtn.frame.origin.x, itemImgBtn.frame.origin.y, itemImgBtn.frame.size.width, itemImgBtn.frame.size.width)];
                    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                                         [UIImage imageNamed:@"Loading_1.png"],
                                                         [UIImage imageNamed:@"Loading_2.png"],
                                                         [UIImage imageNamed:@"Loading_3.png"],
                                                         [UIImage imageNamed:@"Loading_4.png"],
                                                         [UIImage imageNamed:@"Loading_5.png"],
                                                         [UIImage imageNamed:@"Loading_6.png"],
                                                         [UIImage imageNamed:@"Loading_7.png"],
                                                         [UIImage imageNamed:@"Loading_8.png"],
                                                         [UIImage imageNamed:@"Loading_9.png"],
                                                         [UIImage imageNamed:@"Loading_10.png"],
                                                         [UIImage imageNamed:@"Loading_11.png"],nil];
                    animatedImageView.animationDuration = 1.0f;
                    animatedImageView.animationRepeatCount = 0;
                    [animatedImageView startAnimating];
                    
                    [itemImgBtn addSubview:animatedImageView];
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        // the slow stuff to be done in the background
                        NSString* webStringURL = [imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
                        NSString *dataPath;
                        
                        NSFileManager* fileManager = [NSFileManager defaultManager];
                        NSError* error = nil;
                        
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
                        dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
                       
                        if (CurrentUser_ID) {
                            if (![fileManager fileExistsAtPath:dataPath]){
                                [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
                            }else {
                            }
                            dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
                        }
                        
                        NSString *localHousePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseIdStr]];
                        
                        if (![fileManager fileExistsAtPath:localHousePath]){
                            [fileManager createDirectoryAtPath:localHousePath withIntermediateDirectories:NO attributes:nil error:&error];
                        }else {
                        }
                        
                        NSString *localRoomPath = [localHousePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",roomID]];
                        
                        if (![fileManager fileExistsAtPath:localRoomPath]){
                            [fileManager createDirectoryAtPath:localRoomPath withIntermediateDirectories:NO attributes:nil error:&error];
                        }else {
                        }
                        
                        NSString *localItemPath = [localRoomPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",itemID]];
                        
                        if (![fileManager fileExistsAtPath:localItemPath]){
                            [fileManager createDirectoryAtPath:localItemPath withIntermediateDirectories:NO attributes:nil error:&error];
                        }else {
                        }
                        
                        
                        NSString *rhmFileDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
                        NSString *imageFilePath;
                        NSString *storePath;
                        imageFilePath= [rhmFileDir stringByAppendingPathComponent:CurrentUser_ID];
                        if (CurrentUser_ID) {
                            
                            if (![fileManager fileExistsAtPath:imageFilePath]){
                                [fileManager createDirectoryAtPath:imageFilePath withIntermediateDirectories:NO attributes:nil error:&error];
                            }else {
                            }
                            imageFilePath = [imageFilePath stringByAppendingPathComponent:@"Image"];
                            NSString *tempHousePath = [imageFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseIdStr]];
                            NSString *tempRoomPath = [tempHousePath stringByAppendingString:[NSString stringWithFormat:@"/%@",roomID]];
                            NSString *tempItemPath = [tempRoomPath stringByAppendingString:[NSString stringWithFormat:@"/%@",itemID]];
                            
                            NSString *fileName = [NSString stringWithFormat:@"/%@_%@_%@_%@.png",houseIdStr,roomID,itemID,imgID];
                            storePath = [tempItemPath stringByAppendingString:fileName];
                        }
                        
                        // for handling memory pressure handle images having more than 1000 width, with aspect ratio of height

                        UIImage *tempImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]]];
                        CGFloat width = tempImg.size.width;
                        CGFloat height = tempImg.size.height;
                        
                        float bytes =[[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]] length];
                        float kb = bytes/1024;
                        
                         NSLog(@"Size of Image(bytes):%f",bytes);
                        NSLog(@"Size of Image(kb):%f",kb);
                        NSLog(@"Image Url %@",webStringURL);
                        NSLog(@"Width:%f, Height:%f",width,height);
                        
                        if (width >800) {
                            float scaleFactor = 800 / width;
                            float newHeight = height * scaleFactor;
                            float newWidth = width * scaleFactor;
                            UIImage *reducedNewImage =[self imageWithImage:tempImg scaledToSize:CGSizeMake(newWidth,newHeight)];
                            NSData *reducedImageData = UIImageJPEGRepresentation(reducedNewImage, 0.8);;
                            [reducedImageData writeToFile:storePath atomically:YES];
                            NSLog(@"reduced length %lu",(unsigned long)[reducedImageData length]);
                        }else{
                            [[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]] writeToFile:storePath atomically:YES];
                        }
                        
                        [animatedImageView removeFromSuperview];
                        [itemImgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:storePath] forState:UIControlStateNormal];

                        
                        NSFileManager *filemanager=[NSFileManager defaultManager];
                        BOOL fileExists = [filemanager fileExistsAtPath:storePath];
                        
                        dbManager= [DataBaseManager dataBaseManager];
                        if ([storePath isKindOfClass:[NSNull class]]||(storePath.length==0)) {
                            storePath =@"";
                        }
                        
                        
                        NSLog(@"storePath :%@",storePath);
                        
                        if (fileExists == YES) {
                            [dbManager execute:[NSString stringWithFormat:@"Update Images set ImagePath='%@' where ID = '%@'",storePath,imgID]];
                            sleep(0.1);
                        }else{
                            [dbManager execute:[NSString stringWithFormat:@"Delete From Images where ID = '%@'",imgID]];
                            sleep(0.1);
                        }
                        
                    });
                }
                break;
            }
        }
    }
    
    
    
    //        if (imgUrl.length !=0) {
    
    
    //        }
    
    itemView.backgroundColor = [UIColor clearColor];
    //    itemView.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"frame.png"]] CGColor];
    //    itemView.layer.borderWidth = 10;
    itemView.tag =[roomID intValue];
    
    itemView.layer.borderColor = [[UIColor grayColor] CGColor];
    itemView.layer.borderWidth =1.0f;
    
    UILabel *itemNameLabel = [[UILabel alloc]init];
    itemNameLabel.frame=CGRectMake(0, 125, 125, 35);
    itemNameLabel.textAlignment = NSTextAlignmentCenter;
    
    itemNameLabel.text = itemName;
    itemNameLabel.tag = [itemID intValue];
    
    UILongPressGestureRecognizer *labelGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [labelGestureRecognizer addTarget:self action:@selector(itemNameLongPressed:)];
    [itemNameLabel addGestureRecognizer: labelGestureRecognizer];
    
    
    itemNameLabel.userInteractionEnabled = YES;
    itemNameLabel.textColor = [UIColor blackColor];
    //   itemNameLabel.backgroundColor = [UIColor colorWithRed:130.0f/255.0f green:91.0f/255.0f blue:48.0f/255.0f alpha:0.5f];
    itemNameLabel.backgroundColor =[UIColor colorWithRed:236.0f/255.0f green:245.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    [itemView addSubview:itemImgBtn];
    [itemView addSubview:itemNameLabel];
    [ScrollView addSubview:itemView];
    
    originXForItem += 125+2.0f;;
    ScrollView.contentSize = CGSizeMake(originXForItem+125+100,
                                        ScrollView.frame.size.height);
}


-(void)roomOptionsBtnClicked:(id)sender{
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    
    [addRoomSubView removeFromSuperview];
    [addHouseSubView removeFromSuperview];
    
    UIButton *itemOptionBtn = (UIButton *)sender;
    [deleteHouseImgBtn removeFromSuperview];
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    currentOptionBtnTag = itemOptionBtn.tag;
    
    UIViewController* popoverContent = [[UIViewController alloc]init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 160)];
    //    popoverView.backgroundColor = [UIColor blackColor];
    
    UITableView *tblViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 200, 160)];
    tblViewMenu.delegate = self;
    tblViewMenu.dataSource = self;
    tblViewMenu.rowHeight = 32;
    [popoverView addSubview:tblViewMenu];
    popoverContent.view = popoverView;
    //    popoverContent.contentSizeForViewInPopover = CGSizeMake(140, 102);
    popoverContent.preferredContentSize = CGSizeMake(200, 160);
    
    self.optionsPopOver = [[UIPopoverController alloc]
                           initWithContentViewController:popoverContent];
    self.optionsPopOver.delegate =self;
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    if ([self.optionsPopOver isPopoverVisible]) {
        [self.optionsPopOver dismissPopoverAnimated:YES];
    }
    [self.optionsPopOver  presentPopoverFromRect:CGRectMake(0, 0, 133, 29)
                                          inView:itemOptionBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag ==1) {
        return [houseSettingsList count];
    }else if (tableView.tag ==1001) {
        return [roomTypeNames count];
    }
    else{
        return [optionsListAry count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView.tag ==1) {
        cell.textLabel.text = [houseSettingsList objectAtIndex:indexPath.row];
    }else if(tableView.tag==1001){
        NSArray* sortedArray = [roomTypeNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"itemRoomNames sorted Array:%@",sortedArray);
        cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];
        
        //do you stuff here
        if([self.checkedIndexPath isEqual:indexPath])
        {
            if ([roomTypeBtn.titleLabel.text isEqualToString:@"Select Room Type"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
  
            }else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [roomTypeBtn setTitle:cell.textLabel.text  forState:UIControlStateNormal];

            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    else{
        cell.textLabel.text = [optionsListAry objectAtIndex:indexPath.row];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.optionsPopOver dismissPopoverAnimated:YES];
    dbManager = [DataBaseManager dataBaseManager];
    
    if (tableView.tag ==1) {
        if (indexPath.row ==0) {
            [self.houseSettingsPopOver dismissPopoverAnimated:YES];
            
            [self uploadHouseImagesBtnClicked:nil];
        }else if (indexPath.row == 1){
            //            cellValue = [houseSettingsList objectAtIndex:indexPath.row];
            //            if ([cellValue isEqualToString:@"Done"]) {
            //                [self.houseSettingsPopOver dismissPopoverAnimated:YES];
            //            }
            //            [self editHouseDescBtnClicked:nil];
            [self.houseSettingsPopOver dismissPopoverAnimated:YES];
            isHouseUpdated = YES;
            updateHouseID =[NSString stringWithFormat:@"%@",houseIdStr];
            
            [self addHouseBtnClicked:nil];
        }else if (indexPath.row ==2){
            [self.houseSettingsPopOver dismissPopoverAnimated:YES];
            isRoomUpdated = NO;
            [self addRoomBtnClicked:nil];
        }else if (indexPath.row ==3){
            [self.houseSettingsPopOver dismissPopoverAnimated:YES];
            [self deleteHouse:nil];
        }
    }
    else if (tableView.tag==1001){
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *cellLabelText = cell.textLabel.text;
        
        NSArray* sortedArray = [roomTypeNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"roomNames sorted Array:%@",sortedArray);
        NSMutableArray *room_TypeArray = [[NSMutableArray alloc]init];

       
        //do work for checkmark
        if(self.checkedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView
                                            cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if([self.checkedIndexPath isEqual:indexPath])
        {
            self.checkedIndexPath = nil;
            cellLabelText = @"";//Divya

        }
        else
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            cellLabelText = [sortedArray objectAtIndex:indexPath.row];//Divya
        }
        
        
        NSString *typeVal;
        
        if (cellLabelText.length!=0) {
            NSLog(@"%ld room Row ", (long)indexPath.row);

            [roomTypeBtn setTitle:cellLabelText forState:UIControlStateNormal];
            [dbManager execute:[NSString stringWithFormat: @"Select RoomType_ID FROM RoomType where Type='%@'",cellLabelText] resultsArray:room_TypeArray];
            NSLog(@"room_TypeArray %@", room_TypeArray);
            if (room_TypeArray.count >0) {
                NSDictionary *tempDict = [[NSDictionary alloc]init];
                tempDict = [room_TypeArray objectAtIndex:0];
                typeVal= [tempDict objectForKey:@"RoomType_ID"];
            }
            
            NSLog(@"%@ room typeVal ", typeVal);

            if (typeVal.length >0) {
                currentRoomID = typeVal;
            }
        }else {
            [roomTypeBtn setTitle:@"Select RoomType" forState:UIControlStateNormal];
             currentRoomID = @"";
        }
        
        NSLog(@"%@ room cell text ", cellLabelText);
        NSLog(@"%@ currentRoomID ", currentRoomID);
        
       [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.roomTypePopOverController dismissPopoverAnimated:YES];

    }
    else{
        if (indexPath.row == 0) {
            
            NSMutableArray *tempRoomsAry = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Room Where ID = '%d'",currentOptionBtnTag] resultsArray:tempRoomsAry];
            NSDictionary *tempRoomDict = [tempRoomsAry objectAtIndex:0];
            
            
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setObject:tempRoomDict forKey:@"RoomDetails"];
            [standardUserDefaults synchronize];
            
            isSearcingItem = @"0";
            itemSearchedString = @"";
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults synchronize];
            NSString *tempText = @"YES";
            [defaults setObject:tempText forKey:@"MakeTextFieldEmpty"];
            [defaults setObject:@"0" forKey:@"Searching"];
            [defaults setObject:@"" forKey:@"SearchValue"];
            
            
            AddItemViewController *generalVc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
            generalVc.itemID=@"";
            NSString *tempRoomID =[NSString stringWithFormat:@"%d",currentOptionBtnTag];
            generalVc.roomID =tempRoomID;
            
            [self.navigationController pushViewController:generalVc animated:YES];
        }else if (indexPath.row ==1){
            [self deleteRoom:nil];
        }else if (indexPath.row ==2){
            NSLog(@"update item clicked");
            [self.optionsPopOver dismissPopoverAnimated:YES];
            updateRoomID =[NSString stringWithFormat:@"%d",currentOptionBtnTag];
            isRoomUpdated = YES;
            [self addRoomBtnClicked:nil];
        }
    }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)deleteHouse:(id)sender{
    
    
    deletedHouseDict = [houseDetails objectAtIndex:0];
    deleteHouseID = [deletedHouseDict valueForKey:@"ID"];
    deleteHouseServerID = [deletedHouseDict valueForKey:@"ServerID"];
    
    
    NSString *deletedHouseName = [deletedHouseDict valueForKey:@"Name"];
    NSString *alertMsg = [NSString stringWithFormat:@"Are you sure your want to delete %@?",deletedHouseName];
    deleteHouseAlertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                      message:alertMsg
                                                     delegate:self
                                            cancelButtonTitle:@"No"
                                            otherButtonTitles:@"Yes", nil];
    [deleteHouseAlertView show];
    
    
}


-(void)deleteRoom:(id)sender{
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *tempRoomsAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT ID,ServerID,Name FROM Room Where ID = '%d'",currentOptionBtnTag] resultsArray:tempRoomsAry];
    deletedRoomDict = [tempRoomsAry objectAtIndex:0];
    deleteRoomID = [deletedRoomDict valueForKey:@"ID"];
    deleteRoomServerID = [deletedRoomDict valueForKey:@"ServerID"];
    
    
    NSString *deletedRoomName = [deletedRoomDict valueForKey:@"Name"];
    NSString *alertMsg = [NSString stringWithFormat:@"Are you sure your want to delete %@?",deletedRoomName];
    deleteRoomAlertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                     message:alertMsg
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    [deleteRoomAlertView show];
    
    
}



-(void)addItemBtnClicked:(id)sender{
    UIButton *addItemBtnForRoom = (UIButton *)sender;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[roomsArray objectAtIndex:addItemBtnForRoom.tag] forKey:@"RoomDetails"];
    [standardUserDefaults synchronize];
    
    AddItemViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
    vc.itemID=@"";
    
    NSString *tempRoomID =[[roomsArray objectAtIndex:addItemBtnForRoom.tag]valueForKey:@"ID"];
    vc.roomID =tempRoomID;
    currentSelectedRoomID = tempRoomID;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults synchronize];
    //    [defaults setObject:@"" forKey:@"viewType"];
    
    NSLog(@"scrollview call");
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)recognizer{
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    UIButton *selectedItemID = (UIButton *)[recognizer view];
    
    [addHouseSubView removeFromSuperview];
    [addRoomSubView removeFromSuperview];
    
    AddItemViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
    vc.itemID =[NSString stringWithFormat:@"%ld",(long)selectedItemID.tag];
    vc.roomID =[NSString stringWithFormat:@"%ld",(long)selectedItemID.superview.tag];
    
    currentSelectedRoomID =[NSString stringWithFormat:@"%ld",(long)selectedItemID.superview.tag];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//-(void)itemBtnClicked:(id)sender{
-(void)itemBtnClicked:(UITapGestureRecognizer *)recognizer{
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    
    NSLog(@"itemImagesArray %@",itemImagesArray);
    UIButton *selectedItemID = (UIButton *)[recognizer view];
    NSString *localImgPath;
    
    for (int i=0; i<[itemImagesArray count]; i++) {
        NSDictionary *temp = [itemImagesArray objectAtIndex:i];
        NSString *itemIDStr = [temp objectForKey:@"ItemID"];
        if ([itemIDStr isEqualToString:[NSString stringWithFormat:@"%ld",(long)selectedItemID.tag]]) {
            localImgPath = [temp objectForKey:@"LocalImgPath"];
            break;
        }
    }
    
    itemImageButton =selectedItemID;
    
    
    NSFileManager *filemanager=[NSFileManager defaultManager];
    
    BOOL fileExists = [filemanager fileExistsAtPath:localImgPath];
    
    
    if (fileExists == NO) {
    }else{
        [self showItemImage:localImgPath];
    }
    //
    //    AddItemViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
    //    vc.itemID =[NSString stringWithFormat:@"%ld",(long)selectedItemID.tag];
    //    vc.roomID =[NSString stringWithFormat:@"%ld",(long)selectedItemID.superview.tag];
    //
    //    currentSelectedRoomID =[NSString stringWithFormat:@"%ld",(long)selectedItemID.superview.tag];
    //
    //    [self.navigationController pushViewController:vc animated:YES];
}




- (void) showItemImage:(NSString *)path{
    
    [addHouseSubView removeFromSuperview];
    [addRoomSubView removeFromSuperview];
    
    UIViewController* popoverContent = [[UIViewController alloc]init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    if (path.length !=0) {
        itemImageView.image = [UIImage imageWithContentsOfFile:path];
    }
    
    itemImageView.layer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"frame.png"]] CGColor];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] init];
    [swipeLeft addTarget:itemImageView action:@selector(handleSwipe:)];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] init];
    [swipeRight addTarget:itemImageView action:@selector(handleSwipe:)];
    
    
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [itemImageView addGestureRecognizer:swipeLeft];
    [itemImageView addGestureRecognizer:swipeRight];
    
    
    
    
    [popoverView addSubview:itemImageView];
    popoverContent.view = popoverView;
    
    popoverContent.preferredContentSize = CGSizeMake(600, 600);
    if ([self.itemImagePopOver isPopoverVisible]) {
        [self.itemImagePopOver dismissPopoverAnimated:YES];
    }
    self.itemImagePopOver = [[UIPopoverController alloc]
                             initWithContentViewController:popoverContent];
    self.itemImagePopOver.delegate =self;
    
    [self.itemImagePopOver  presentPopoverFromRect:CGRectMake(0, 0, 133, 29)
                                            inView:itemImageButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //    loading.hidden = YES;
    
    
}

//-(IBAction)globalSyncButtonClick:(id)sender{
//    webServiceUtils = [[WebServiceUtils alloc]initWithVC:self];
//    webServiceUtils.delegate =self;
//    [webServiceUtils postRequest:SYNC_HOUSE_TYPE withHouseID:nil];
//}

-(IBAction)houseSyncButtonClick:(id)sender{
    
    //    [self showSimple:nil];
    
    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
    [tempDefaults synchronize];
    [tempDefaults setObject:@"" forKey:@"viewType"];
    
    [addHouseSubView removeFromSuperview];
    [addRoomSubView removeFromSuperview];
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [photoSheet dismissWithClickedButtonIndex:0 animated:YES];
    [photoPopOver dismissPopoverAnimated:YES];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *tempText = @"YES";
    [defaults setObject:tempText forKey:@"MakeTextFieldEmpty"];
    [defaults setObject:@"0" forKey:@"Searching"];
    [defaults setObject:@"" forKey:@"SearchValue"];
    
    isSearcingItem = @"0";
    itemSearchedString = @"";
    
    
    NSLog(@"house sync button clicked");
    [self.view endEditing:YES];
    UIButton *currentBtn = (UIButton*)sender;
    
    if (currentBtn == globalSyncBtn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:@"ID"];
        [defaults synchronize];
        houseIdStr = @"";
    }
    
    NSMutableArray *houseNameDetails = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT Name FROM House Where ID = '%@'",houseIdStr] resultsArray:houseNameDetails];
    if(houseNameDetails.count >0){
        NSDictionary *houseDict = [houseNameDetails objectAtIndex:0];
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setObject:[houseDict valueForKey:@"Name"] forKey:@"HouseName"];
        [standardDefaults synchronize];
    }
    
    webServiceUtils = [[WebServiceUtils alloc]initWithVC:self];
    webServiceUtils.delegate =self;
    //    [webServiceUtils postRequest:SYNC_HOUSE_TYPE];
    [webServiceUtils postRequest:SYNC_HOUSE_TYPE withHouseID:houseIdStr];
    
    //        [self hideSimple:nil];
}

-(void)getStatus:(NSDictionary *)status{
    NSLog(@"Status %@",status);
    [self viewDidLoad];
    [addHouseSubView removeFromSuperview];
    [addRoomSubView removeFromSuperview];
    if ([[status objectForKey:@"Room"] isEqualToString:@"Complete"]) {
        [self drawAttchmentsView];
        [self setupScrollView];
    }
    if ([[status objectForKey:@"Item"] isEqualToString:@"Complete"]) {
        if (isItemPdfClicked == YES) {
            [self viewPdfBtnClicked:itemPdfClickedBtn];
        }
    }
}


- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    [deleteHouseImgBtn removeFromSuperview];
    [deleteItemBtn removeFromSuperview];
    [emailItemBtn removeFromSuperview];
    [viewPdfItemButton removeFromSuperview];
    isEditItemPopOverPresent = NO;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    isEditItemPopOverPresent = NO;
    
    return YES;
}

//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
//
//}



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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_View_1024x1024.png"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbarpotrait.png"] forBarMetrics:UIBarMetricsDefault];
        //        pdfWebView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
        
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
        //        pdfWebView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
        
    }
    [pdfcontroller dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)showSimple:(id)sender {
    
    //    AddItemViewController *currentVC = (AddItemViewController *)sender;
    
    
	// The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(loading) onTarget:self withObject:nil animated:YES];
}

- (void)hideSimple:(id)sender {
    [HUD removeFromSuperview];
}

-(void)loading{
    sleep(30);
}

//- (void)myTask {
// Do something usefull in here instead of sleeping ...
//    BOOL val = [self drawAttchmentsView];
//    if (val == YES) {
//        [self hideSimple:nil];
//    }
//	sleep(30);
//}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //    [self showSimple:nil];
    tapTimer = nil;

    [tapTimer invalidate];
    [self setupScrollView];
    [self drawAttchmentsView];
    //    if (UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)) {
    //        pdfWebView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
    //    }
    //    else {
    //        pdfWebView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
    //    }
    [pdfcontroller dismissViewControllerAnimated:YES completion:nil];
    //Divya
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [photoSheet dismissWithClickedButtonIndex:0 animated:YES];
    [photoPopOver dismissPopoverAnimated:YES];
    //Divya
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UIView class]])
        {
            if (view.tag == 1000) {
                [self addRoomCancelBtnClicked:nil];
                [self addRoomBtnClicked:nil];
            }else if (view.tag == 1001){
                [self addHouseCancelBtnClicked:nil];
                [self addHouseBtnClicked:nil];
            }
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
