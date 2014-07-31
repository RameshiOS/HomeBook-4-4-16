//
//  AddItemViewController.m
//  RoyalHouseManagement
//
//  Created by Manulogix on 04/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "AddItemViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "ItemUploadsViewController.h"
#import "FAUtilities.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController
@synthesize itemCategoryPopOverController;
@synthesize itemCategoryPicker;
@synthesize itemConditionPopOverController;
@synthesize itemConditionPicker;
@synthesize itemStatusPopOverController;//Divya
@synthesize itemStatusPicker;//Divya@synthesize houseID;
@synthesize roomID;
@synthesize itemID;
@synthesize houseID;
@synthesize itemSaveBtn;
@synthesize categoryCheckedIndexPath;
@synthesize conditionCheckedIndexPath;
@synthesize statusCheckedIndexPath;

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
    //    [self hideSimple:nil];
    deleteItemImgBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
    
    
    itemPropertiesScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    itemDescTextView.delegate =self;
    activeBtnTag = 1;
    itemPropertieView.hidden = YES;
    itemUploadsView.hidden = YES;
    
    //  isInsuredClicked = NO;//Divya
    // isTaxableClicked = NO;//Divya
    menuItemView.layer.cornerRadius = 5;
    menuItemView.backgroundColor =[UIColor colorWithRed:130.0f/255.0f green:91.0f/255.0f blue:48.0f/255.0f alpha:1.0f];
    
    [itemInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    itemInformationView.layer.cornerRadius = 5;
    itemInformationView.layer.borderColor =[[UIColor colorWithRed:130.0f/255.0f green:91.0f/255.0f blue:48.0f/255.0f alpha:1.0f] CGColor];
    itemInformationView.layer.borderWidth =2;
    itemInformationView.tag =1;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cellPanForInfoView:)];
    [itemInformationView addGestureRecognizer:panRecognizer];
    
    itemPropertieView.layer.cornerRadius = 5;
    itemPropertieView.layer.borderColor =[[UIColor colorWithRed:130.0f/255.0f green:91.0f/255.0f blue:48.0f/255.0f alpha:1.0f] CGColor];
    itemPropertieView.layer.borderWidth =2;
    itemPropertieView.tag =2;
    UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cellPanForPropView:)];
    [itemPropertieView addGestureRecognizer:panRecognizer1];
    
    
    itemUploadsView.layer.cornerRadius = 5;
    itemUploadsView.layer.borderColor =[[UIColor colorWithRed:130.0f/255.0f green:91.0f/255.0f blue:48.0f/255.0f alpha:1.0f] CGColor];
    itemUploadsView.layer.borderWidth =2;
    itemUploadsView.tag =3;
    UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cellPanForUploads:)];
    [itemUploadsView addGestureRecognizer:panRecognizer2];
    
    
    itemAdded = NO;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *housedetailsDict = [standardUserDefaults objectForKey:@"HouseDetails"];
    houseName = [housedetailsDict objectForKey:@"Name"];
    houseID = [housedetailsDict objectForKey:@"ID"];
    //    NSDictionary *roomdetailsDict = [standardUserDefaults objectForKey:@"RoomDetails"];
    //    roomName= [roomdetailsDict valueForKey:@"Name"];
    //    roomID = [roomdetailsDict valueForKey:@"ID"];
    
    NSLog(@"Room ID %@", roomID);
    
    NSUserDefaults *roomUserDefaults = [NSUserDefaults standardUserDefaults];
    if (roomUserDefaults) {
        [roomUserDefaults setObject:roomID forKey:@"selectedRoomID"];
        [roomUserDefaults synchronize];
    }
    
    
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *roomNameAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT Name FROM Room Where ID = '%@'",roomID] resultsArray:roomNameAry];
    roomName = [[roomNameAry objectAtIndex:0]valueForKey:@"Name"];
    
    if (itemID.length ==0) {
        NSLog(@"inser item");
        [itemCategoryBtn setTitle:@"Select Category" forState:UIControlStateNormal];//Divya
        [itemConditionBtn setTitle:@"Select Condition" forState:UIControlStateNormal];//Divya
        [itemStatusBtn setTitle:@"Select Status" forState:UIControlStateNormal];//Divya
        isInsuredClicked = NO;//Divya
        isTaxableClicked = NO;//Divya
        isInsuredVal = 0;//Divya
        isTaxableVal = 0;//Divya
    }else{
        [itemSaveBtn setTitle:@"Update" forState:UIControlStateNormal];//Divya
        
        NSMutableArray *editingItemDetails = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Item where ID='%@'",itemID] resultsArray:editingItemDetails];
        
        itemNameTextField.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Name"];
        itemDescTextView.text= [[editingItemDetails objectAtIndex:0]valueForKey:@"Description"];
        itemPurchasedDate.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"DatePurchase"];
        itemInvoiceNum.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"InvoiceNum"];
        itemManufacturer.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Manufacturer"];
        itemCost.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Cost"];
        itemBrand.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Brand"];
        itemModel.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Model"];
        itemQunatity.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Quantity"];
        //  itemStatus.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Status"];//Divya
        itemSize.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Size"];//Divya
        itemYearMade.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"YearMade"];
        itemMaterialMade.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"MaterialMade"];
        itemShape.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Shape"];
        itemColor.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Color"];
        //itemIsInsured.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"IsInsured"];//Divya
        // itemIsTaxable.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"IsTaxable"];//Divya
        itemCurrentValue.text=[[editingItemDetails objectAtIndex:0]valueForKey:@"CurrentValue"];//Divya
        
        NSString *isInsured= [[editingItemDetails objectAtIndex:0]valueForKey:@"IsInsured"];//Divya
        NSString *isTaxable= [[editingItemDetails objectAtIndex:0]valueForKey:@"IsTaxable"];//Divya
        
        int insured = [isInsured intValue];
        int taxable = [isTaxable intValue];
        
        
        if(taxable==1) {//Divya
            isTaxableClicked = YES;
            [isTaxableBtn setSelected:YES];//Divya
        }else if (taxable==0){//Divya
            [isTaxableBtn setSelected:NO];//Divya
            isTaxableClicked = NO;
        }else{
            [isTaxableBtn setSelected:NO];//Divya
            isTaxableClicked = NO;

        }
        
        if (insured==1){//Divya
            [isInsuredBtn setSelected:YES];//Divya
            isInsuredClicked =YES;
        }else if (insured==0) {//Divya
            [isInsuredBtn setSelected:NO];//Divya
            isInsuredClicked =NO;

        }else{
            [isInsuredBtn setSelected:NO];//Divya
            isInsuredClicked =NO;

            
        }// sold information
        
        itemSoldTo.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"SoldTo"];
        itemSoldDate.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"SoldDate"];
        itemSoldPrice.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"SoldPrice"];
        
        // warranty info
        itemWarrantyExpire.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"WarrantyExpire"];
        itemWarrantyInfo.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"WarrantyInfo"];
        
        // insurance info
        itemInsureBy.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"InsuredBy"];
        itemInsurePolicy.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"InsuredPolicy"];
        
        // Lease info
        itemLeaseStartDate.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"LeaseStartDate"];
        itemLeaseEndDate.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"LeaseEndDate"];
        itemLeaseDesc.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"LeaseDesc"];
        
        
        itemReplacementCost.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"ReplacementCost"];
        itemSerialNum.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"SerialNum"];
        itemPlaceInService.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"PlacedInService"];
        
        itemUsePercentage.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"UsePercentage"];
        itemSalvageValue.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"SalvageValue"];
        itemDepreciationMethod.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"DepreciationMethod"];
        
        itemBenificiary.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Beneficiary"];
        itemLifeInYears.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"LifeInYears"];
        
        
        itemComments.text = [[editingItemDetails objectAtIndex:0]valueForKey:@"Comments"];
        
        NSMutableArray *itemCategoryVals = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT Name FROM Item_Category where Category_ID='%@'",[[editingItemDetails objectAtIndex:0]valueForKey:@"Category"]] resultsArray:itemCategoryVals];//Divya
        NSLog(@"itemCategoryVals %@", itemCategoryVals);
        //        itemCategoryBtn.titleLabel.text =[[itemCategoryVals objectAtIndex:0]valueForKey:@"Name"];
        //if(itemCategoryVals.count !=0){//Divya
        if([itemCategoryVals count]>0){//Divya
            [itemCategoryBtn setTitle:[[itemCategoryVals objectAtIndex:0]valueForKey:@"Name"] forState:UIControlStateNormal];
            currentItemCategoryID = [[editingItemDetails objectAtIndex:0]valueForKey:@"Category"];
        }else{
            [itemCategoryBtn setTitle:@"Select Category" forState:UIControlStateNormal];//Divya
        }
        
        
        //Divya
        NSMutableArray *itemStatusVals = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT Status FROM Item_Status where Status_ID='%@'",[[editingItemDetails objectAtIndex:0]valueForKey:@"Status"]] resultsArray:itemStatusVals];//Divya
        NSLog(@"itemStatusVals %@", itemStatusVals);
        if([itemStatusVals count]>0){
            [itemStatusBtn setTitle:[[itemStatusVals objectAtIndex:0]valueForKey:@"Status"] forState:UIControlStateNormal];
            currentItemStatusID = [[editingItemDetails objectAtIndex:0]valueForKey:@"Status"];
        }else{
            [itemStatusBtn setTitle:@"Select Status" forState:UIControlStateNormal];//Divya
        }
        //Divya
        
        NSMutableArray *itemConditionVals = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT Type FROM Item_Condition where Condition_ID='%@'",[[editingItemDetails objectAtIndex:0]valueForKey:@"Condition"]] resultsArray:itemConditionVals];//Divya
        NSLog(@"itemConditionVals %@", itemConditionVals);//Divya
        if([itemConditionVals count]>0){//Divya
            //if(itemConditionVals.count !=0){//Divya
            [itemConditionBtn setTitle:[[itemConditionVals objectAtIndex:0]valueForKey:@"Type"] forState:UIControlStateNormal];
            currentItemConditionID = [[editingItemDetails objectAtIndex:0]valueForKey:@"Condition"];
        }else {
            [itemConditionBtn setTitle:@"Select Condition" forState:UIControlStateNormal];//Divya
        }
        
    }
    
    headingStr = [NSString stringWithFormat:@"%@-%@",houseName,roomName];
    NSLog(@"headingStr:%@",headingStr);
    titleView.text=headingStr;
