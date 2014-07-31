//
//  MenuViewController.m
//  RoyalHouseManagement
//
//  Created by Manulogix on 21/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "MenuViewController.h"
#import "DashBoardViewController.h"
#import "ContainerViewController.h"

@implementation SWUITableViewCell
@end

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize popOver;
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
//    searchTextField.layer.borderColor = [UIColor colorWithRed:127/255.0f green:92/255.0f blue:50/255.0f alpha:1.0].CGColor;
//    searchTextField.layer.borderWidth = 2;
    
    searchTextField.layer.borderColor = [UIColor blackColor].CGColor;
    searchTextField.layer.borderWidth = 1;

    [searchTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 35)];
    searchTextField.leftView = leftView1;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.layer.borderColor = [UIColor blackColor].CGColor;
    searchTextField.layer.borderWidth = 1;
    
    
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
    [clearButton setFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)]; // Required for iOS7
    searchTextField.rightView = clearButton;
    [clearButton addTarget:self action:@selector(clearSearchText:) forControlEvents:UIControlEventTouchUpInside];
    searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
   
    self.view.backgroundColor =[UIColor whiteColor];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];

    if (searchTextField.text.length == 0) {
        isSearching = NO;
        [defaults setObject:[NSString stringWithFormat:@"%d",isSearching] forKey:@"Searching"];

    }else{
        isSearching = YES;
        [defaults setObject:[NSString stringWithFormat:@"%d",isSearching] forKey:@"Searching"];
    }
    
    [defaults setObject:nil forKey:@"SearchRoomsArray"];

	// Do any additional setup after loading the view.
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES; // So that I can determine whether or not to perform the segue based on app logic
}

-(void)viewWillAppear:(BOOL)animated{
    
    //    menuTableview.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot.png"]];
    searchRoomsArray = [[NSMutableArray alloc]init];
    searchHousesArray = [[NSMutableArray alloc]init];
    searchItemsArray = [[NSMutableArray alloc]init];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *temp = [defaults objectForKey:@"MakeTextFieldEmpty"];

    if ([temp isEqualToString:@"YES"]) {
        isSearching = NO;
        [defaults setObject:[NSString stringWithFormat:@"%d",isSearching] forKey:@"Searching"];
        searchTextField.text =@"";
        [defaults setObject:@"NO" forKey:@"MakeTextFieldEmpty"];
    }
    
    dbManager = [DataBaseManager dataBaseManager];
    // for getting item of same users
    
    
    NSMutableArray *housesIDAry = [[NSMutableArray alloc]init];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
    [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM House Where SyncStatus ='New' or SyncStatus ='Update' or SyncStatus ='Sync' and UserID = '%@'",user_Server_ID] resultsArray:housesIDAry];
    
    
    
    NSMutableString *formattedhouseIdsStr = [[NSMutableString alloc]init];
    
    if(housesIDAry.count > 0){
        for(int i=0; i<[housesIDAry count]; i++){
            
            NSDictionary *tempDict = [housesIDAry objectAtIndex:i];
            NSString *houseId = [tempDict objectForKey:@"ID"];
            
            NSLog(@"house id %@", houseId);
            NSString *tempStr = [NSString stringWithFormat:@"Item.HouseID='%@'",houseId];
            [formattedhouseIdsStr appendString:[NSString stringWithFormat:@"%@ or ", tempStr]];
            
        }
        
        NSRange range1 = NSMakeRange([formattedhouseIdsStr length]-3,3);
        [formattedhouseIdsStr replaceCharactersInRange:range1 withString:@""];
        
        NSLog(@"formattedhouseIdsStr %@",formattedhouseIdsStr);
    }
        

    
    NSMutableArray *searchItemDetailsAry = [[NSMutableArray alloc]init];
    
    if (formattedhouseIdsStr.length !=0) {
        [dbManager execute:[NSString stringWithFormat:@"select Item.id as ItemId,Item.name as ItemName,Item.ServerId as ItemServerId,Room.id as RoomId,Room.name as RoomName, Room.ServerId as RoomServerId,House.Id as HouseId,House.name as HouseName, house.ServerId as HouseServerID from Item left join Room on item.roomid = room.id left join House on item.houseid = house.id where item.SyncStatus != 'Delete' and item.name like '%%%@%%' and (%@)",searchTextField.text,formattedhouseIdsStr] resultsArray:searchItemDetailsAry];
    }
    
    NSLog(@"searchItemDetailsAry %@", searchItemDetailsAry);
    
    
    for (int i=0; i<[searchItemDetailsAry count]; i++) {
        
        NSString *houseID = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"HouseId"];
        NSString *houseName = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"HouseName"];
        NSString *houseServerId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"HouseServerID"];
        
        [self loadHouseArray:houseID withName:houseName withServerID:houseServerId];
        
        NSString *roomId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"RoomId"];
        NSString *roomName = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"RoomName"];
        NSString *roomServerId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"RoomServerId"];
        
        
        [self loadRoomArray:houseID withRoomID:roomId withName:roomName withServerID:roomServerId];
        
        
        NSString *itemId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"ItemId"];
        NSString *itemName = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"ItemName"];
        NSString *itemServerId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"ItemServerId"];
        
        [self loadItemsArray:houseID withRoomID:roomId withItemID:itemId withName:itemName withServerID:itemServerId];
        
