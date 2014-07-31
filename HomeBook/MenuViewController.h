//
//  MenuViewController.h
//  RoyalHouseManagement
//
//  Created by Manulogix on 21/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseManager.h"
#import "MBProgressHUD.h"

@interface SWUITableViewCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *label;

@end

@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,MBProgressHUDDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>{
    NSMutableArray *rowsAry;
    NSMutableArray *rowIDAry;
    NSMutableArray *rowHouseIDAry;
    UIPopoverController *popOver;
    MBProgressHUD *HUD;
    NSArray *searchResults;
    NSString *searchValString;
    NSMutableArray *secAry;
    NSMutableArray *secIDAry;
    NSMutableArray *secHouseIDAry;

    NSMutableArray *secRowAry;
    NSMutableArray *secRowIDAry;
    NSMutableArray *secRowHouseIDAry;
    
    IBOutlet UIView *houseNameEditView;
    IBOutlet UITextField *houseNameEditTextField;
    IBOutlet UIButton *saveBtn;
    IBOutlet UIButton *cancelBtn;

    NSString *editedText;
    
    // search items
    
    IBOutlet UITextField *searchTextField;
    BOOL isSearching;
    NSMutableArray *searchHousesArray;
    NSMutableArray *searchRoomsArray;
    NSMutableArray *searchItemsArray;

    
    
    
    DataBaseManager *dbManager;
    
    IBOutlet UITableView *menuTableview;
    IBOutlet UIButton    *addHouseBtn;
    
    
    UIButton *clearButton;
    
    BOOL longPressBtnClicked;
    
//    UIImageView *rowImgView;
//    UIImageView *houseRowImgView;
//    UIImageView *roomRowImgView;
    

    
}
//-(IBAction)searchCancelBtnClicked:(id)sender;

-(IBAction)addHouseBtnClicked:(id)sender;
-(IBAction)houseEditSaveClicked:(id)sender;
@property(nonatomic,retain)UIPopoverController *popOver;

@end