//    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
//    titleView.backgroundColor = [UIColor clearColor];
//    titleView.font = [UIFont boldSystemFontOfSize:20.0];
//    titleView.textColor = [FAUtilities getUIColorObjectFromHexString:@"#6F4925" alpha:1]; // Your color here
//    titleView.text =headingStr;
//    self.navigationItem.titleView = titleView;
//    [titleView sizeToFit];
    
    itemDescTextView.layer.borderWidth = 2.0f;
    itemDescTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    itemLeaseDesc.layer.borderWidth = 2.0f;
    itemLeaseDesc.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    itemComments.layer.borderWidth = 2.0f;
    itemComments.layer.borderColor = [[UIColor grayColor] CGColor];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        keyboardHeight = 352;
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        keyboardHeight = 264;
    }
    
    //    [itemPropertiesScrollView setContentSize:CGSizeMake(768, 1000)];
    //    [itemPropertiesScrollView setScrollEnabled:YES]; // need to set in viewDidLayoutSubviews
    
	// Do any additional setup after loading the view.
    
    menuUploadPhotosAlertViewFirstTime = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(handleGesture:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); // For Saving in libarary
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
	NSError* error = nil;

    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
    NSString *dataPath;
    
    NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];

        dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
    
    if (CurrentUser_ID) {

        if (![fileManager fileExistsAtPath:dataPath]){
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
        
        dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
    }
    housePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",houseID]];
    if (![fileManager fileExistsAtPath:housePath]){
        [fileManager createDirectoryAtPath:housePath withIntermediateDirectories:NO attributes:nil error:&error];
	}else {
	}
    
    
    roomPath = [housePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",roomID]];
    
    
    
    if (![fileManager fileExistsAtPath:roomPath]){
        [fileManager createDirectoryAtPath:roomPath withIntermediateDirectories:NO attributes:nil error:&error];
	}else {
	}
    
    if (itemID.length !=0) {
        itemPath = [roomPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",itemID]];
        
        if (![fileManager fileExistsAtPath:itemPath]){
            [fileManager createDirectoryAtPath:itemPath withIntermediateDirectories:NO attributes:nil error:&error];
        }else {
        }
    }
    
    
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_View_1024x1024.png"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f]];
    
    //    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:111.0/255.0
    //                                                               green:73.0/255.0 blue:37.0/255.0 alpha:1.0]];
    
//    self.navigationItem.backBarButtonItem.tintColor = [UIColor colorWithRed:111.0/255.0
//                                                                      green:73.0/255.0 blue:37.0/255.0 alpha:1.0];
    
    self.navigationItem.backBarButtonItem.tintColor =[UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:151.0f/255.0f green:127.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
    
    [self.navigationItem.backBarButtonItem setAction:@selector(perform:)];
    
}


- (void)keyboardWasShown:(NSNotification *)aNotification{
    if (currentScrollView == itemPropertiesScrollView) {
        // keyboard frame is in window coordinates
        NSDictionary *userInfo = [aNotification userInfo];
        CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        // get the height of the keyboard by taking into account the orientation of the device too
        CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
        CGRect keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
        coveredFrame = [self.view.window convertRect:keyboardFrame toView:self.view];
        
        // add the keyboard height to the content insets so that the scrollview can be scrolled
        UIEdgeInsets contentInsets = UIEdgeInsetsMake (0.0, 0.0, coveredFrame.size.height, 0.0);
        currentScrollView.contentInset = contentInsets;
        currentScrollView.scrollIndicatorInsets = contentInsets;
        
        // make sure the scrollview content size width and height are greater than 0
        [currentScrollView setContentSize:CGSizeMake (currentScrollView.frame.size.width, currentScrollView.contentSize.height)];
        
        // scroll to the text view
        
        if (activeTextView!=nil) {
            [currentScrollView scrollRectToVisible:activeTextView.superview.frame animated:YES];
        }else{
            [currentScrollView scrollRectToVisible:activeTExtField.superview.frame animated:YES];
        }
        
    }
    
    
}



// Called when the UIKeyboardWillHideNotification is received
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    
    if (currentScrollView == itemPropertiesScrollView) {
        // scroll back..
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        currentScrollView.contentInset = contentInsets;
        currentScrollView.scrollIndicatorInsets = contentInsets;
    }
}


-(void)viewWillAppear:(BOOL)animated{

}



- (void)viewDidLayoutSubviews {
    itemPropertiesScrollView.contentSize = CGSizeMake(itemPropertiesScrollView.frame.size.width, 1050);
}

//Divya
-(IBAction)itemIsInsuredBtnClicked:(id)sender{
    
    if (isInsuredClicked == NO){
		[isInsuredBtn setSelected:YES];
		isInsuredClicked = YES;
        isInsuredVal = 1;
        
	} else {
		[isInsuredBtn setSelected:NO];
		isInsuredClicked = NO;
        isInsuredVal = 0;
        
	}
    NSLog(@"isInsuredClicked Val:%d",isInsuredVal);
}
-(IBAction)itemIsTaxableBtnClicked:(id)sender{
    if (isTaxableClicked == NO){
		[isTaxableBtn setSelected:YES];
		isTaxableClicked = YES;
        isTaxableVal = 1;
        
	} else {
		[isTaxableBtn setSelected:NO];
		isTaxableClicked = NO;
        isTaxableVal = 0;
        
	}
    NSLog(@"isTaxableClicked Val:%d",isTaxableVal);
    
}
//Divya
-(IBAction)itemCategoryBtnClicked:(id)sender{
    [self.view endEditing:YES];
    
    itemCategoryAry = [[NSMutableArray alloc]init];
    
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Item_Category"] resultsArray:itemCategoryAry];
    
    itemCategoryIds = [[NSMutableArray alloc]init];
    itemCategoryNames = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[itemCategoryAry count]; i++) {
        NSDictionary *tempDict = [itemCategoryAry objectAtIndex:i];
        [itemCategoryNames addObject:[tempDict valueForKey:@"Name"]];
        [itemCategoryIds addObject:[tempDict valueForKey:@"Category_ID"]];
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
    
    self.itemCategoryPopOverController = [[UIPopoverController alloc]
                                      initWithContentViewController:popoverContent];
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
 if ([self.itemCategoryPopOverController isPopoverVisible]) {
        [self.itemCategoryPopOverController  dismissPopoverAnimated:YES];
    }
    [self.itemCategoryPopOverController  presentPopoverFromRect:button.bounds
                                                     inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}
//Divya
-(IBAction)itemStatusBtnClicked:(id)sender{
    [self.view endEditing:YES];
    
    itemStatusAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Item_Status"] resultsArray:itemStatusAry];
    
    itemStatusIds = [[NSMutableArray alloc]init];
    itemStatusNames = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[itemStatusAry count]; i++) {
        NSDictionary *tempDict = [itemStatusAry objectAtIndex:i];
        [itemStatusNames addObject:[tempDict valueForKey:@"Status"]];
        [itemStatusIds addObject:[tempDict valueForKey:@"Status_ID"]];
    }
    
    UIButton *button = (UIButton *)sender;
    UIViewController* popoverContent = [[UIViewController alloc]init];
    
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 260)];
    
    UITableView *tblViewRoomTypeMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300, 260)];
    tblViewRoomTypeMenu.delegate = self;
    tblViewRoomTypeMenu.dataSource = self;
    tblViewRoomTypeMenu.rowHeight = 32;
    tblViewRoomTypeMenu.tag = 1003;
    [popoverView addSubview:tblViewRoomTypeMenu];
    popoverContent.view = popoverView;
    popoverContent.preferredContentSize = CGSizeMake( 300, 260);
    
    self.itemStatusPopOverController = [[UIPopoverController alloc]
                                          initWithContentViewController:popoverContent];
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
if ([self.itemStatusPopOverController isPopoverVisible]) {
        [self.itemStatusPopOverController  dismissPopoverAnimated:YES];
    }
    [self.itemStatusPopOverController  presentPopoverFromRect:button.bounds
                                                         inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
//Divya

-(IBAction)itemConditionBtnClicked:(id)sender{
    [self.view endEditing:YES];
    
    itemConditionAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
   
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Item_Condition"] resultsArray:itemConditionAry];
    
    itemConditionIds = [[NSMutableArray alloc]init];
    itemConditionNames = [[NSMutableArray alloc]init];
    
    
    for (int i=0; i<[itemConditionAry count]; i++) {
        NSDictionary *tempDict = [itemConditionAry objectAtIndex:i];
        [itemConditionNames addObject:[tempDict valueForKey:@"Type"]];
        [itemConditionIds addObject:[tempDict valueForKey:@"Condition_ID"]];
    }
     UIButton *button = (UIButton *)sender;
    UIViewController* popoverContent = [[UIViewController alloc]init];
    
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 260)];
    
    UITableView *tblViewRoomTypeMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300, 260)];
    tblViewRoomTypeMenu.delegate = self;
    tblViewRoomTypeMenu.dataSource = self;
    tblViewRoomTypeMenu.rowHeight = 32;
    tblViewRoomTypeMenu.tag = 1002;
    [popoverView addSubview:tblViewRoomTypeMenu];
    popoverContent.view = popoverView;
    popoverContent.preferredContentSize = CGSizeMake( 300, 260);
    
    self.itemConditionPopOverController = [[UIPopoverController alloc]
                                        initWithContentViewController:popoverContent];
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
 if ([self.itemConditionPopOverController isPopoverVisible]) {
        [self.itemConditionPopOverController  dismissPopoverAnimated:YES];
    }
    
    [self.itemConditionPopOverController  presentPopoverFromRect:button.bounds
                                                       inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag ==1001) {
        return [itemCategoryNames count];
    }else if (tableView.tag ==1002) {
        return [itemConditionNames count];
    }else if (tableView.tag ==1003) {
        return [itemStatusNames count];
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView.tag ==1001) {
        
            NSArray* sortedArray = [itemCategoryNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];//Divya
            NSLog(@"itemCategoryNames sorted Array:%@",sortedArray);//Divya
            cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];//Divya
        
        
        
            //do you stuff here
            if([self.categoryCheckedIndexPath isEqual:indexPath])
            {
                
                if ([itemCategoryBtn.titleLabel.text isEqualToString:@"Select Category"]) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [itemCategoryBtn setTitle:cell.textLabel.text  forState:UIControlStateNormal];
                    
                }
                
                
                
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        
    }else if (tableView.tag ==1002) {
        NSArray* sortedArray = [itemConditionNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];//Divya
        NSLog(@"itemConditionNames sorted Array:%@",sortedArray);//Divya
        cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];//Divya
        
        //do you stuff here
        if([self.conditionCheckedIndexPath isEqual:indexPath])
        {
            if ([itemConditionBtn.titleLabel.text isEqualToString:@"Select Condition"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [itemConditionBtn setTitle:cell.textLabel.text  forState:UIControlStateNormal];
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }


    }else if (tableView.tag ==1003) {
        NSArray* sortedArray = [itemStatusNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"itemStatusNames sorted Array:%@",sortedArray);
        cell.textLabel.text  = [sortedArray objectAtIndex:indexPath.row];
        
        //do you stuff here
        if([self.statusCheckedIndexPath isEqual:indexPath])
        {
            if ([itemStatusBtn.titleLabel.text isEqualToString:@"Select Status"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [itemStatusBtn setTitle:cell.textLabel.text  forState:UIControlStateNormal];
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag==1001){
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *cellLabelText = cell.textLabel.text;
        
        NSArray* sortedArray = [itemCategoryNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"itemCategoryNames sorted Array:%@",sortedArray);
        NSMutableArray *catTypeArray = [[NSMutableArray alloc]init];
        
        
        //do work for checkmark
        if(self.categoryCheckedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView
                                            cellForRowAtIndexPath:self.categoryCheckedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if([self.categoryCheckedIndexPath isEqual:indexPath])
        {
            self.categoryCheckedIndexPath = nil;
            cellLabelText = @"";//Divya
            
        }
        else
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.categoryCheckedIndexPath = indexPath;
            cellLabelText = [sortedArray objectAtIndex:indexPath.row];//Divya
        }
        
        
        NSString *typeVal;
        
        if (cellLabelText.length!=0) {
            NSLog(@"%ld category Row ", (long)indexPath.row);
            
            [itemCategoryBtn setTitle:cellLabelText forState:UIControlStateNormal];
            [dbManager execute:[NSString stringWithFormat: @"Select Category_ID FROM Item_Category where Name='%@'",cellLabelText] resultsArray:catTypeArray];
            NSLog(@"categoryTypeArray %@", catTypeArray);
            if (catTypeArray.count >0) {
                NSDictionary *tempDict = [[NSDictionary alloc]init];
                tempDict = [catTypeArray objectAtIndex:0];
                typeVal= [tempDict objectForKey:@"Category_ID"];
            }
            
            NSLog(@"%@ category typeVal ", typeVal);
            
            if (typeVal.length >0) {
                currentItemCategoryID = typeVal;
            }
        }else {
            [itemCategoryBtn setTitle:@"Select Category" forState:UIControlStateNormal];
            currentItemCategoryID = @"";
        }
        
        NSLog(@"%@ category cell text ", cellLabelText);
        NSLog(@"%@ currentItemCategoryID ", currentItemCategoryID);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.itemCategoryPopOverController dismissPopoverAnimated:YES];
        
    }
    else if (tableView.tag==1002){
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *cellLabelText = cell.textLabel.text;
        
        NSArray* sortedArray = [itemConditionNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"itemConditionNames sorted Array:%@",sortedArray);
        NSMutableArray *conditionTypeArray = [[NSMutableArray alloc]init];
        
        //do work for checkmark
        if(self.conditionCheckedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView
                                            cellForRowAtIndexPath:self.conditionCheckedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if([self.conditionCheckedIndexPath isEqual:indexPath])
        {
            self.conditionCheckedIndexPath = nil;
            cellLabelText = @"";//Divya
            
        }
        else
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.conditionCheckedIndexPath = indexPath;
            cellLabelText = [sortedArray objectAtIndex:indexPath.row];//Divya
        }
        
        
        if (cellLabelText.length!=0) {
            NSLog(@"%ld condition Row ", (long)indexPath.row);
            NSLog(@"conditionTypeArray %@", conditionTypeArray);
            NSString *typeVal;
            
            [itemConditionBtn setTitle:cellLabelText forState:UIControlStateNormal];
            [dbManager execute:[NSString stringWithFormat: @"Select Condition_ID FROM Item_Condition where Type='%@'",cellLabelText] resultsArray:conditionTypeArray];

            if (conditionTypeArray.count >0) {
                NSDictionary *tempDict = [[NSDictionary alloc]init];
                tempDict = [conditionTypeArray objectAtIndex:0];
                typeVal= [tempDict objectForKey:@"Condition_ID"];
            }
            NSLog(@"%@ condition typeVal ", typeVal);
            
            if (typeVal.length >0) {
                currentItemConditionID = typeVal;
            }
        }else {
            [itemConditionBtn setTitle:@"Select Condition" forState:UIControlStateNormal];
            currentItemConditionID = @"";
        }
        
        NSLog(@"%@ condition cell text ", cellLabelText);
        NSLog(@"%@ currentItemConditionID ", currentItemConditionID);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.itemConditionPopOverController dismissPopoverAnimated:YES];
        
    }else if (tableView.tag==1003){
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *cellLabelText = cell.textLabel.text;
        
        
        NSArray* sortedArray = [itemStatusNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"itemStatusNames sorted Array:%@",sortedArray);
        NSMutableArray *statusTypeArray = [[NSMutableArray alloc]init];


        
        
        //do work for checkmark
        if(self.statusCheckedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView
                                            cellForRowAtIndexPath:self.statusCheckedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if([self.statusCheckedIndexPath isEqual:indexPath])
        {
            self.statusCheckedIndexPath = nil;
            cellLabelText = @"";//Divya
            
        }
        else
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.statusCheckedIndexPath = indexPath;
            cellLabelText = [sortedArray objectAtIndex:indexPath.row];//Divya
        }
        
        
        if (cellLabelText.length!=0) {
            NSLog(@"%ld condition Row ", (long)indexPath.row);
            NSLog(@"statusTypeArray %@", statusTypeArray);
            NSString *typeVal;
            
            [itemStatusBtn setTitle:cellLabelText forState:UIControlStateNormal];
            [dbManager execute:[NSString stringWithFormat: @"Select Status_ID FROM Item_Status where Status='%@'",cellLabelText] resultsArray:statusTypeArray];
            
            if (statusTypeArray.count >0) {
                NSDictionary *tempDict = [[NSDictionary alloc]init];
                tempDict = [statusTypeArray objectAtIndex:0];
                typeVal= [tempDict objectForKey:@"Status_ID"];
            }
            NSLog(@"%@ status typeVal ", typeVal);
            
            if (typeVal.length >0) {
                currentItemStatusID = typeVal;
            }
        }else {
            [itemStatusBtn setTitle:@"Select Status" forState:UIControlStateNormal];
            currentItemStatusID = @"";
        }
        
        NSLog(@"%@ status cell text ", cellLabelText);
        NSLog(@"%@ currentItemStatusID ", currentItemStatusID);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.itemStatusPopOverController dismissPopoverAnimated:YES];
       
    }

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    activeTextView = textView;
    currentScrollView = (UIScrollView*)textView.superview;
    currentScrollView.alwaysBounceHorizontal = NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    activeTextView = nil;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    currentScrollView = (UIScrollView*)textField.superview;
    
    if (textField==itemYearMade ||textField==itemShape ||textField==itemMaterialMade ||textField==itemColor ||textField==itemCurrentValue ||textField==itemSize) {
        activeTExtField =nil;
        currentScrollView.alwaysBounceHorizontal = NO;
        if (currentScrollView == itemInfoScrollView) {
            [self scrollToControl:nil];
        }
        
    }else{
        activeTExtField = textField;
        NSLog(@"text field %@", textField);
        currentScrollView.alwaysBounceHorizontal = NO;
        
        if (currentScrollView == itemInfoScrollView) {
            [self scrollToControl:textField];
        }
    }
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    return YES;
//}

//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    activeTExtField =nil;
//    currentScrollView = (UIScrollView*)textField.superview;
//    currentScrollView.alwaysBounceHorizontal = NO;
//    if (currentScrollView == itemInfoScrollView) {
//        [self scrollToControl:nil];
//    }
//    if (textField == itemPurchasedDate || textField == itemSoldDate || textField == itemWarrantyExpire || textField == itemLeaseStartDate || textField == itemLeaseEndDate) {
//        
//        if (textField.text.length ==0) {
//            
//        }else{
//            BOOL isValidDate = [self getDateFromString:textField.text];
//            if (isValidDate == NO) {
//                textField.text = @"";
//                NSLog(@"valid date no");
//            }else{
//                NSLog(@"valid date");
//            }
//        }
//    }
//    
//    if (textField == itemYearMade) {
//        
//        if (textField.text.length ==0) {
//            
//        }else{
//            BOOL isValidDate = [self getYearFromString:textField.text];
//            if (isValidDate == NO) {
//                textField.text = @"";
//                NSLog(@"valid year no");
//            }else{
//                NSLog(@"valid year");
//            }
//        }
//    }
//    
//    
//    if (textField == itemCost || textField == itemSoldPrice|| textField == itemReplacementCost||textField==itemCurrentValue) {
//        NSString *regEx = @"0123456789";
//        NSRange r = [textField.text rangeOfString:regEx options:NSRegularExpressionSearch];
//        
//        if (r.location == NSNotFound) {
//            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[.]"
//                                                                                        options:0
//                                                                                          error:NULL];
//            NSString *cleanedString = [expression stringByReplacingMatchesInString:textField.text
//                                                                           options:0
//                                                                             range:NSMakeRange(0, textField.text.length)
//                                                                      withTemplate:@""];
//            NSLog(@"cleaned = %s",[cleanedString UTF8String] );
//            if (cleanedString.length!=0) {
//                textField.text = [NSString stringWithFormat:@"%@.00",cleanedString];
//            }
//        }
//    }
//    if (textField ==itemUsePercentage) {
//        NSString *regEx = @"0123456789";
//        NSRange r = [textField.text rangeOfString:regEx options:NSRegularExpressionSearch];
//        
//        if (r.location == NSNotFound) {
//            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[%]"
//                                                                                        options:0
//                                                                                          error:NULL];
//            NSString *cleanedString = [expression stringByReplacingMatchesInString:textField.text
//                                                                           options:0
//                                                                             range:NSMakeRange(0, textField.text.length)
//                                                                      withTemplate:@""];
//            NSLog(@"cleaned = %s",[cleanedString UTF8String] );
//            if (cleanedString.length!=0) {
//                textField.text = [NSString stringWithFormat:@"%@%@",cleanedString,@"%"];
//            }
//        }
//    }
//    
//}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    activeTExtField =nil;
    currentScrollView = (UIScrollView*)textField.superview;
    currentScrollView.alwaysBounceHorizontal = NO;
    if (currentScrollView == itemInfoScrollView) {
        [self scrollToControl:nil];
    }
    if (textField == itemPurchasedDate || textField == itemSoldDate || textField == itemWarrantyExpire || textField == itemLeaseStartDate || textField == itemLeaseEndDate) {
        
        if (textField.text.length ==0) {
            
        }else{
            BOOL isValidDate = [self getDateFromString:textField.text];
            if (isValidDate == NO) {
                textField.text = @"";
                NSLog(@"valid date no");
            }else{
                NSLog(@"valid date");
            }
        }
    }
    
    if (textField == itemYearMade) {
        
        if (textField.text.length ==0) {
            
        }else{
            BOOL isValidDate = [self getYearFromString:textField.text];
            if (isValidDate == NO) {
                textField.text = @"";
                NSLog(@"valid year no");
            }else{
                NSLog(@"valid year");
            }
        }
    }
    
    
    if (textField == itemCost || textField == itemSoldPrice|| textField == itemReplacementCost||textField==itemCurrentValue) {
        NSString *regEx = @"0123456789";
        NSRange r = [textField.text rangeOfString:regEx options:NSRegularExpressionSearch];
        
        if (r.location == NSNotFound) {
            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[.]"
                                                                                        options:0
                                                                                          error:NULL];
            NSString *cleanedString = [expression stringByReplacingMatchesInString:textField.text
                                                                           options:0
                                                                             range:NSMakeRange(0, textField.text.length)
                                                                      withTemplate:@""];
            NSLog(@"cleaned = %s",[cleanedString UTF8String] );
            if (cleanedString.length!=0) {
                
                NSRange range = [textField.text rangeOfString:@"."];
                NSLog(@"range:%lu",(unsigned long)range.location);
                
                if (range.length>0) {
                    NSRange searchRange = NSMakeRange(0, [textField.text length]);
                    searchRange = NSMakeRange(range.location, [textField.text length] - range.location);
                    
                    if((searchRange.length-1)<=2){
                        NSLog(@"2 characters after decimal");
                        
                    }else{
                        NSLog(@"greater than 2 characters after decimal");
                        return;
                    }
                }else{
                    textField.text = [NSString stringWithFormat:@"%@.00",cleanedString];
                }
            }
        }
    }
    if (textField ==itemUsePercentage) {
        NSString *regEx = @"0123456789";
        NSRange r = [textField.text rangeOfString:regEx options:NSRegularExpressionSearch];
        
        if (r.location == NSNotFound) {
            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[%]"
                                                                                        options:0
                                                                                          error:NULL];
            NSString *cleanedString = [expression stringByReplacingMatchesInString:textField.text
                                                                           options:0
                                                                             range:NSMakeRange(0, textField.text.length)
                                                                      withTemplate:@""];
            NSLog(@"cleaned = %s",[cleanedString UTF8String] );
            
            if (cleanedString.length!=0) {
                if ([cleanedString intValue] >100) {
                    [FAUtilities showAlertMessage:@"Percentage value is greater than 100"];
                    textField.text =@"";
                }else{
                    textField.text = [NSString stringWithFormat:@"%@%@",cleanedString,@"%"];
                }
            }
        }
    }
    
}