//            [self loadItemImagesArray:imgId withImgServerPath:imgSerPath withServerID:imgServerId withImgData:imgData withLocalImgPath:imgLocalPath withItemID:itemId withRoomID:roomId];
    }
    [menuTableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"menu view will disappear ");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (isSearching == YES) {
        [defaults setObject:[NSString stringWithFormat:@"%d",isSearching] forKey:@"Searching"];
        [defaults setObject:searchTextField.text forKey:@"SearchValue"];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        UIViewController *containerVC = [sb instantiateViewControllerWithIdentifier:@"ContainerViewController"];
        
//        [self presentViewController:containerVC animated:NO completion:nil];

//        ContainerViewController *containerVC = [[ContainerViewController alloc]initWithNibName:@"ContainerViewController" bundle:nil];
        [containerVC viewDidLoad];
        [containerVC viewWillAppear:YES];
    }else{
        
    }
}
- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:
    if ( [segue.destinationViewController isKindOfClass: [DashBoardViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        UILabel* c = [(SWUITableViewCell *)sender label];
        DashBoardViewController* cvc = segue.destinationViewController;
        NSLog(@"c and cvs %@- %@", c , cvc);
    }
    
    // configure the segue.
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        SWRevealViewController* rvc = self.revealViewController;
        NSAssert( rvc != nil, @"oops! must have a revealViewController" );
        NSAssert( [rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );
        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:dvc];
            [rvc setFrontViewController:nc animated:YES];
        };
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    longPressBtnClicked = NO;
    
    [self hideSimple:nil];
    dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *housesAry = [[NSMutableArray alloc]init];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
    if (isSearching == NO) {
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where SyncStatus ='New' or SyncStatus ='Update' or SyncStatus ='Sync' and UserID = '%@'",user_Server_ID] resultsArray:housesAry];

    }else{
        housesAry = searchHousesArray;
    }
    
    
    secAry              = [[NSMutableArray alloc]init];
    secIDAry            = [[NSMutableArray alloc]init];
    secRowAry           = [[NSMutableArray alloc]init];
    secRowIDAry         = [[NSMutableArray alloc]init];
    secRowHouseIDAry    = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[housesAry count]; i++) {
        NSDictionary *tempDict = [housesAry objectAtIndex:i];
        [secAry addObject:[tempDict valueForKey:@"Name"]];
        [secIDAry addObject:[tempDict valueForKey:@"ID"]];
        [secHouseIDAry addObject:[tempDict valueForKey:@"HouseID"]];
    }
    return [secAry count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   dbManager = [DataBaseManager dataBaseManager];
    NSMutableArray *roomsAry = [[NSMutableArray alloc]init];
    
    

    if (isSearching == NO) {
        [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Room Where HouseID = '%@' AND (SyncStatus = 'Sync' or SyncStatus = 'New' or SyncStatus = 'Update')",[secIDAry objectAtIndex:section]] resultsArray:roomsAry];

    }else{
        NSMutableArray *searchTempRoomsAry = [[NSMutableArray alloc]init];
        
        for (int i=0; i<[searchRoomsArray count]; i++) {
            NSDictionary *tempDict = [searchRoomsArray objectAtIndex:i];
            NSString *houseID = [tempDict objectForKey:@"HouseID"];
            if ([houseID isEqualToString:[secIDAry objectAtIndex:section]]) {
                [searchTempRoomsAry addObject:tempDict];
            }
        }
        
        roomsAry = searchTempRoomsAry;
    }
    
    
    
    rowsAry = [[NSMutableArray alloc]init];
    rowIDAry = [[NSMutableArray alloc]init];
    rowHouseIDAry = [[NSMutableArray alloc]init];
    
    [rowsAry addObject:[secAry objectAtIndex:section]];
    [rowIDAry addObject:[secIDAry objectAtIndex:section]];
    [rowHouseIDAry addObject:@""];
    
        for (int i=0; i<[roomsAry count]; i++) {
            NSDictionary *tempDict = [roomsAry objectAtIndex:i];
            [rowsAry addObject:[tempDict valueForKey:@"Name"]];
            [rowIDAry addObject:[tempDict valueForKey:@"ID"]];
            [rowHouseIDAry addObject:[tempDict valueForKey:@"HouseID"]];
            
        }
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *tempIDDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *tempHouseIDDict = [[NSMutableDictionary alloc]init];
    
    
    [tempDict setValue:rowsAry forKey:[NSString stringWithFormat:@"Section%ld",(long)section]];
    [tempIDDict setValue:rowIDAry forKey:[NSString stringWithFormat:@"Section%ld",(long)section]];
    [tempHouseIDDict setValue:rowHouseIDAry forKey:[NSString stringWithFormat:@"Section%ld",(long)section]];
    
    [secRowAry addObject:tempDict];
    [secRowIDAry addObject:tempIDDict];
    [secRowHouseIDAry addObject:tempHouseIDDict];
    
//    if ([searchArray count]>0) {
//        return [searchArray count]+1;
//    }else{
        return [roomsAry count]+1;
//    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    UILabel* detailTextLabel = nil;
    UIImageView *imageView = nil;
    UIFont *myFont;
    NSString *rowValue;
    UIColor *cellColor;
    CGFloat rowHeight;
    NSArray *tempAry;
    if (!cell) {
        cell = [[SWUITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }else{
        cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        detailTextLabel = (UILabel*)[cell.contentView viewWithTag:102];
        imageView = (UIImageView*)[cell.contentView viewWithTag:103];
    }
    
    NSString *key = [NSString stringWithFormat:@"Section%ld",(long)indexPath.section];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressNameEdit:)];
    [cell addGestureRecognizer:longPress];
    cell.backgroundColor = [UIColor clearColor];
    tableView.contentInset =UIEdgeInsetsZero;
    
    for (int i=0; i<[secRowAry count]; i++) {
        NSDictionary *tempDict = [secRowAry objectAtIndex:i];
        tempAry = [tempDict valueForKey:key];
        
        if (tempAry.count !=0) {
            if (indexPath.row == 0) {
                
                myFont = [ UIFont fontWithName: @"HelveticaNeue-Regular" size: 22.0 ];
                rowValue = [NSString stringWithFormat:@"%@",[tempAry objectAtIndex:indexPath.row]];
                cellColor = [UIColor colorWithRed:241.0f/255.0f green:241.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
                cell.backgroundColor = cellColor;
                rowHeight = [self heightForText:rowValue Font:myFont];
                
                detailTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 5.0f, 220.0f, rowHeight)];
                detailTextLabel.text =@"";
                detailTextLabel.tag = 101;
                [cell.contentView addSubview:detailTextLabel];
            }else{
                
                myFont = [ UIFont fontWithName: @"HelveticaNeue-Regular" size: 20.0 ];
                rowValue = [NSString stringWithFormat:@"%@",[tempAry objectAtIndex:indexPath.row]];
                cellColor =[UIColor whiteColor];
                rowHeight = [self heightForText:rowValue Font:myFont];
                
                detailTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(25.0f, 5.0f, 220.0f, rowHeight)];
                detailTextLabel.text =@"";
                detailTextLabel.tag = 101;
                [cell.contentView addSubview:detailTextLabel];
                
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 20, rowHeight)];
                imageView.tag = 103;
                [cell.contentView addSubview:imageView];
            }
            break;
        }
    }
    
    detailTextLabel.text= rowValue;
    detailTextLabel.font = myFont;
    detailTextLabel.backgroundColor=[UIColor clearColor];
    detailTextLabel.lineBreakMode= NSLineBreakByWordWrapping;
    detailTextLabel.textColor=[UIColor blackColor];
    detailTextLabel.numberOfLines = 0;
    detailTextLabel.minimumScaleFactor=0.5;
    [detailTextLabel sizeToFit];
    detailTextLabel.adjustsFontSizeToFitWidth = YES;
    detailTextLabel.backgroundColor =cellColor;
    return cell;
}
- (CGFloat)heightForText:(NSString *)bodyText Font:(UIFont *)cellFont
{
    CGSize constraintSize = CGSizeMake(220, MAXFLOAT);
    CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = labelSize.height + 10;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSArray *tempAry;
    UILabel* detailTextLabel = nil;
    UIImageView *imageView = nil;
    UIFont *myFont;
    NSString *rowValue;
    UIColor *cellColor;
    CGFloat rowHeight;
    
    if (!cell) {
        cell = (SWUITableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        cell= (UITableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        detailTextLabel = (UILabel*)[cell.contentView viewWithTag:102];
        imageView = (UIImageView*)[cell.contentView viewWithTag:103];
    }
    
    
    NSString *key = [NSString stringWithFormat:@"Section%ld",(long)indexPath.section];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressNameEdit:)];
    [cell addGestureRecognizer:longPress];
    cell.backgroundColor = [UIColor clearColor];
    tableView.contentInset =UIEdgeInsetsZero;
    
    for (int i=0; i<[secRowAry count]; i++) {
        NSDictionary *tempDict = [secRowAry objectAtIndex:i];
        tempAry = [tempDict valueForKey:key];
        
        if (tempAry.count !=0) {
            if (indexPath.row == 0) {
                
                myFont = [ UIFont fontWithName: @"HelveticaNeue-Regular" size: 22.0 ];
                rowValue = [NSString stringWithFormat:@"%@",[tempAry objectAtIndex:indexPath.row]];
                cellColor = [UIColor colorWithRed:241.0f/255.0f green:241.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
                cell.backgroundColor = cellColor;
                rowHeight = [self heightForText:rowValue Font:myFont];
                
                detailTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 5.0f, 220.0f, rowHeight)];
                detailTextLabel.text =@"";
                detailTextLabel.tag = 101;
                [cell.contentView addSubview:detailTextLabel];
            }else{
                
                myFont = [ UIFont fontWithName: @"HelveticaNeue-Regular" size: 20.0 ];
                rowValue = [NSString stringWithFormat:@"%@",[tempAry objectAtIndex:indexPath.row]];
                cellColor =[UIColor whiteColor];
                rowHeight = [self heightForText:rowValue Font:myFont];
                
                detailTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(25.0f, 5.0f, 220.0f, rowHeight)];
                detailTextLabel.text =@"";
                detailTextLabel.tag = 101;
                [cell.contentView addSubview:detailTextLabel];
                
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 20, rowHeight)];
                imageView.tag = 103;
                //                imageView.backgroundColor = [UIColor grayColor];
                [cell.contentView addSubview:imageView];
            }
            break;
        }
    }
    detailTextLabel.text= rowValue;
    detailTextLabel.font = myFont;
    detailTextLabel.backgroundColor=[UIColor clearColor];
    detailTextLabel.lineBreakMode= NSLineBreakByWordWrapping;
    detailTextLabel.textColor=[UIColor blackColor];
    detailTextLabel.numberOfLines = 0;
    detailTextLabel.minimumScaleFactor=0.5;
    [detailTextLabel sizeToFit];
    detailTextLabel.adjustsFontSizeToFitWidth = YES;
    detailTextLabel.backgroundColor =cellColor;
    return [self heightForText:detailTextLabel.text Font:detailTextLabel.font];
}