-(BOOL)getYearFromString:(NSString *)string
{
    NSString *dateStr = [NSString stringWithFormat: @"%@",string];
    
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"YYYY"];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *currentYearString = [formatter stringFromDate:[NSDate date]];
    
    int pastYear = [currentYearString integerValue]-100;
    int futureYear = [currentYearString integerValue]+1;
    
    NSLog(@"Current Year:%d",pastYear);
    NSLog(@"Future Year:%d",futureYear);
    
    
    NSString *startDateStr = [NSString stringWithFormat: @"%d",pastYear];
    NSString *endDateStr = [NSString stringWithFormat: @"%d",futureYear];
    NSDate *startDate = [formate dateFromString:startDateStr];
    NSDate *endDate = [formate dateFromString:endDateStr];
    NSDate *currentDate = [formate dateFromString:dateStr];
    
    
    NSComparisonResult result1,result2;
    //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
    
    result1 = [currentDate compare:startDate]; // comparing two dates
    result2 = [currentDate compare:endDate]; // comparing two dates
    
    if(result2==NSOrderedAscending && result1==NSOrderedDescending)
    {
        NSLog(@"Between the Startyear and Endyear");
    }else{
        [FAUtilities showAlert:YEAR_INVALID];
        return NO;
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    int newLength = [textField.text length] + [string length] - range.length;
    NSLog(@"length %d",newLength);
    
    if (newLength == 1) {
        //        NSCharacterSet * invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"\_!@#$%^&*()[]{}'\".,<>:;|-/?+=\t~` € $ £ ¥ ₩"];
        string = [string uppercaseString];
        
        if (textField ==itemQunatity||textField ==itemLifeInYears||textField ==itemSize||textField ==itemSoldPrice||textField ==itemReplacementCost||textField ==itemCurrentValue||textField ==itemUsePercentage||textField ==itemCost||textField == itemPurchasedDate || textField == itemSoldDate || textField == itemWarrantyExpire || textField == itemLeaseStartDate || textField == itemLeaseEndDate||textField == itemYearMade) {//numeric
            NSCharacterSet * invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\"-_£$&?!\'%¥€@#^*()[]{},<>:;|+=~/"];
            
            NSRange r = [string rangeOfCharacterFromSet:invalidNumberSet];
            if (r.location != NSNotFound) {
                NSLog(@"the string contains illegal characters");
                return NO;
            }
        }
        
        if (textField ==itemShape||textField ==itemColor||textField ==itemMaterialMade) {//alpha
            NSCharacterSet * invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            
            NSRange r = [string rangeOfCharacterFromSet:invalidNumberSet];
            if (r.location != NSNotFound) {
                NSLog(@"the string contains numeric illegal characters");
                return NO;
            }else{
                return YES;
            }
            
        }
        
        
        if ([string isEqualToString:@" "]||[string isEqualToString:@"_"]||[string isEqualToString:@"!"]||[string isEqualToString:@"@"]||[string isEqualToString:@"#"]||[string isEqualToString:@"$"]||[string isEqualToString:@"%"]||[string isEqualToString:@"^"]||[string isEqualToString:@"&"]||[string isEqualToString:@"*"]||[string isEqualToString:@"("]||[string isEqualToString:@")"]||[string isEqualToString:@"["]||[string isEqualToString:@"]"]||[string isEqualToString:@"{"]||[string isEqualToString:@"}"]||[string isEqualToString:@"'"]||[string isEqualToString:@"."]||[string isEqualToString:@","]||[string isEqualToString:@"<"]||[string isEqualToString:@">"]||[string isEqualToString:@":"]||[string isEqualToString:@";"]||[string isEqualToString:@"|"]||[string isEqualToString:@"\\"]||[string isEqualToString:@"?"]||[string isEqualToString:@"+"]||[string isEqualToString:@"="]||[string isEqualToString:@"~"]||[string isEqualToString:@"-"]||[string isEqualToString:@"/"]||[string isEqualToString:@"€"]||[string isEqualToString:@"£"]||[string isEqualToString:@"¥"]||[string isEqualToString:@"₩"]||[string isEqualToString:@"₹"]) {
            return NO;
        }else{
            return YES;
        }
    }
    
    
    if (textField == itemPurchasedDate || textField == itemSoldDate || textField == itemWarrantyExpire || textField == itemLeaseStartDate || textField == itemLeaseEndDate) {//Numeric & /
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789/"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (filtered) {
            return [string isEqualToString:filtered];
        }
    }
    else if (textField == itemQunatity || textField == itemLifeInYears||textField == itemUsePercentage||textField==itemYearMade){//Numeric
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (filtered) {
            return [string isEqualToString:filtered];

        }
    }
    else if (textField == itemCost || textField == itemSoldPrice|| textField == itemReplacementCost||textField==itemCurrentValue) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        NSLog(@"filtered %@", filtered);
        
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
        
        
        
        //        if (textField.text.length!=0) {
        //
        //            NSRange rangePrice = [textField.text rangeOfString:@"."];
        //            NSLog(@"range:%c",rangePrice.location);
        //
        //            if (rangePrice.length>0) {
        //                NSRange searchRange = NSMakeRange(0, [textField.text length]);
        //                searchRange = NSMakeRange(rangePrice.location, [textField.text length] - rangePrice.location);
        //
        //                NSLog(@"range length:%d",range.length);
        //
        //                if((searchRange.length-range.length)<=2){
        //                    NSLog(@"2 characters after decimal");
        //                    return [string isEqualToString:filtered];
        //                }else{
        //                    NSLog(@"greater than 2 characters after decimal");
        //                    return NO;
        //                }
        //            }
        //        }
        
    }
    else if (textField == itemModel||textField==itemSerialNum||textField==itemInsurePolicy|| textField == itemSize || textField==itemWarrantyInfo){//Alphanumeric
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (filtered) {
            return [string isEqualToString:filtered];
        }
    }else if (textField==itemInvoiceNum){//Alphanumeric with special chars
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-_. "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (filtered) {
            return [string isEqualToString:filtered];
        }else{
            return NO;
        }
    }
    else if (textField==itemMaterialMade||textField==itemShape||textField==itemColor){//Alpha
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (filtered) {
            return [string isEqualToString:filtered];
        }
    }
    else if (textField==itemNameTextField||textField==itemInsureBy||textField==itemManufacturer||textField==itemBrand||textField==itemMaterialMade||itemSoldTo){
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-'_ "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (filtered) {
            return [string isEqualToString:filtered];
        }
    }
    return YES;
}


//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
//    
//    int newLength = [textField.text length] + [string length] - range.length;
//    NSLog(@"length %d",newLength);
//    
//    if (newLength == 1) {
//        //        NSCharacterSet * invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"\_!@#$%^&*()[]{}'\".,<>:;|-/?+=\t~` € $ £ ¥ ₩"];
//        string = [string uppercaseString];
//        
//        if (textField == itemNameTextField ||textField == itemQunatity||textField == itemLifeInYears||textField == itemSize||textField == itemSoldPrice||textField == itemReplacementCost||textField == itemCurrentValue||textField == itemUsePercentage||textField == itemYearMade) {
//            NSCharacterSet * invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
//            NSRange r = [string rangeOfCharacterFromSet:invalidNumberSet];
//            if (r.location != NSNotFound) {
//                NSLog(@"the string contains illegal characters");
//                return NO;
//            }
//        }
//
//        
//        if ([string isEqualToString:@" "]||[string isEqualToString:@"_"]||[string isEqualToString:@"!"]||[string isEqualToString:@"@"]||[string isEqualToString:@"#"]||[string isEqualToString:@"$"]||[string isEqualToString:@"%"]||[string isEqualToString:@"^"]||[string isEqualToString:@"&"]||[string isEqualToString:@"*"]||[string isEqualToString:@"("]||[string isEqualToString:@")"]||[string isEqualToString:@"["]||[string isEqualToString:@"]"]||[string isEqualToString:@"{"]||[string isEqualToString:@"}"]||[string isEqualToString:@"'"]||[string isEqualToString:@"."]||[string isEqualToString:@","]||[string isEqualToString:@"<"]||[string isEqualToString:@">"]||[string isEqualToString:@":"]||[string isEqualToString:@";"]||[string isEqualToString:@"|"]||[string isEqualToString:@"\\"]||[string isEqualToString:@"?"]||[string isEqualToString:@"+"]||[string isEqualToString:@"="]||[string isEqualToString:@"~"]||[string isEqualToString:@"`"]||[string isEqualToString:@" "]||[string isEqualToString:@"-"]||[string isEqualToString:@"/"]||[string isEqualToString:@"€"]||[string isEqualToString:@"£"]||[string isEqualToString:@"¥"]||[string isEqualToString:@"₩"]) {
//            return NO;
//        }else{
//            return YES;
//        }
//    }
//    
//    
//    if (textField == itemPurchasedDate || textField == itemSoldDate || textField == itemWarrantyExpire || textField == itemLeaseStartDate || textField == itemLeaseEndDate) {//Numeric & /
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789/"] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        return [string isEqualToString:filtered];
//    }
//    
//    else if (textField == itemQunatity || textField == itemLifeInYears|| textField == itemSize){//Numeric
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        return [string isEqualToString:filtered];
//    }
//    else if (textField == itemCost || textField == itemSoldPrice|| textField == itemReplacementCost||textField==itemCurrentValue){
//        
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        return [string isEqualToString:filtered];
//
////        NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
////        if (range.length > 0 && [string length] == 0) {
////            return YES;
////        }
////        
////        NSString *symbol = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
////        if (range.location == 0 && [string isEqualToString:symbol]) {
////            // decimalseparator should not be first
////            return NO;
////        }
////        NSRange separatorRange = [textField.text rangeOfString:symbol];
////        if (separatorRange.location == NSNotFound) {
////        }else {
////            // allow 2 characters after the decimal separator
////            if (range.location > (separatorRange.location + 2)) {
////                return NO;
////            }
////            characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
////        }
////        return ([[string stringByTrimmingCharactersInSet:characterSet] length] > 0);
//    }
//    else if (textField == itemModel||textField==itemInvoiceNum||textField==itemSerialNum){//Alphanumeric
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        return [string isEqualToString:filtered];
//    }
//    
//    else if (textField == itemUsePercentage){//Numeric & %@
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        int maxLength = 3;
//        if (maxLength==0){//100 i.e 3 digits is max
//        }else{
//            if (newLength > maxLength) {//accessing max characters in textfield
//                newLength=3;
//                if ([textField.text intValue] >100) {
//                    [FAUtilities showAlertMessage:@"Percentage value is greater than 100"];
//                    textField.text =@"";
//                }
//            }else {
//                return [string isEqualToString:filtered];
//            }
//        }
//        
//        
//        
////        NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789%"] invertedSet];
////        NSString *filtered = [[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
////        int maxLength = 4;
////        if (maxLength==0){//100 i.e 3 digits is max
////        }else{
//////            NSString *percentageStr=[textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
//////            if (percentageStr.length==3) {
//////                int percentageVal =[percentageStr integerValue];
//////                if (percentageVal >100) {
//////                    [FAUtilities showAlertMessage:@"Percentage value is greater than 100"];
//////                    textField.text =@"";
//////                }else{
//////                    [textField resignFirstResponder];
//////                }
//////            }
////            
////            if (newLength > maxLength) {//accessing max characters in textfield
////                newLength=3;
////                int percentageVal =[[textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""] integerValue];
////                if (percentageVal >100) {
////                    [FAUtilities showAlertMessage:@"Percentage value is greater than 100"];
////                    textField.text =@"";
////                }else{
////                    [textField resignFirstResponder];
////                }
////            }else {
////                if ([textField.text rangeOfString:@"%"].location != NSNotFound){
////                        return [string isEqualToString:filtered];
////                }else{
////                    if (newLength<=3) {
////                        if ([textField.text rangeOfString:@"%"].location != NSNotFound){
////                                return NO;
////                        }else{
////                            return [string isEqualToString:filtered];
////                        }
////                    }
////                    else{
////                        if ([textField.text rangeOfString:@"%"].location != NSNotFound){
////                            return NO;
////                        }else{
////                                return [string isEqualToString:filtered];
////                        }
////                    }
////                }
////            }
////        }
//    }
//    if (textField == itemNameTextField) {
//        if ([string isEqualToString:@""]) {
//            NSLog(@"back space");
//        }else{
//            NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"] invertedSet];
//            NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
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
//                        return [string isEqualToString:filtered];
//                    }
//                }
//            }
//        }
//    }
//    
//
//    if (textField == itemYearMade) {
//        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        int maxLength = 4;
//        if (maxLength==0){//2014 is max
//        }else{
//            if (newLength > maxLength) {//accessing max characters in textfield
//                [textField resignFirstResponder];
//            }else {
//                return [string isEqualToString:filtered];
//            }
//            
//        }
//    }
//    return YES;
//}

/* Method to format the textfield value length after entering for SSN/DOB*/
-(int)getLength:(NSString*)formatNumber{
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@":" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"/" withString:@""];
    int length = [formatNumber length];
    return length;
}
-(BOOL)getDateFromString:(NSString *)string
{
    NSString *dateStr = [NSString stringWithFormat: @"%@",string];
    
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"MM/dd/YYYY"];
    
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"YYYY"];
    NSString *currentYearString = [yearFormatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MM"];
    NSString *currentMonthString = [monthFormatter stringFromDate:[NSDate date]];
    
    int pastYear = [currentYearString integerValue]-100;
    int futureYear = [currentYearString integerValue]+100;
    
    NSDateFormatter *date1Formatter = [[NSDateFormatter alloc] init];
    [date1Formatter setDateFormat:@"MM/dd/YYYY"];
    NSString *dateCurrentString = [date1Formatter stringFromDate:[NSDate date]];
    NSLog(@"currentDate:%@",dateCurrentString);
    
    NSString *datePastString = [NSString stringWithFormat:@"%@/%@/%d",currentMonthString,currentDateString,pastYear];
    NSLog(@"pastDate:%@",datePastString);
    
    NSString *dateFutureString = [NSString stringWithFormat:@"%@/%@/%d",currentMonthString,currentDateString,futureYear];
    NSLog(@"futureDate:%@",dateFutureString);
    
    NSDate *startDate = [formate dateFromString:[NSString stringWithFormat:@"%@",datePastString]];//Divya
    NSDate *endDate = [formate dateFromString:[NSString stringWithFormat:@"%@",dateFutureString]];//Divya
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/YYYY"];
    NSDate *currentDate = [formate dateFromString:dateStr];
    
    
    NSComparisonResult result1,result2;
    //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
    
    result1 = [currentDate compare:startDate]; // comparing two dates
    result2 = [currentDate compare:endDate]; // comparing two dates
    
    if(result2==NSOrderedAscending && result1==NSOrderedDescending)
    {
        NSLog(@"Between the StartDate and Enddate");
        return YES;
        
    }else{
        [FAUtilities showAlert:DATE_INVALID];
        return NO;
    }
}




- (void) scrollToControl:(UIView*)control {
    int viewPortHeight = itemInfoScrollView.frame.size.height - keyboardHeight;
    
    CGRect rectToScroll = CGRectZero;
    int controlBottomLine = 0;
    
    if (control != nil) {
        rectToScroll = CGRectMake(control.frame.origin.x, control.frame.origin.y+100, control.frame.size.width, control.frame.size.height);
        controlBottomLine = control.frame.origin.y + control.frame.size.height;
        
        if (controlBottomLine > (viewPortHeight)) {
            [itemInfoScrollView setContentOffset:CGPointMake(0, controlBottomLine-100)animated:YES];
        }
    }else{
        itemInfoScrollView.contentSize = CGSizeMake(currentScrollView.frame.size.width, 880);
        //        [currentScrollView setContentOffset:CGPointZero];
    }
    
}