- (void)longPressNameEdit:(UILongPressGestureRecognizer *)gesture
{
    
    NSLog(@"menu long press");
    
    if (longPressBtnClicked == NO) {
        NSLog(@"method call");

        NSMutableArray *editedHouseAry = [[NSMutableArray alloc]init];
        NSMutableArray *editedRoomAry = [[NSMutableArray alloc]init];
        dbManager = [DataBaseManager dataBaseManager];
        

        BOOL isPressed =NO;
        
        // get affected cell
        SWUITableViewCell *cell = (SWUITableViewCell *)[gesture view];
        
        // get indexPath of cell
        NSIndexPath *indexPath = [menuTableview indexPathForCell:cell];
        
        NSString *key = [NSString stringWithFormat:@"Section%ld",(long)indexPath.section];
        
        NSArray *tempAry;
        NSArray *tempIDAry;
        NSArray *tempHouseIDAry;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        
        for (int i=0; i<[secRowAry count]; i++) {
            NSDictionary *tempDict = [secRowAry objectAtIndex:i];
            NSDictionary *tempIDDict = [secRowIDAry objectAtIndex:i];
            NSDictionary *tempHouseIDDict = [secRowHouseIDAry objectAtIndex:i];
            
            tempAry = [tempDict valueForKey:key];
            tempIDAry = [tempIDDict valueForKey:key];
            tempHouseIDAry = [tempHouseIDDict valueForKey:key];
            
            if (tempAry.count !=0) {
                [defaults setObject:[tempAry objectAtIndex:indexPath.row] forKey:@"Name"];
                [defaults setObject:[tempAry objectAtIndex:0] forKey:@"CurrentHouseName"];
                [defaults setObject:[tempIDAry objectAtIndex:indexPath.row] forKey:@"ID"];
                [defaults setObject:[tempHouseIDAry objectAtIndex:indexPath.row] forKey:@"HouseID"];
                [defaults setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"RowID"];
                [defaults setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.section] forKey:@"SectionID"];
                
                NSLog(@"Cell Text:%@",cell.textLabel.text);
                NSLog(@"selected Name Text:%@",[tempAry objectAtIndex:indexPath.row]);
//                NSLog(@"Long-pressed cell at RowID %d", indexPath.row);
                NSLog(@"Long-pressed cell at ID %@",  [tempIDAry objectAtIndex:indexPath.row]);
                NSLog(@"Long-pressed cell at house ID%@", [tempHouseIDAry objectAtIndex:indexPath.row]);
                NSLog(@"Long-pressed cell at Name %@", [tempAry objectAtIndex:indexPath.row]);
                NSLog(@"Long-pressed cell at CurrentHouseName %@", [tempAry objectAtIndex:0]);
//                NSLog(@"Long-pressed cell at SectionID %d", indexPath.section);
                
                if (indexPath.row==0) {
                    [defaults setObject:@"EditHouse" forKey:@"viewType"];
                    [defaults setObject:@"House" forKey:@"Type"];
                    
                    NSLog(@"updateHouse");
                    NSLog(@"ID:%@",[tempIDAry objectAtIndex:indexPath.row]);
                    
                    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where ID='%@'",[tempIDAry objectAtIndex:indexPath.row]] resultsArray:editedHouseAry];
                    [defaults setObject:editedHouseAry forKey:@"EditHouseNameArray"];
                    NSLog(@"Edited HouseArray:%@",editedHouseAry);
                    isPressed =YES;
                }else{
                    
                    NSLog(@"updateRoom");
                    NSLog(@"RoomId:%@",[tempIDAry objectAtIndex:indexPath.row]);
                    
                    NSLog(@"HouseId:%@",[tempHouseIDAry objectAtIndex:indexPath.row]);
                    [defaults setObject:@"EditRoom" forKey:@"viewType"];
                    [defaults setObject:@"Room" forKey:@"Type"];
                    
                    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM Room Where ID='%@' and HouseID='%@'",[tempIDAry objectAtIndex:indexPath.row],[tempHouseIDAry objectAtIndex:indexPath.row]] resultsArray:editedRoomAry];
                    [defaults setObject:editedRoomAry forKey:@"EditRoomNameArray"];
                    NSLog(@"Edited RoomArray:%@",editedRoomAry);
                    isPressed =YES;
                    
                }
                break;
            }
        }
        if (isPressed==YES) {
            [self performSegueWithIdentifier:@"CellToView" sender:nil];
        }
        longPressBtnClicked = YES;
    }
}


-(IBAction)cancelEditClicked:(id)sender{
    houseNameEditView.hidden = YES;
}


-(IBAction)houseEditSaveClicked:(id)sender{
    
    [self.view endEditing:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *name= [defaults valueForKey:@"Name"];
    NSString *idVal= [defaults valueForKey:@"ID"];
    NSString *houseID=[defaults valueForKey:@"HouseID"];
    NSString *rowID= [defaults valueForKey:@"RowID"];
    
    NSLog(@" RowID %@", rowID);
    NSLog(@" ID %@",  idVal);
    NSLog(@"house ID%@", houseID);
    NSLog(@"Name %@", name);
    dbManager = [DataBaseManager dataBaseManager];
    
    
    if (houseID.length==0) {
        houseID=idVal;
    }
    NSString *str;
    NSRange first = [name rangeOfComposedCharacterSequenceAtIndex:0];
    NSRange second = [name rangeOfComposedCharacterSequenceAtIndex:1];
    NSRange third = [name rangeOfComposedCharacterSequenceAtIndex:2];
    NSRange fourth = [name rangeOfComposedCharacterSequenceAtIndex:3];
    
    NSRange match = [name rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:0 range:first];
    if (match.location != NSNotFound) {
        // codeString starts with a letter
    }else{
        str =[name stringByReplacingCharactersInRange:first withString:@""];
        str =[name stringByReplacingCharactersInRange:second withString:@""];
        str =[name stringByReplacingCharactersInRange:third withString:@""];
        str =[name stringByReplacingCharactersInRange:fourth withString:@""];
        
    }
    
    
    if ([rowID isEqual:@"0"]) {
        NSLog(@"updateHouse");
        if ([editedText isKindOfClass:[NSNull class]]||(editedText.length==0)) {
            editedText =@"";
        }
        if ([houseID isKindOfClass:[NSNull class]]) {
            houseID =@"";
        }
        editedText = [editedText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

        NSLog(@"Name = '%@'  where House ID = '%@' ",editedText,houseID);
        [dbManager execute:[NSString stringWithFormat:@"Update House set Name ='%@',SyncStatus='Update' where ID = '%@'",editedText,houseID]];
        
    }else{
        NSLog(@"updateRoom");
        
        if ([editedText isKindOfClass:[NSNull class]]||(editedText.length==0)) {
            editedText =@"";
        }
        if ([idVal isKindOfClass:[NSNull class]]) {
            idVal =@"";
        } if ([houseID isKindOfClass:[NSNull class]]) {
            houseID =@"";
        }
        editedText = [editedText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

        NSLog(@"Name = '%@'  where Room ID = '%@',HouseID='%@'",editedText,idVal,houseID);
        [dbManager execute:[NSString stringWithFormat:@"Update Room set Name ='%@',SyncStatus='Update'  where ID = '%@' and HouseID='%@'",editedText,idVal,houseID]];
        
        
    }
    
    [menuTableview reloadData];
    houseNameEditView.hidden=YES;
    
    //    [dbManager execute:[NSString stringWithFormat:@"Update House set Name = '%@'  where ID = '%@'",name,houseID]];
    NSLog(@"houseEditSavedClicked:");
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    editedText = textField.text;
    NSLog(@"edited Text:%@",editedText);
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    isSearching = YES;

    searchRoomsArray = [[NSMutableArray alloc]init];
    searchHousesArray = [[NSMutableArray alloc]init];
    searchItemsArray = [[NSMutableArray alloc]init];
    
    
    NSLog(@"text field %@",textField.text);
    NSLog(@"string %@",string);

    NSString *searchingStr = [NSString stringWithFormat:@"%@%@",textField.text,string];

    if (textField.text.length == 1 && searchingStr.length ==1) {
        isSearching = NO;
    }
    dbManager = [DataBaseManager dataBaseManager];
    
    
    // for getting item of same user
    
    
    NSMutableArray *housesIDAry = [[NSMutableArray alloc]init];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];
    [dbManager execute:[NSString stringWithFormat:@"SELECT ID FROM House Where SyncStatus ='New' or SyncStatus ='Update' or SyncStatus ='Sync' and UserID = '%@'",user_Server_ID] resultsArray:housesIDAry];
    
    NSMutableString *formattedhouseIdsStr = [[NSMutableString alloc]init];
    
    if (housesIDAry.count >0) {
        for(int i=0; i<[housesIDAry count]; i++){
            
            NSDictionary *tempDict = [housesIDAry objectAtIndex:i];
            NSString *houseId = [tempDict objectForKey:@"ID"];
            
            NSLog(@"house id %@", houseId);
            NSString *tempStr = [NSString stringWithFormat:@"Item.HouseID='%@'",houseId];
            [formattedhouseIdsStr appendString:[NSString stringWithFormat:@"%@ or ", tempStr]];
            
        }
        
        NSRange range1 = NSMakeRange([formattedhouseIdsStr length]-3,3);
        [formattedhouseIdsStr replaceCharactersInRange:range1 withString:@""];
        NSLog(@"formattedhouseIdsStr %@",formattedhouseIdsStr);
    }

    
    NSMutableArray *searchItemDetailsAry = [[NSMutableArray alloc]init];
    if (formattedhouseIdsStr.length !=0) {
        [dbManager execute:[NSString stringWithFormat:@"select Item.id as ItemId,Item.name as ItemName,Item.ServerId as ItemServerId,Room.id as RoomId,Room.name as RoomName, Room.ServerId as RoomServerId,House.Id as HouseId,House.name as HouseName, house.ServerId as HouseServerID from Item left join Room on item.roomid = room.id left join House on item.houseid = house.id where item.SyncStatus != 'Delete' and item.name like '%%%@%%' and (%@)",searchingStr,formattedhouseIdsStr] resultsArray:searchItemDetailsAry];

    }
    NSLog(@"searchItemDetailsAry %@", searchItemDetailsAry);
    
    
    for (int i=0; i<[searchItemDetailsAry count]; i++) {
       
        NSString *houseID = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"HouseId"];
        NSString *houseName = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"HouseName"];
        NSString *houseServerId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"HouseServerID"];
        
        [self loadHouseArray:houseID withName:houseName withServerID:houseServerId];
        
        NSString *roomId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"RoomId"];
        NSString *roomName = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"RoomName"];
        NSString *roomServerId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"RoomServerId"];
        
        
        [self loadRoomArray:houseID withRoomID:roomId withName:roomName withServerID:roomServerId];
        
        
        NSString *itemId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"ItemId"];
        NSString *itemName = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"ItemName"];
        NSString *itemServerId = [[searchItemDetailsAry objectAtIndex:i]valueForKey:@"ItemServerId"];

        [self loadItemsArray:houseID withRoomID:roomId withItemID:itemId withName:itemName withServerID:itemServerId];
        