-(IBAction)addItemSaveBtnClicked:(id)sender{
    [self.view endEditing:YES];
    if (itemNameTextField.text.length == 0 ) {
        [FAUtilities showAlert:@"Please Enter Item name"];
    }else{
        dbManager = [DataBaseManager dataBaseManager];
       
        if (itemID.length == 0) {
            
            if (itemAdded == YES) {
                int tempID =[self lastInsertedItemRowID];
                itemID = [NSString stringWithFormat:@"%d",tempID];
                
                NSString *updatedSyncStatus;
                
                NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Item where ID='%@'",itemID] resultsArray:syncDetails];
                
                NSLog(@"syncDetails %@", syncDetails);
                
                NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
                
                
                if ([syncValue isEqualToString:@"Sync"] || [syncValue isEqualToString:@"Update"]) {
                    updatedSyncStatus = @"Update";
                }else{
                    updatedSyncStatus = @"New";
                }
                
                
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSError* error = nil;
                
                itemPath = [roomPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",itemID]];
                
                if (![fileManager fileExistsAtPath:itemPath]){
                    [fileManager createDirectoryAtPath:itemPath withIntermediateDirectories:NO attributes:nil error:&error];
                }else {
                }
                if (currentItemCategoryID.length==0 ||[currentItemCategoryID isKindOfClass:[NSNull class]] || !currentItemCategoryID) {
                    currentItemCategoryID=@"0";
                }
                if (currentItemConditionID.length==0 ||[currentItemConditionID isKindOfClass:[NSNull class]] || !currentItemConditionID) {
                    currentItemConditionID=@"0";
                }
                if (currentItemStatusID.length==0 ||[currentItemStatusID isKindOfClass:[NSNull class]]|| !currentItemStatusID ) {
                    currentItemStatusID=@"0";
                }
                
                NSLog(@" update is Insured item added id 0:%d",isInsuredVal );
                NSLog(@" update is taxable item added id 0:%d",isTaxableVal);
                
                if (isInsuredClicked ==YES) {
                    isInsuredVal =1;
                }if (isTaxableClicked ==YES) {
                    isTaxableVal =1;
                }
                
                //Divya
                BOOL isQuerySuccess;
                
                NSMutableArray *pdfPathAry = [[NSMutableArray alloc]init];
                [dbManager execute:[NSString stringWithFormat:@"SELECT PdfPath FROM Item Where ID = '%@' ",itemID] resultsArray:pdfPathAry];
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
                
                
//                if ([itemServerID isKindOfClass:[NSNull class]]) {
//                    itemServerID =@"";
//                }
                if ([itemSoldDate.text isKindOfClass:[NSNull class]]||([itemSoldDate.text isEqualToString:@"0000-00-00"])) {
                    itemSoldDate.text =@"";
                }if ([itemSoldTo.text isKindOfClass:[NSNull class]]||(itemSoldTo.text.length==0)) {
                    itemSoldTo.text =@"";
                }if ([itemSoldPrice.text isKindOfClass:[NSNull class]]||([itemSoldPrice.text isEqual:@"0.00"])) {
                    itemSoldPrice.text =@"";
                }if ([itemWarrantyExpire.text isKindOfClass:[NSNull class]]||([itemWarrantyExpire.text isEqualToString:@"0000-00-00"])) {
                    itemWarrantyExpire.text =@"";
                }if ([itemWarrantyInfo.text isKindOfClass:[NSNull class]]||(itemWarrantyInfo.text.length==0)) {
                    itemWarrantyInfo.text =@"";
                }if ([itemMaterialMade.text isKindOfClass:[NSNull class]]||(itemMaterialMade.text.length==0)) {
                    itemMaterialMade.text =@"";
                } if ([itemShape.text isKindOfClass:[NSNull class]]||(itemShape.text.length==0)) {
                    itemShape.text =@"";
                }if ([itemColor.text isKindOfClass:[NSNull class]]||(itemColor.text.length==0)) {
                    itemColor.text =@"";
                }if (isInsuredVal == (int)[NSNull null]){
                    isInsuredVal =0;
                }if (isTaxableVal == (int)[NSNull null]) {
                    isTaxableVal =0;
                }if ([itemComments.text isKindOfClass:[NSNull class]]||(itemComments.text.length==0)) {
                    itemComments.text =@"";
                }if ([itemInsureBy.text isKindOfClass:[NSNull class]]||(itemInsureBy.text.length==0)) {
                    itemInsureBy.text =@"";
                }if ([itemInsurePolicy.text isKindOfClass:[NSNull class]]||(itemInsurePolicy.text.length==0)) {
                    itemInsurePolicy.text =@"";
                }if ([itemLeaseStartDate.text isKindOfClass:[NSNull class]]||([itemLeaseStartDate.text isEqualToString:@"0000-00-00"])) {
                    itemLeaseStartDate.text =@"";
                }if ([itemLeaseEndDate.text isKindOfClass:[NSNull class]]||([itemLeaseEndDate.text isEqualToString:@"0000-00-00"])) {
                    itemLeaseEndDate.text =@"";
                }if ([itemLeaseDesc.text isKindOfClass:[NSNull class]]||(itemLeaseDesc.text.length==0)) {
                    itemLeaseDesc.text =@"";
                }
//                if ([datePurchase isKindOfClass:[NSNull class]]||([datePurchase isEqualToString:@"0000-00-00"])) {
//                    datePurchase =@"";
//                }
                
                if ([itemReplacementCost.text isKindOfClass:[NSNull class]]||([itemReplacementCost.text isEqual:@"0.00"])) {
                    itemReplacementCost.text =@"";
                }if ([itemSerialNum.text isKindOfClass:[NSNull class]]||(itemSerialNum.text.length==0)) {
                    itemSerialNum.text =@"";
                }if ([itemPlaceInService.text isKindOfClass:[NSNull class]]||(itemPlaceInService.text.length==0)) {
                    itemPlaceInService.text =@"";
                }if ([itemUsePercentage.text isKindOfClass:[NSNull class]]||([itemUsePercentage.text  isEqual: @"0"])) {
                    itemUsePercentage.text =@"";
                }if ([itemSalvageValue.text isKindOfClass:[NSNull class]]||([itemSalvageValue.text isEqual:@"0"])) {
                    itemSalvageValue.text =@"";
                }if ([itemDepreciationMethod.text isKindOfClass:[NSNull class]]||([itemDepreciationMethod.text isEqual:@"0"])) {
                    itemDepreciationMethod.text =@"";
                }if ([itemBenificiary.text isKindOfClass:[NSNull class]]||(itemBenificiary.text.length==0)) {
                    itemBenificiary.text =@"";
                }if ([itemLifeInYears.text isKindOfClass:[NSNull class]]||([itemLifeInYears.text isEqual:@"0"])) {
                    itemLifeInYears.text =@"";
                }
                
                if (currentItemCategoryID.length==0 ||[currentItemCategoryID isKindOfClass:[NSNull class]] || !currentItemCategoryID) {
                    currentItemCategoryID=@"0";
                }
                if (currentItemConditionID.length==0 ||[currentItemConditionID isKindOfClass:[NSNull class]] || !currentItemConditionID) {
                    currentItemConditionID=@"0";
                }
                if (currentItemStatusID.length==0 ||[currentItemStatusID isKindOfClass:[NSNull class]]|| !currentItemStatusID ) {
                    currentItemStatusID=@"0";
                }
               
                NSString *tempItemNameStr   = [itemNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempItemDescStr   = [itemDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempMafStr        = [itemManufacturer.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempsoldToStr     = [itemSoldTo.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempInsuredByStr  = [itemInsureBy.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

                
                NSString *tempItemInvoiceNumberStr  = [itemInvoiceNum.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempItemBrandStr          = [itemBrand.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempModelStr              = [itemModel.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                NSString *tempQtyStr                = [itemQunatity.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempSizeStr               = [itemSize.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                NSString *tempShapeStr              = [itemShape.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempColorStr              = [itemColor.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempWarrantyInfoStr       = [itemWarrantyInfo.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempInsurePolicyStr       = [itemInsurePolicy.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempSerialStr             = [itemSerialNum.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                NSString *tempPlacedInServiceStr    = [itemPlaceInService.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                NSString *tempSalvageStr            = [itemSalvageValue.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                NSString *tempDepreciationStr       = [itemDepreciationMethod.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempBenificiaryStr        = [itemBenificiary.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempCommentsStr           = [itemComments.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempMaterialMadeStr       = [itemMaterialMade.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                
                isQuerySuccess =[dbManager execute:[NSString stringWithFormat:@"Update Item set Name = '%@',Description='%@',Category='%@',DatePurchase='%@', InvoiceNum='%@',Manufacturer='%@',Cost='%@',Brand='%@', Model='%@',Condition ='%@',Quantity='%@',Status='%@',Size='%@',YearMade='%@',MaterialMade='%@',Shape='%@',Color='%@',IsTaxable='%d',IsInsured='%d',SoldTo='%@',SoldDate='%@',SoldPrice='%@',WarrantyExpire='%@',WarrantyInfo='%@',InsuredBy='%@',InsuredPolicy='%@',LeaseStartDate='%@',LeaseEndDate='%@',LeaseDesc='%@',ReplacementCost='%@',SerialNum='%@',PlacedInService='%@',UsePercentage='%@',SalvageValue='%@',DepreciationMethod='%@',Beneficiary='%@',LifeInYears='%@',Comments='%@', SyncStatus='%@',CurrentValue='%@' where ID = '%@'",tempItemNameStr,tempItemDescStr,currentItemCategoryID,itemPurchasedDate.text,tempItemInvoiceNumberStr,tempMafStr,itemCost.text,tempItemBrandStr,tempModelStr,currentItemConditionID,itemQunatity.text,currentItemStatusID,tempSizeStr,itemYearMade.text,tempMaterialMadeStr,tempShapeStr,tempColorStr,isTaxableVal,isInsuredVal,tempsoldToStr,itemSoldDate.text,itemSoldPrice.text,itemWarrantyExpire.text,tempWarrantyInfoStr,tempInsuredByStr,tempInsurePolicyStr,itemLeaseStartDate.text,itemLeaseEndDate.text,itemLeaseDesc.text,itemReplacementCost.text,tempSerialStr,tempPlacedInServiceStr,itemUsePercentage.text,itemSalvageValue.text,itemDepreciationMethod.text,tempBenificiaryStr,itemLifeInYears.text,tempCommentsStr,updatedSyncStatus,itemCurrentValue.text,itemID]];
                if (isQuerySuccess==YES) {
                    [FAUtilities showAlert:@"Item Updated"];
                    
                }else{
                    [FAUtilities showAlert:@"Failed to update item due to invalid text entry"];
                }
            }else{
                
                //                if ([itemServerID isKindOfClass:[NSNull class]]) {
                //                    itemServerID =@"";
                //                }
                if ([itemSoldDate.text isKindOfClass:[NSNull class]]||([itemSoldDate.text isEqualToString:@"0000-00-00"])) {
                    itemSoldDate.text =@"";
                }if ([itemSoldTo.text isKindOfClass:[NSNull class]]||(itemSoldTo.text.length==0)) {
                    itemSoldTo.text =@"";
                }if ([itemSoldPrice.text isKindOfClass:[NSNull class]]||([itemSoldPrice.text isEqual:@"0.00"])) {
                    itemSoldPrice.text =@"";
                }if ([itemWarrantyExpire.text isKindOfClass:[NSNull class]]||([itemWarrantyExpire.text isEqualToString:@"0000-00-00"])) {
                    itemWarrantyExpire.text =@"";
                }if ([itemWarrantyInfo.text isKindOfClass:[NSNull class]]||(itemWarrantyInfo.text.length==0)) {
                    itemWarrantyInfo.text =@"";
                }if ([itemMaterialMade.text isKindOfClass:[NSNull class]]||(itemMaterialMade.text.length==0)) {
                    itemMaterialMade.text =@"";
                } if ([itemShape.text isKindOfClass:[NSNull class]]||(itemShape.text.length==0)) {
                    itemShape.text =@"";
                }if ([itemColor.text isKindOfClass:[NSNull class]]||(itemColor.text.length==0)) {
                    itemColor.text =@"";
                } if ([itemYearMade.text isKindOfClass:[NSNull class]]||([itemYearMade.text  isEqual: @"0"])) {
                    itemYearMade.text =@"";
                }if (isInsuredVal == (int)[NSNull null]){
                    isInsuredVal =0;
                }if (isTaxableVal == (int)[NSNull null]) {
                    isTaxableVal =0;
                }if ([itemComments.text isKindOfClass:[NSNull class]]||(itemComments.text.length==0)) {
                    itemComments.text =@"";
                }if ([itemInsureBy.text isKindOfClass:[NSNull class]]||(itemInsureBy.text.length==0)) {
                    itemInsureBy.text =@"";
                }if ([itemInsurePolicy.text isKindOfClass:[NSNull class]]||(itemInsurePolicy.text.length==0)) {
                    itemInsurePolicy.text =@"";
                }if ([itemLeaseStartDate.text isKindOfClass:[NSNull class]]||([itemLeaseStartDate.text isEqualToString:@"0000-00-00"])) {
                    itemLeaseStartDate.text =@"";
                }if ([itemLeaseEndDate.text isKindOfClass:[NSNull class]]||([itemLeaseEndDate.text isEqualToString:@"0000-00-00"])) {
                    itemLeaseEndDate.text =@"";
                }if ([itemLeaseDesc.text isKindOfClass:[NSNull class]]||(itemLeaseDesc.text.length==0)) {
                    itemLeaseDesc.text =@"";
                }
                //                if ([datePurchase isKindOfClass:[NSNull class]]||([datePurchase isEqualToString:@"0000-00-00"])) {
                //                    datePurchase =@"";
                //                }
                
                if ([itemReplacementCost.text isKindOfClass:[NSNull class]]||([itemReplacementCost.text isEqual:@"0.00"])) {
                    itemReplacementCost.text =@"";
                }if ([itemSerialNum.text isKindOfClass:[NSNull class]]||(itemSerialNum.text.length==0)) {
                    itemSerialNum.text =@"";
                }if ([itemPlaceInService.text isKindOfClass:[NSNull class]]||(itemPlaceInService.text.length==0)) {
                    itemPlaceInService.text =@"";
                }if ([itemUsePercentage.text isKindOfClass:[NSNull class]]||([itemUsePercentage.text  isEqual: @"0"])) {
                    itemUsePercentage.text =@"";
                }if ([itemSalvageValue.text isKindOfClass:[NSNull class]]||([itemSalvageValue.text isEqual:@"0"])) {
                    itemSalvageValue.text =@"";
                }if ([itemDepreciationMethod.text isKindOfClass:[NSNull class]]||([itemDepreciationMethod.text isEqual:@"0"])) {
                    itemDepreciationMethod.text =@"";
                }if ([itemBenificiary.text isKindOfClass:[NSNull class]]||(itemBenificiary.text.length==0)) {
                    itemBenificiary.text =@"";
                }if ([itemLifeInYears.text isKindOfClass:[NSNull class]]||([itemLifeInYears.text isEqual:@"0"])) {
                    itemLifeInYears.text =@"";
                }
                if (currentItemCategoryID.length==0 ||[currentItemCategoryID isKindOfClass:[NSNull class]] || !currentItemCategoryID) {
                    currentItemCategoryID=@"0";
                }
                if (currentItemConditionID.length==0 ||[currentItemConditionID isKindOfClass:[NSNull class]] || !currentItemConditionID) {
                    currentItemConditionID=@"0";
                }
                if (currentItemStatusID.length==0 ||[currentItemStatusID isKindOfClass:[NSNull class]]|| !currentItemStatusID ) {
                    currentItemStatusID=@"0";
                }
                
                NSLog(@" insert is Insured item added id 0:%d",isInsuredVal );
                NSLog(@" insert is taxable item added id 0:%d",isTaxableVal);
                
                if (isInsuredClicked ==YES) {
                    isInsuredVal =1;
                }if (isTaxableClicked ==YES) {
                    isTaxableVal =1;
                }
                
                NSString *tempItemNameStr   = [itemNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempItemDescStr   = [itemDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempMafStr        = [itemManufacturer.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempsoldToStr     = [itemSoldTo.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempInsuredByStr  = [itemInsureBy.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                NSString *tempItemInvoiceNumberStr  = [itemInvoiceNum.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempItemBrandStr          = [itemBrand.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempModelStr              = [itemModel.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                NSString *tempQtyStr                = [itemQunatity.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempSizeStr               = [itemSize.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                NSString *tempShapeStr              = [itemShape.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempColorStr              = [itemColor.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempWarrantyInfoStr       = [itemWarrantyInfo.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempInsurePolicyStr       = [itemInsurePolicy.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempSerialStr             = [itemSerialNum.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                
                NSString *tempPlacedInServiceStr    = [itemPlaceInService.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                NSString *tempSalvageStr            = [itemSalvageValue.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//                NSString *tempDepreciationStr       = [itemDepreciationMethod.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempBenificiaryStr        = [itemBenificiary.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempCommentsStr           = [itemComments.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *tempMaterialMadeStr       = [itemMaterialMade.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

                
                BOOL isQuerySuccess;
                isQuerySuccess=  [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Item' (HouseID,RoomID,Name,Description,Category,DatePurchase,InvoiceNum,Manufacturer,Cost,Brand,Model,Condition,Quantity,Status,Size,YearMade,MaterialMade,Shape,Color,IsTaxable,IsInsured,SoldTo,SoldDate,SoldPrice,WarrantyExpire,WarrantyInfo,InsuredBy,InsuredPolicy,LeaseStartDate,LeaseEndDate,LeaseDesc,ReplacementCost,SerialNum,PlacedInService,UsePercentage,SalvageValue,DepreciationMethod,Beneficiary,LifeInYears,Comments,SyncStatus,CurrentValue)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%d','%d','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",houseID,roomID,tempItemNameStr,tempItemDescStr,currentItemCategoryID,itemPurchasedDate.text,tempItemInvoiceNumberStr,tempMafStr,itemCost.text,tempItemBrandStr,tempModelStr,currentItemConditionID,itemQunatity.text,currentItemStatusID,tempSizeStr,itemYearMade.text,tempMaterialMadeStr,tempShapeStr,tempColorStr,isTaxableVal,isInsuredVal,tempsoldToStr,itemSoldDate.text,itemSoldPrice.text,itemWarrantyExpire.text,tempWarrantyInfoStr,tempInsuredByStr,tempInsurePolicyStr,itemLeaseStartDate.text,itemLeaseEndDate.text,itemLeaseDesc.text,itemReplacementCost.text,tempSerialStr,tempPlacedInServiceStr,itemUsePercentage.text,itemSalvageValue.text,itemDepreciationMethod.text,tempBenificiaryStr,itemLifeInYears.text,tempCommentsStr,@"New",itemCurrentValue.text]];
                if (isQuerySuccess==YES) {
                    [FAUtilities showAlert:@"Item Added"];
                   
                    int tempID =[self lastInsertedItemRowID];
                    itemID = [NSString stringWithFormat:@"%d",tempID];

                }else{
                    [FAUtilities showAlert:@"Failed to add item due to invalid text entry"];
                }
                
            }
            
            
            int tempID =[self lastInsertedItemRowID];
            NSString *tempItemID = [NSString stringWithFormat:@"%d",tempID];
            
            
            NSFileManager* fileManager = [NSFileManager defaultManager];
            NSError* error = nil;
            
            itemPath = [roomPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",tempItemID]];
            
            if (![fileManager fileExistsAtPath:itemPath]){
                [fileManager createDirectoryAtPath:itemPath withIntermediateDirectories:NO attributes:nil error:&error];
            }else {
            }
            
            
        }else{
            
            NSString *updatedSyncStatus;
            
            NSMutableArray *syncDetails = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Item where ID='%@'",itemID] resultsArray:syncDetails];
            
            NSLog(@"syncDetails %@", syncDetails);
            
            NSString *syncValue = [[syncDetails objectAtIndex:0] valueForKey:@"SyncStatus"];
            
            
            if ([syncValue isEqualToString:@"Sync"] || [syncValue isEqualToString:@"Update"]) {
                updatedSyncStatus = @"Update";
            }else{
                updatedSyncStatus = @"New";
            }
            
            
            NSLog(@" update is Insured item update id !0:%d",isInsuredVal );
            NSLog(@" update is taxable item update id !0:%d",isTaxableVal);
            
            if (isInsuredClicked ==YES) {
                isInsuredVal =1;
            }if (isTaxableClicked ==YES) {
                isTaxableVal =1;
            }

            //Divya
            BOOL isQuerySuccess;
            
            NSMutableArray *pdfPathAry = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT PdfPath FROM Item Where ID = '%@' ",itemID] resultsArray:pdfPathAry];
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

            
            //                if ([itemServerID isKindOfClass:[NSNull class]]) {
            //                    itemServerID =@"";
            //                }
            if ([itemSoldDate.text isKindOfClass:[NSNull class]]||([itemSoldDate.text isEqualToString:@"0000-00-00"])) {
                itemSoldDate.text =@"";
            }if ([itemSoldTo.text isKindOfClass:[NSNull class]]||(itemSoldTo.text.length==0)) {
                itemSoldTo.text =@"";
            }if ([itemSoldPrice.text isKindOfClass:[NSNull class]]||([itemSoldPrice.text isEqual:@"0.00"])) {
                itemSoldPrice.text =@"";
            }if ([itemWarrantyExpire.text isKindOfClass:[NSNull class]]||([itemWarrantyExpire.text isEqualToString:@"0000-00-00"])) {
                itemWarrantyExpire.text =@"";
            }if ([itemWarrantyInfo.text isKindOfClass:[NSNull class]]||(itemWarrantyInfo.text.length==0)) {
                itemWarrantyInfo.text =@"";
            }if ([itemMaterialMade.text isKindOfClass:[NSNull class]]||(itemMaterialMade.text.length==0)) {
                itemMaterialMade.text =@"";
            } if ([itemShape.text isKindOfClass:[NSNull class]]||(itemShape.text.length==0)) {
                itemShape.text =@"";
            }if ([itemColor.text isKindOfClass:[NSNull class]]||(itemColor.text.length==0)) {
                itemColor.text =@"";
            } if ([itemYearMade.text isKindOfClass:[NSNull class]]||([itemYearMade.text  isEqual: @"0"])) {
                itemYearMade.text =@"";
            }if (isInsuredVal == (int)[NSNull null]){
                isInsuredVal =0;
            }if (isTaxableVal == (int)[NSNull null]) {
                isTaxableVal =0;
            }if ([itemComments.text isKindOfClass:[NSNull class]]||(itemComments.text.length==0)) {
                itemComments.text =@"";
            }if ([itemInsureBy.text isKindOfClass:[NSNull class]]||(itemInsureBy.text.length==0)) {
                itemInsureBy.text =@"";
            }if ([itemInsurePolicy.text isKindOfClass:[NSNull class]]||(itemInsurePolicy.text.length==0)) {
                itemInsurePolicy.text =@"";
            }if ([itemLeaseStartDate.text isKindOfClass:[NSNull class]]||([itemLeaseStartDate.text isEqualToString:@"0000-00-00"])) {
                itemLeaseStartDate.text =@"";
            }if ([itemLeaseEndDate.text isKindOfClass:[NSNull class]]||([itemLeaseEndDate.text isEqualToString:@"0000-00-00"])) {
                itemLeaseEndDate.text =@"";
            }if ([itemLeaseDesc.text isKindOfClass:[NSNull class]]||(itemLeaseDesc.text.length==0)) {
                itemLeaseDesc.text =@"";
            }
            //                if ([datePurchase isKindOfClass:[NSNull class]]||([datePurchase isEqualToString:@"0000-00-00"])) {
            //                    datePurchase =@"";
            //                }
            
            if ([itemReplacementCost.text isKindOfClass:[NSNull class]]||([itemReplacementCost.text isEqual:@"0.00"])) {
                itemReplacementCost.text =@"";
            }if ([itemSerialNum.text isKindOfClass:[NSNull class]]||(itemSerialNum.text.length==0)) {
                itemSerialNum.text =@"";
            }if ([itemPlaceInService.text isKindOfClass:[NSNull class]]||(itemPlaceInService.text.length==0)) {
                itemPlaceInService.text =@"";
            }if ([itemUsePercentage.text isKindOfClass:[NSNull class]]||([itemUsePercentage.text  isEqual: @"0"])) {
                itemUsePercentage.text =@"";
            }if ([itemSalvageValue.text isKindOfClass:[NSNull class]]||([itemSalvageValue.text isEqual:@"0"])) {
                itemSalvageValue.text =@"";
            }if ([itemDepreciationMethod.text isKindOfClass:[NSNull class]]||([itemDepreciationMethod.text isEqual:@"0"])) {
                itemDepreciationMethod.text =@"";
            }if ([itemBenificiary.text isKindOfClass:[NSNull class]]||(itemBenificiary.text.length==0)) {
                itemBenificiary.text =@"";
            }if ([itemLifeInYears.text isKindOfClass:[NSNull class]]||([itemLifeInYears.text isEqual:@"0"])) {
                itemLifeInYears.text =@"";
            }

            if (currentItemCategoryID.length==0 ||[currentItemCategoryID isKindOfClass:[NSNull class]] || !currentItemCategoryID) {
                currentItemCategoryID=@"0";
            }
            if (currentItemConditionID.length==0 ||[currentItemConditionID isKindOfClass:[NSNull class]] || !currentItemConditionID) {
                currentItemConditionID=@"0";
            }
            if (currentItemStatusID.length==0 ||[currentItemStatusID isKindOfClass:[NSNull class]]|| !currentItemStatusID ) {
                currentItemStatusID=@"0";
            }
            
            NSString *tempItemNameStr   = [itemNameTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempItemDescStr   = [itemDescTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempMafStr        = [itemManufacturer.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempsoldToStr     = [itemSoldTo.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempInsuredByStr  = [itemInsureBy.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

            
            NSString *tempItemInvoiceNumberStr  = [itemInvoiceNum.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempItemBrandStr          = [itemBrand.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempModelStr              = [itemModel.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//            NSString *tempQtyStr                = [itemQunatity.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempSizeStr               = [itemSize.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            NSString *tempShapeStr              = [itemShape.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempColorStr              = [itemColor.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempWarrantyInfoStr       = [itemWarrantyInfo.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempInsurePolicyStr       = [itemInsurePolicy.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempSerialStr             = [itemSerialNum.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            NSString *tempPlacedInServiceStr    = [itemPlaceInService.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//            NSString *tempSalvageStr            = [itemSalvageValue.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//            NSString *tempDepreciationStr       = [itemDepreciationMethod.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempBenificiaryStr        = [itemBenificiary.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempCommentsStr           = [itemComments.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *tempMaterialMadeStr       = [itemMaterialMade.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

            
            isQuerySuccess=  [dbManager execute:[NSString stringWithFormat:@"Update Item set Name = '%@',Description='%@',Category='%@',DatePurchase='%@', InvoiceNum='%@',Manufacturer='%@',Cost='%@',Brand='%@', Model='%@',Condition ='%@',Quantity='%@',Status='%@',Size='%@',YearMade='%@',MaterialMade='%@',Shape='%@',Color='%@',IsTaxable='%d',IsInsured='%d',SoldTo='%@',SoldDate='%@',SoldPrice='%@',WarrantyExpire='%@',WarrantyInfo='%@',InsuredBy='%@',InsuredPolicy='%@',LeaseStartDate='%@',LeaseEndDate='%@',LeaseDesc='%@',ReplacementCost='%@',SerialNum='%@',PlacedInService='%@',UsePercentage='%@',SalvageValue='%@',DepreciationMethod='%@',Beneficiary='%@',LifeInYears='%@',Comments='%@',SyncStatus='%@',CurrentValue='%@' where ID = '%@'",tempItemNameStr,tempItemDescStr,currentItemCategoryID,itemPurchasedDate.text,tempItemInvoiceNumberStr,tempMafStr,itemCost.text,tempItemBrandStr,tempModelStr,currentItemConditionID,itemQunatity.text,currentItemStatusID,tempSizeStr,itemYearMade.text,tempMaterialMadeStr,tempShapeStr,tempColorStr,isTaxableVal,isInsuredVal,tempsoldToStr,itemSoldDate.text,itemSoldPrice.text,itemWarrantyExpire.text,tempWarrantyInfoStr,tempInsuredByStr,tempInsurePolicyStr,itemLeaseStartDate.text,itemLeaseEndDate.text,itemLeaseDesc.text,itemReplacementCost.text,tempSerialStr,tempPlacedInServiceStr,itemUsePercentage.text,itemSalvageValue.text,itemDepreciationMethod.text,tempBenificiaryStr,itemLifeInYears.text,tempCommentsStr,updatedSyncStatus,itemCurrentValue.text,itemID]];
            if (isQuerySuccess==YES) {
                [FAUtilities showAlert:@"Item Updated"];
                
            }else{
                [FAUtilities showAlert:@"Failed to update item due to invalid text entry"];
//                itemID=@"";
            }
        }
        itemAdded = YES;
        menuUploadPhotosAlertViewFirstTime = YES;
        //        [self addItemCancelBtnClicked:nil];
    }
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

-(void) perform:(id)sender {
    
    //do your saving and such here
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}





-(IBAction)addItemCancelBtnClicked:(id)sender{
    //    [self showSimple:nil];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults synchronize];
//    [defaults setObject:@"" forKey:@"RoomSelected"];
    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)uploadItemImgsBtnClicked:(id)sender{
    
    NSMutableArray *itemImagesAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
   
    [dbManager execute:[NSString stringWithFormat:@"SELECT Id FROM Images where HouseID= '%@' and RoomID= '%@' and ItemID = '%@' AND SyncStatus != 'Delete'",houseID,roomID,itemID] resultsArray:itemImagesAry];
    
    NSLog(@"uploadItemImgsBtnClicked Query houseID= %@,roomID=%@,itemID=%@",houseID,roomID,itemID);
    
    
    if ([itemImagesAry count]>=4) {
        [FAUtilities showAlertMessage:@"You can add only 4 Item Images"];
    }else{
        photoSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll",@"Camera",nil];
        photoSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [photoSheet showFromRect:CGRectMake(uploadItemImgsBtn.frame.origin.x,uploadItemImgsBtn.frame.origin.y+(2*uploadItemImgsBtn.frame.size.height)+10,100,100) inView:[self view] animated:YES];//Divya added +10
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
        if ([photoPopOver isPopoverVisible]) {
            [photoPopOver  dismissPopoverAnimated:YES];
        }
        [photoPopOver presentPopoverFromRect:CGRectMake(uploadItemImgsBtn.frame.origin.x,uploadItemImgsBtn.frame.origin.y+(2*uploadItemImgsBtn.frame.size.height)+30,100,80) inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (buttonIndex == 1) {

//        [self imagePicker];   // for testing camera view
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        if (![NSThread isMainThread]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:imagePicker animated:YES completion:NULL];
//            });
//        }else{
//            [self presentViewController:imagePicker animated:YES completion:NULL];
//        }
//        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}


// for testing camera view
//-(UIImagePickerController *) imagePicker{
//    UIImagePickerController *tempImagePicker = [[UIImagePickerController alloc]init];
//    tempImagePicker.delegate = self;
//    tempImagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:tempImagePicker animated:YES completion:NULL];
//
//    return tempImagePicker;
//}




#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

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

    
    
//    UIImage *reducedNewImage =[self imageWithImage:chosenImage scaledToSize:CGSizeMake(125,125)];
//    NSData *reducedData  = UIImageJPEGRepresentation(reducedNewImage, 0);
    
    NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    
    NSLog(@"metadata %@", metadata);
    NSData *imgData;
    
    if (metadata != NULL) {
        imgData = UIImageJPEGRepresentation(chosenImage, 0.5);
    }else{
        imgData = [NSData dataWithData:UIImagePNGRepresentation(chosenImage)];
    }
    
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
        fileName = [NSString stringWithFormat:@"%@_%@_%@_%d_%d.png",houseID,roomID,itemID,currentID,unixtime];
        
        //  fileName = [NSString stringWithFormat:@"%@_%@_%@_%d.png",houseID,roomID,itemID,currentID];
        storePath = [itemPath stringByAppendingPathComponent:fileName];
        [imgData writeToFile:storePath atomically:YES];
    }
    NSString* filePath = [storePath stringByAppendingPathComponent:fileName];
    imgData = [NSData dataWithContentsOfFile:filePath];
    dbManager = [DataBaseManager dataBaseManager];
    
    NSMutableArray *itemImagesAry = [[NSMutableArray alloc]init];
    
    NSString *syncValue;
    //    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images Where SyncStatus ='New' AND (ItemID ='%@' or HouseID='%@' or RoomID='%@')",itemID,houseID,roomID] resultsArray:itemImagesAry];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Images where HouseID= '%@' and RoomID= '%@' and ItemID = '%@' AND SyncStatus != 'Delete'",houseID,roomID,itemID] resultsArray:itemImagesAry];
    NSLog(@"imagePickerController Query houseID= %@,roomID=%@,itemID=%@",houseID,roomID,itemID);
    
    if ([itemImagesAry count]>=4) {
        [FAUtilities showAlert:@"You can add only 4 Item Images"];
    }else{
        
        if ([houseID isKindOfClass:[NSNull class]]) {
            houseID =@"";
        }
        if ([roomID isKindOfClass:[NSNull class]]) {
            roomID =@"";
        }
        if ([itemID isKindOfClass:[NSNull class]]) {
            itemID =@"";
        }
        if ([storePath isKindOfClass:[NSNull class]]||(storePath.length==0)) {
            storePath =@"";
        }
//        if ([imageByteAryresult isKindOfClass:[NSNull class]]||(imageByteAryresult.length==0)) {
//            imageByteAryresult =@"";
//        }
        
        [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Images' (HouseID,RoomID,ItemID,ImagePath,ImageData,SyncStatus)VALUES ('%@','%@','%@','%@','%@','%@')",houseID,roomID,itemID,storePath,imageByteAryresult,@"New"]];
        
        NSMutableArray *syncStatusAry = [[NSMutableArray alloc]init];
        [dbManager execute:[NSString stringWithFormat:@"SELECT SyncStatus FROM Item where ID='%@'",itemID] resultsArray:syncStatusAry];
        NSLog(@"syncStatusAry %@", syncStatusAry);
        syncValue = [[syncStatusAry objectAtIndex:0] valueForKey:@"SyncStatus"];
        
    }
    if ([syncValue isEqualToString:@"Sync"]) {
        if ([itemID isKindOfClass:[NSNull class]]||(itemID.length==0)) {
            itemID =@"";
        }
        [dbManager execute:[NSString stringWithFormat:@"Update Item set SyncStatus='Update' where ID = '%@'",itemID]];
    }
    
    [self showSimple:nil];

//    [FAUtilities showAlert:@"Image Added"];
//    [self showSimple:nil];
//    [self drawAttchmentsView];
}



/* Method to design Form folders */
- (BOOL)drawAttchmentsView{
    
    imagesAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    [dbManager execute:[NSString stringWithFormat:@"SELECT ID,ServerPath,ImagePath FROM Images where HouseID= '%@' and RoomID= '%@' and ItemID = '%@' AND (SyncStatus = 'Sync' or SyncStatus = 'New')",houseID,roomID,itemID] resultsArray:imagesAry];
    
    CGFloat originX;
    CGFloat width =0;
    originX = 0;
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        width = 125;
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        width = 125;
    }
    
    CGFloat originY = 0;
    CGFloat height = 125;
    CGFloat yGap = 0;
    
    
    
    if ( [itemImagesScrollView.subviews count] >0) {
        for (UIView *view in itemImagesScrollView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    int foldersContainEachRow = 6;
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        foldersContainEachRow = 8;
    }
    
    for (int i=0; i<[imagesAry count]; i++) {
        
        NSString *imgID =[[imagesAry objectAtIndex:i]valueForKey:@"ID"];
        int imgTagID = [imgID intValue];
        
        UIView *folderView = [self createFolderViewForTag:i withID:imgTagID withFrame:CGRectMake(originX, originY, width, height)];
        folderView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
        folderView.layer.borderWidth = 3;
        folderView.backgroundColor = [UIColor lightGrayColor];
        
        [itemImagesScrollView addSubview:folderView];
        int val = i+1;
        
        if(val%foldersContainEachRow != 0){
            originX += width;
        }
        else{
            originY += height+yGap;
            
            if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
                originX = 0;
            }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
                originX = 0;
            }
        }
        
    }
    itemImagesScrollView.contentSize = CGSizeMake(0, originY+height);
    
//    [self hideSimple:nil];
    return YES;
}


/* Method to create Form folders */
- (UIView*)createFolderViewForTag:(int)tag withID:(int)itemImgID withFrame:(CGRect)rect{
    UIView *folderVIew = [[UIView alloc]initWithFrame:rect];
//    UIButton *itmImgGridViewBtn;
  UIButton *itmImgGridViewBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    itmImgGridViewBtn.tag = itemImgID;
    [itmImgGridViewBtn addTarget:self action:@selector(selectedImgWithTag:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongPressWithTag:)];
    [itmImgGridViewBtn addGestureRecognizer:longPress];
    
    [itmImgGridViewBtn addTarget:self action:@selector(showItemImage:) forControlEvents:UIControlEventTouchUpInside];
  
    NSLog(@"createFolderViewForTag imagesAry 0 object %@",  [imagesAry objectAtIndex:tag]);
    
    NSDictionary *selectedBtnDetails = [imagesAry objectAtIndex:tag];
    NSLog(@"selectedBtnDetails %@", selectedBtnDetails);
    
    
    if (imagesAry.count ==0) {
        [itmImgGridViewBtn setBackgroundImage:[UIImage imageNamed:@"no_image.jpg"] forState:UIControlStateNormal];
    }else{
        NSDictionary *currentHouseTempDict = [imagesAry objectAtIndex:tag];
//        NSString *valStr = [currentHouseTempDict valueForKey:@"ImageData"];
        NSString *localPath =[currentHouseTempDict valueForKey:@"ImagePath"];
        NSString *imgUrl = [currentHouseTempDict valueForKey:@"ServerPath"];
        
//        NSString *tempFile = [currentHouseTempDict valueForKey:@"ServerPath"];
//        NSString *imgUrl = [tempFile stringByReplacingOccurrencesOfString:@"rhm.mlx.com" withString:@"192.168.137.20"];

        
        
        NSString *imgID= [currentHouseTempDict valueForKey:@"ID"];
        
        if (localPath.length !=0) {
            [itmImgGridViewBtn setBackgroundImage:[UIImage imageWithContentsOfFile:localPath] forState:UIControlStateNormal];
//            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
//            [itmImgGridViewBtn setBackgroundImage:img forState:UIControlStateNormal];
            
        }else{
            
            UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itmImgGridViewBtn.frame.origin.x, itmImgGridViewBtn.frame.origin.y, itmImgGridViewBtn.frame.size.width, itmImgGridViewBtn.frame.size.width)];
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
            
            [itmImgGridViewBtn addSubview:animatedImageView];
            dbManager = [DataBaseManager dataBaseManager];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                // UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                NSString* webStringURL = [imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]]];
                
                [animatedImageView removeFromSuperview];
                [itmImgGridViewBtn setBackgroundImage:img forState:UIControlStateNormal];

                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); // For Saving in libarary
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSError* error = nil;
                
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *rhmDir = [documentsDirectory stringByAppendingPathComponent:@"RHM"];
                NSString *dataPath;
                
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                NSString *CurrentUser_ID= [standardUserDefaults valueForKey:@"CURRENT_USER_LOCAL_ID"];
                
                    dataPath= [rhmDir stringByAppendingPathComponent:CurrentUser_ID];
                if (CurrentUser_ID) {

                    dataPath =[dataPath stringByAppendingPathComponent:@"Image"];
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
                NSString *storePath;
                if (CurrentUser_ID) {
                    imageFilePath = [imageFilePath stringByAppendingPathComponent:@"Image"];
                    NSString *tempHousePath = [imageFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",houseID]];
                    NSString *tempRoomPath = [tempHousePath stringByAppendingString:[NSString stringWithFormat:@"/%@",roomID]];
                    NSString *tempItemPath = [tempRoomPath stringByAppendingString:[NSString stringWithFormat:@"/%@",itemID]];
                    
                    NSString *fileName = [NSString stringWithFormat:@"/%@_%@_%@_%@.png",houseID,roomID,itemID,imgID];
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
                
                
//                [[NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]] writeToFile:storePath atomically:YES];
                
                // [[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]] writeToFile:storePath atomically:YES];
                if ([storePath isKindOfClass:[NSNull class]]||(storePath.length==0)) {
                    storePath =@"";
                }
//                if ([imgID isKindOfClass:[NSNull class]]||(imgID.length==0)) {
//                    imgID =@"";
//                }
                [dbManager execute:[NSString stringWithFormat:@"Update Images set ImagePath='%@' where ID = '%@'",storePath,imgID]];
            });

//            NSArray *bytesAryTest = [valStr componentsSeparatedByString:@","];
//            
//            unsigned c = bytesAryTest.count;
//            uint8_t *bytes = malloc(sizeof(*bytes) * c);
//            
//            unsigned i;
//            for (i = 0; i < c; i++)
//            {
//                NSString *str = [bytesAryTest objectAtIndex:i];
//                int byte = [str intValue];
//                bytes[i] = (uint8_t)byte;
//            }
//            NSData* dbimageData = [NSData dataWithBytes:(const void *)bytes length:sizeof(unsigned char)*c];
//            [itmImgGridViewBtn setBackgroundImage:[UIImage imageWithData:dbimageData] forState:UIControlStateNormal];
        }
        
        
    }
    
    [folderVIew addSubview:itmImgGridViewBtn];
    return folderVIew;
}

- (void)selectedImgWithTag:(UILongPressGestureRecognizer*)gestureRecognizer
{
    [deleteItemImgBtn removeFromSuperview];
    
}


- (void)showItemImage:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    NSString *btnID = [NSString stringWithFormat:@"%ld",(long)button.tag];
    
    NSLog(@"btnID %@", btnID);
    
    UIViewController* popoverContent = [[UIViewController alloc]init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 600, 600)];
    
    NSMutableArray *imgSeverPathAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
   
    [dbManager execute:[NSString stringWithFormat: @"Select ServerPath,ImagePath From Images Where ID = '%@'",btnID] resultsArray:imgSeverPathAry];
    NSLog(@"imgSeverPathAry %@",imgSeverPathAry);
    NSLog(@"[imgSeverPathAry objectAtIndex:0] %@",[imgSeverPathAry objectAtIndex:0]);
    NSLog(@"[imgSeverPathAry oServerPath %@",[[imgSeverPathAry objectAtIndex:0]valueForKey:@"ServerPath"]);
    
//    NSString *imgServerPathVal = [[imgSeverPathAry objectAtIndex:0]valueForKey:@"ServerPath"];
    NSString *imgLocalPathVal= [[imgSeverPathAry objectAtIndex:0]valueForKey:@"ImagePath"];
    
    if (imgLocalPathVal.length !=0) {
        itemImageView.image = [UIImage imageWithContentsOfFile:imgLocalPathVal];
    }
    
    [popoverView addSubview:itemImageView];
    popoverContent.view = popoverView;
    
    popoverContent.preferredContentSize = CGSizeMake(600, 600);
    
    self.itemImagePopOver = [[UIPopoverController alloc]
                             initWithContentViewController:popoverContent];
    
  if ([self.itemImagePopOver isPopoverVisible]) {
        [self.itemImagePopOver  dismissPopoverAnimated:YES];
    }
    [self.itemImagePopOver  presentPopoverFromRect:CGRectMake(0, 0, 133, 29)
                                            inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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


- (void)imgLongPressWithTag:(UILongPressGestureRecognizer*)gestureRecognizer
{
    UIButton *button = (UIButton *)[gestureRecognizer view];
    UIImage *buttonImage = [UIImage imageNamed:@"deleteButton.png"];
    
    deleteItemImgBtn.tag = button.tag;
    [deleteItemImgBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [deleteItemImgBtn addTarget:self action:@selector(deleteItemImgBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:deleteItemImgBtn];
}


-(void)deleteItemImgBtnClicked:(id)sender{
    UIButton *longPressRoomBtn = (UIButton *)sender;
    deletedItemImgID = longPressRoomBtn.tag;
    
    deletedItemImgServerID = [self getServerIDTable:@"Images" ForID:[NSString stringWithFormat:@"%d",deletedItemImgID]];
    
    
    NSString *alertMsg = [NSString stringWithFormat:@"Are you sure your want to delete this Image?"];
    itemImgDeleteAlertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                        message:alertMsg
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [itemImgDeleteAlertView show];
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




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    dbManager = [DataBaseManager dataBaseManager];
    if (buttonIndex == 1){
        
        if (alertView == itemImgDeleteAlertView){
            
            if (deletedItemImgServerID.length ==0) {
                NSString *imgQuery = [NSString stringWithFormat:@"DELETE FROM Images WHERE ID = %d", deletedItemImgID];
                [dbManager execute:imgQuery];
                
            }else{
                if ([itemID isKindOfClass:[NSNull class]]) {
                    itemID =@"";
                }
//                if ([deletedItemImgID isKindOfClass:[NSNull class]]||(deletedItemImgID==0)) {
//                 deletedItemImgID =@"";
//                  }
                
                [dbManager execute:[NSString stringWithFormat:@"Update Item set SyncStatus='Update' where ID = '%@'",itemID]];
                [dbManager execute:[NSString stringWithFormat:@"Update Images set SyncStatus='Delete' where ID = '%d'",deletedItemImgID]];
            }
            
            NSMutableArray *imgPathAry = [[NSMutableArray alloc]init];
            [dbManager execute:[NSString stringWithFormat:@"SELECT ImagePath FROM Images Where ID = '%d' ",deletedItemImgID] resultsArray:imgPathAry];
            NSLog(@"serverIDAry %@", imgPathAry);

            NSString *imgPath;
            if ([imgPathAry count] !=0) {
                NSDictionary *tempDict = [imgPathAry objectAtIndex:0];
                imgPath = [tempDict valueForKey:@"ImagePath"];
                NSLog(@"serverID %@", imgPath);
                if (imgPath.length !=0) {
                    [self removeImage:imgPath];
                }
            }

            
            [self drawAttchmentsView];
        }
    }
    
    [deleteItemImgBtn removeFromSuperview];
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


-(void)cellPanForInfoView:(UIPanGestureRecognizer *)recognizer{
    
    CGPoint translate = [recognizer translationInView:recognizer.view];
    
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (recognizer.view.bounds.size.width / 2.0)){
        // moving right (and/or flicked right)
    }else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(recognizer.view.frame.size.width / 2.0))
    {
        // moving left (and/or flicked left)
        [self itemPropertiesBtnBtnClicked:nil];
        
    }
    
    
    //    if (velocity.x > 0)
    //    {
    //        NSLog(@"right");
    //        // user dragged towards the right
    //    }
    //    else
    //    {
    //        NSLog(@"left");
    //
    //        // user dragged towards the left
    //    }
}




-(void)cellPanForPropView:(UIPanGestureRecognizer *)recognizer{
    
    CGPoint translate = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (recognizer.view.bounds.size.width / 2.0)){
        [self itemInfoBtnClicked:nil];
        
        // moving right (and/or flicked right)
    }else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(recognizer.view.frame.size.width / 2.0))
    {
        // moving left (and/or flicked left)
        if (menuUploadPhotosAlertViewFirstTime == YES) {
            if (itemID.length ==0) {
                if (itemAdded == YES) {
                    int tempItemID = [self lastInsertedItemRowID];
                    itemID = [NSString stringWithFormat:@"%d", tempItemID];
                }else{
                    menuUploadPhotosAlertViewFirstTime = NO;
                    [FAUtilities showAlert:@"Please create Item before uploading a image"];
                    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeMenuAlert:) userInfo:nil repeats:NO];
                }
            }else{
                [self itemUploadsBtnClicked:nil];
            }
        }
        
    }
    //    CGPoint vel = [recognizer velocityInView:self.view];
    //    if (vel.x > 0)
    //    {
    //        NSLog(@"right");
    //        [self itemInfoBtnClicked:nil];
    //
    //        // user dragged towards the right
    //    }
    //    else
    //    {
    //        NSLog(@"left");
    //        [self itemUploadsBtnClicked:nil];
    //
    //        // user dragged towards the left
    //    }
}

-(void)changeMenuAlert:(NSTimer *)timer;
{
    menuUploadPhotosAlertViewFirstTime = YES;
}


-(void)cellPanForUploads:(UIPanGestureRecognizer *)recognizer{
    CGPoint translate = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (recognizer.view.bounds.size.width / 2.0)){
        [self itemPropertiesBtnBtnClicked:nil];
        
        // moving right (and/or flicked right)
    }else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(recognizer.view.frame.size.width / 2.0))
    {
        // moving left (and/or flicked left)
        
    }
    
    
    
    //    CGPoint vel = [recognizer velocityInView:self.view];
    //
    //    UIView *currentView = recognizer.view;
    //
    //    NSLog(@"currentView %@", currentView);
    //
    //    if (vel.x > 0)
    //    {
    //        NSLog(@"right");
    //        [self itemPropertiesBtnBtnClicked:nil];
    //
    //        // user dragged towards the right
    //    }
    //    else
    //    {
    //        NSLog(@"left");
    //
    //        // user dragged towards the left
    //    }
    
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



// new view


-(IBAction)itemInfoBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    
    [itemInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [itemPropertiesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [itemUploadsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    itemInformationView.hidden = NO;
    itemUploadsView.hidden = YES;
    itemPropertieView.hidden = YES;
    
    if (activeBtnTag == 2 || activeBtnTag == 3) {
        [self leftAnimation:itemInformationView];
    }
    
    activeBtnTag=itemInfoBtn.tag;
    
}

-(void)rightAnimation:(UIView *)aView {
    
    CATransition *transition = [CATransition animation];
    transition.type =kCATransitionPush;
    [transition setSubtype:kCATransitionFromRight];
    transition.duration = 0.5f;
    transition.delegate = self;
    [aView.layer addAnimation:transition forKey:nil];
}


-(void)leftAnimation:(UIView *)aView {
    
    CATransition *transition = [CATransition animation];
    transition.type =kCATransitionPush;
    [transition setSubtype:kCATransitionFromLeft];
    transition.duration = 0.5f;
    transition.delegate = self;
    [aView.layer addAnimation:transition forKey:nil];
}



-(IBAction)itemPropertiesBtnBtnClicked:(id)sender{
    
    [self.view endEditing:YES];
    itemPropertiesScrollView.contentSize = CGSizeMake(itemPropertiesScrollView.frame.size.width, 1050);
    
    [itemInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [itemPropertiesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [itemUploadsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    itemInformationView.hidden = YES;
    itemUploadsView.hidden = YES;
    itemPropertieView.hidden = NO;
    
    if (activeBtnTag == 1) {
        [self rightAnimation:itemPropertieView];
    }else if (activeBtnTag == 3){
        [self leftAnimation:itemPropertieView];
    }
    
    activeBtnTag=itemPropertiesBtn.tag;
    
    //    [UIView animateWithDuration:1.0
    //                          delay: 1.0
    //                        options: UIViewAnimationOptionCurveEaseIn //UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
    //                     animations:^{
    //                         itemInformationView.hidden = YES;
    //                         itemPropertieView.hidden = NO;
    //                         itemUploadsView.hidden = YES;
    //                     }
    //                     completion:nil];
}

-(IBAction)itemUploadsBtnClicked:(id)sender{
    [deleteItemImgBtn removeFromSuperview];
    [self.view endEditing:YES];
    
    if (itemID.length ==0) {
        if (itemAdded == YES) {
            int tempItemID = [self lastInsertedItemRowID];
            itemID = [NSString stringWithFormat:@"%d", tempItemID];
        }else{
            [FAUtilities showAlert:@"Please create Item before uploading a image"];
        }
    }else{
        [itemInfoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [itemPropertiesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [itemUploadsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        itemInformationView.hidden = YES;
        itemPropertieView.hidden = YES;
        itemUploadsView.hidden = NO;
        
        if (activeBtnTag == 2 || activeBtnTag == 1) {
            [self rightAnimation:itemUploadsView];
        }
//        [self showSimple:nil];
        [self drawAttchmentsView];
        activeBtnTag=itemUploadsBtn.tag;
    }
}


- (void)showSimple:(id)sender {
    
    //    AddItemViewController *currentVC = (AddItemViewController *)sender;
    
    
	// The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(exeMethod) onTarget:self withObject:nil animated:YES];
}

- (void)hideSimple:(id)sender {
    [HUD removeFromSuperview];
}


//- (void)myTask {
//	// Do something usefull in here instead of sleeping ...
////    BOOL val = [self drawAttchmentsView];
//    
////    if (val == YES) {
////        [self hideSimple:nil];
////    }
//    	sleep(30);
//}


- (void)exeMethod {
	// Do something usefull in here instead of sleeping ...
    BOOL val = [self drawAttchmentsView];
    if (val == YES) {
        [self hideSimple:nil];
    }
    //	sleep(30);
}




-(int)lastInsertedItemRowID{
    
    dbManager =[DataBaseManager dataBaseManager];
    NSMutableArray *idAry = [[NSMutableArray alloc]init];
    [dbManager execute:[NSString stringWithFormat:@"SELECT * from SQLITE_SEQUENCE;"] resultsArray:idAry];
    NSLog(@"ID Ary %@", idAry);
    
    NSString *seqVal;
    for (int i=0; i<[idAry count]; i++) {
        NSDictionary *tempDict = [idAry objectAtIndex:i];
        if ([[tempDict valueForKey:@"name"] isEqualToString:@"Item"]) {
            seqVal = [[idAry objectAtIndex:i] valueForKey:@"seq"];
        }
        
    }
    int rowID = [seqVal intValue];
    return rowID;
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if(theTextField.returnKeyType==UIReturnKeySearch)
    {
        NSLog(@"search"); //Your search key code
    }
//    if ([valueForColumn rangeOfString:@","].location == NSNotFound) {
//        NSLog(@"string does not contain ,");
//    } else {
//        NSLog(@"string contains ,!");

    return YES;
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    [deleteItemImgBtn removeFromSuperview];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_View_1024x1024.png"]];
    self.view.backgroundColor = [UIColor whiteColor];

    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbarpotrait.png"] forBarMetrics:UIBarMetricsDefault];
    }else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
}




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.itemImagePopOver dismissPopoverAnimated:YES];
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [photoSheet dismissWithClickedButtonIndex:0 animated:YES];
    [photoPopOver dismissPopoverAnimated:YES];
    
    itemPropertiesScrollView.contentSize = CGSizeMake(itemPropertiesScrollView.frame.size.width, 1040);
    //    [self performSelectorInBackground:@selector(drawAttchmentsView) withObject:nil];
//    [self performSelectorOnMainThread:@selector(drawAttchmentsView) withObject:nil waitUntilDone:YES];
      [self drawAttchmentsView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