//        [self loadItemImagesArray:imgId withImgServerPath:imgSerPath withServerID:imgServerId withImgData:imgData withLocalImgPath:imgLocalPath withItemID:itemId withRoomID:roomId];
        
    }
    
    [menuTableview reloadData];
    return YES;
}


-(void)loadHouseArray:(NSString *)houseID withName:(NSString *)houseName withServerID:(NSString *)serverID{
    BOOL isHouseExists = NO;
    
    for (int i=0; i<[searchHousesArray count]; i++) {
        NSDictionary *tempDict = [searchHousesArray objectAtIndex:i];
        if ([[tempDict valueForKey:@"ID"] isEqualToString:houseID]) {
            isHouseExists = YES;
            break;
        }
    }
    if (isHouseExists == NO) {
        NSMutableDictionary *houseDictionary = [[NSMutableDictionary alloc]init];
        [houseDictionary setObject:houseID forKey:@"ID"];
        [houseDictionary setObject:houseName forKey:@"Name"];
        [houseDictionary setObject:serverID forKey:@"HouseServerId"];
        [searchHousesArray addObject:houseDictionary];
    }
}

-(void)loadRoomArray:(NSString *)houseID withRoomID:(NSString *)roomID withName:(NSString *)roomName withServerID:(NSString *)serverID{
    BOOL isRoomExists = NO;
    
    for (int i=0; i<[searchRoomsArray count]; i++) {
        NSDictionary *tempDict = [searchRoomsArray objectAtIndex:i];
        if ([[tempDict valueForKey:@"ID"] isEqualToString:roomID]) {
            isRoomExists = YES;
            break;
        }
    }
    if (isRoomExists == NO) {
        NSMutableDictionary *roomDictionary = [[NSMutableDictionary alloc]init];
        [roomDictionary setObject:houseID forKey:@"HouseID"];
        [roomDictionary setObject:roomID forKey:@"ID"];
        [roomDictionary setObject:roomName forKey:@"Name"];
        [roomDictionary setObject:serverID forKey:@"RoomServerId"];
        [searchRoomsArray addObject:roomDictionary];
    }
}


-(void)loadItemsArray:(NSString *)houseID withRoomID:(NSString *)roomID withItemID:(NSString *)itemID withName:(NSString *)itemName withServerID:(NSString *)serverID{
   
    BOOL isItemExists = NO;
    
    for (int i=0; i<[searchItemsArray count]; i++) {
        NSDictionary *tempDict = [searchItemsArray objectAtIndex:i];
        if ([[tempDict valueForKey:@"ID"] isEqualToString:itemID]) {
            isItemExists = YES;
            break;
        }
    }
    if (isItemExists == NO) {
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc]init];
        [itemDictionary setObject:houseID forKey:@"HouseID"];
        [itemDictionary setObject:roomID forKey:@"RoomID"];
        [itemDictionary setObject:itemID forKey:@"ID"];
        [itemDictionary setObject:itemName forKey:@"Name"];
        [itemDictionary setObject:serverID forKey:@"itemServerId"];
        [searchItemsArray addObject:itemDictionary];
    }
}


-(void)clearSearchText:(id)sender{
    searchTextField.text=@"";
    NSLog(@"clear X Clicked");
    isSearching = NO;
    [menuTableview reloadData];
    [clearButton removeFromSuperview];
    
    [self.view endEditing:YES];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//
//    [defaults setObject:[NSString stringWithFormat:@"%d",isSearching] forKey:@"Searching"];
//
//    ContainerViewController *containerVC = [[ContainerViewController alloc]init];
//    [containerVC viewDidLoad];
//    [containerVC viewWillAppear:YES];
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    isSearching = NO;
    [menuTableview reloadData];
    NSLog(@"text field %@",textField.text);
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
       dbManager = [DataBaseManager dataBaseManager];
    if (textField == searchTextField) {
    }
    
    NSLog(@"search text %@", textField.text);
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self showSimple:nil];
    
    
    //    NSString *roomSelected;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    [defaults setObject:@"Details" forKey:@"viewType"];
    
    if (indexPath.row == 0) {
        [defaults setObject:@"House" forKey:@"Type"];
    }else{
        [defaults setObject:@"Room" forKey:@"Type"];
    }
    NSString *key = [NSString stringWithFormat:@"Section%ld",(long)indexPath.section];
    
    NSArray *tempAry;
    NSArray *tempIDAry;
    NSArray *tempHouseIDAry;
    
    for (int i=0; i<[secRowAry count]; i++) {
        NSDictionary *tempDict = [secRowAry objectAtIndex:i];
        NSDictionary *tempIDDict = [secRowIDAry objectAtIndex:i];
        NSDictionary *tempHouseIDDict = [secRowHouseIDAry objectAtIndex:i];
        
        
        tempAry = [tempDict valueForKey:key];
        tempIDAry = [tempIDDict valueForKey:key];
        tempHouseIDAry = [tempHouseIDDict valueForKey:key];
        
        if (tempAry.count !=0) {
            [defaults setObject:[tempAry objectAtIndex:indexPath.row] forKey:@"Name"];
            [defaults setObject:[tempAry objectAtIndex:0] forKey:@"CurrentHouseName"];
            [defaults setObject:[tempIDAry objectAtIndex:indexPath.row] forKey:@"ID"];
            [defaults setObject:[tempHouseIDAry objectAtIndex:indexPath.row] forKey:@"HouseID"];

            [defaults setObject:[NSString stringWithFormat:@"%d",isSearching] forKey:@"Searching"];
            [defaults setObject:searchTextField.text forKey:@"SearchValue"];
            
            [defaults setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"RowID"];
            
            
            NSMutableArray *serchedRoomAry = [[NSMutableArray alloc]init];
            
            for (int i=0; i<[searchRoomsArray count]; i++) {
                NSDictionary *tempRoomDict = [searchRoomsArray objectAtIndex:i];
                NSString *roomName = [tempRoomDict objectForKey:@"Name"];
                NSString *roomID= [tempRoomDict objectForKey:@"ID"];
                NSString *roomServerID = [tempRoomDict objectForKey:@"RoomServerId"];
                NSString *roomHouseID= [tempRoomDict objectForKey:@"HouseID"];
                
                NSString *tempHouseID;
                if (indexPath.row == 0) {
                    tempHouseID = [tempIDAry objectAtIndex:indexPath.row];
                }else{
                    tempHouseID =[tempHouseIDAry objectAtIndex:indexPath.row];
                }

                
                if ([tempHouseID isEqualToString:roomHouseID]) {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                    [tempDict setObject:roomName forKey:@"RoomName"];
                    [tempDict setObject:roomID forKey:@"RoomId"];
                    [tempDict setObject:roomServerID forKey:@"RoomServerId"];
                    [tempDict setObject:roomHouseID forKey:@"HouseId"];
                    [serchedRoomAry addObject:tempDict];
                }
            }
            
            NSMutableArray *serchedItemAry = [[NSMutableArray alloc]init];

            for (int i=0; i<[searchItemsArray count]; i++) {
                NSDictionary *tempRoomDict = [searchItemsArray objectAtIndex:i];
                NSString *itemName = [tempRoomDict objectForKey:@"Name"];
                NSString *itemID= [tempRoomDict objectForKey:@"ID"];
                NSString *itemServerID = [tempRoomDict objectForKey:@"itemServerId"];
                NSString *itemHouseID= [tempRoomDict objectForKey:@"HouseID"];
                NSString *itemRoomID= [tempRoomDict objectForKey:@"RoomID"];
                
                NSString *tempHouseID;
                
                if (indexPath.row == 0) {
                    tempHouseID = [tempIDAry objectAtIndex:indexPath.row];
                }else{
                    tempHouseID =[tempHouseIDAry objectAtIndex:indexPath.row];
                }
                
                if ([tempHouseID isEqualToString:itemHouseID]) {
                    
//                    if ([[tempIDAry objectAtIndex:indexPath.row] isEqualToString:itemRoomID]) {
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                        [tempDict setObject:itemName forKey:@"ItemName"];
                        [tempDict setObject:itemID forKey:@"ItemId"];
                        [tempDict setObject:itemServerID forKey:@"ItemServerId"];
                        [tempDict setObject:itemHouseID forKey:@"HouseId"];
                        [tempDict setObject:itemRoomID forKey:@"ItemRoomId"];
                        [serchedItemAry addObject:tempDict];
//                    }
                }
            }

            
            
            if (isSearching == YES) {
                [defaults setObject:searchHousesArray forKey:@"SearchHousesArray"];
                [defaults setObject:serchedRoomAry forKey:@"SearchRoomsArray"];
                [defaults setObject:serchedItemAry forKey:@"serchedItemAry"];
            }
            
            
//            NSLog(@"Long-pressed cell at row %d", indexPath.row);
            NSLog(@"Long-pressed cell at house%@", [tempHouseIDAry objectAtIndex:indexPath.row]);
            NSLog(@"Long-pressed cell at name %@", [tempAry objectAtIndex:indexPath.row]);
            NSLog(@"Long-pressed cell at CurrentHouseName %@", [tempAry objectAtIndex:0]);
            
            //            if ([tempAry objectAtIndex:0]) {
            //                [defaults setObject:@"" forKey:@"RoomSelected"];
            //            }else{
            //            [defaults setObject:@"YES" forKey:@"RoomSelected"];
            //            }
            break;
        }
    }
    
    [self performSegueWithIdentifier:@"CellToView" sender:nil];
    
}

- (void)showSimple:(id)sender {
	// The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
	sleep(30);
}


- (void)hideSimple:(id)sender {
    [HUD removeFromSuperview];
}

-(IBAction)addHouseBtnClicked:(id)sender{

    NSMutableArray *housesAry = [[NSMutableArray alloc]init];
    dbManager = [DataBaseManager dataBaseManager];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_Server_ID= [standardUserDefaults valueForKey:@"UserServerID"];

    [dbManager execute:[NSString stringWithFormat:@"SELECT * FROM House Where UserId='%@' And (SyncStatus ='New' or SyncStatus ='Update' or SyncStatus ='Sync')",user_Server_ID] resultsArray:housesAry];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *actionType=[defaults valueForKey:@"actionType"];
    
    
    if ([housesAry count] >= 3) {
        //        addHouseBtn.hidden = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        [defaults setObject:@"AddHouseShowAlert" forKey:@"viewType"];
        
    }else{
        //        addHouseBtn.hidden = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        [defaults setObject:@"AddHouse" forKey:@"viewType"];
         [defaults setObject:housesAry forKey:@"HousesAryONAddhouse"];
    }
    
    [self performSegueWithIdentifier:@"CellToView" sender:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
