//
//  AddItemViewController.h
//  RoyalHouseManagement
//
//  Created by Manulogix on 04/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAUtilities.h"
#import "DataBaseManager.h"
#import "ContainerViewController.h"
#import "DashBoardViewController.h"
#import "MBProgressHUD.h"

@interface AddItemViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>{//added UIActionSheetDelegate,UIImagePickerControllerDelegate, to remove warnign for imagepicker UINavigationControllerDelegate Divya
    IBOutlet UILabel        *addItemHeadingLabel;
//    IBOutlet UIScrollView   *addItemScrollView;
    CGPoint svos;
    int keyboardHeight;
    DataBaseManager *dbManager;
 	MBProgressHUD *HUD;

    NSString *headingStr;
    
    NSString *houseName;
    NSString *houseID;
    NSString *roomName;
    NSString *roomID;
    NSString *itemID;
    
   IBOutlet UILabel *titleView;
    
    // Item Information
    IBOutlet UITextField    *itemNameTextField;
    IBOutlet UITextView     *itemDescTextView;
    IBOutlet UITextField    *itemPurchasedDate;
    IBOutlet UITextField    *itemInvoiceNum;
    IBOutlet UITextField    *itemManufacturer;
    
    IBOutlet UITextField    *itemCost;
    IBOutlet UITextField    *itemBrand;
    IBOutlet UITextField    *itemModel;
    IBOutlet UITextField    *itemQunatity;
  //  IBOutlet UITextField    *itemStatus;
IBOutlet UITextField    *itemCurrentValue;
    IBOutlet UITextField    *itemSize;

    
    IBOutlet UIButton       *itemCategoryBtn;
    IBOutlet UIButton       *itemConditionBtn;
     IBOutlet UIButton       *itemStatusBtn;
    
    // item Properties
    IBOutlet UITextField    *itemYearMade;
    IBOutlet UITextField    *itemMaterialMade;
    IBOutlet UITextField    *itemShape;
    IBOutlet UITextField    *itemColor;
   // IBOutlet UITextField    *itemIsInsured;
   // IBOutlet UITextField    *itemIsTaxable;
    IBOutlet UITextView     *itemComments;
    
    // item sold info
    
    IBOutlet UITextField    *itemSoldTo;
    IBOutlet UITextField    *itemSoldDate;
    IBOutlet UITextField    *itemSoldPrice;
    
    // item warranty info
    
    IBOutlet UITextField    *itemWarrantyExpire;
    IBOutlet UITextField    *itemWarrantyInfo;
    
    
    // item Insurance info
    
    IBOutlet UITextField    *itemInsureBy;
    IBOutlet UITextField    *itemInsurePolicy;

    // item Lease info
    
    IBOutlet UITextField    *itemLeaseStartDate;
    IBOutlet UITextField    *itemLeaseEndDate;
    IBOutlet UITextView    *itemLeaseDesc;

    
    
    IBOutlet UITextField    *itemReplacementCost;
    IBOutlet UITextField    *itemSerialNum;
    IBOutlet UITextField    *itemPlaceInService;
    IBOutlet UITextField    *itemUsePercentage;
    IBOutlet UITextField    *itemSalvageValue;
    IBOutlet UITextField    *itemDepreciationMethod;
    IBOutlet UITextField    *itemBenificiary;
    IBOutlet UITextField    *itemLifeInYears;

    NSIndexPath* checkedIndexPath;

    
    // item category
    
    NSMutableArray *itemCategoryAry;
    NSMutableArray *itemCategoryIds;
    NSMutableArray *itemCategoryNames;
    
    NSString *currentItemCategoryID;
    
    // item condition
    NSMutableArray *itemConditionAry;
    NSMutableArray *itemConditionIds;
    NSMutableArray *itemConditionNames;
    
    NSString *currentItemConditionID;

// item status//Divya
    NSMutableArray *itemStatusAry;
    NSMutableArray *itemStatusIds;
    NSMutableArray *itemStatusNames;
    
    NSString *currentItemStatusID;
    
    
    IBOutlet UIButton *isTaxableBtn;
    IBOutlet UIButton *isInsuredBtn;
    
    BOOL isTaxableClicked;
    BOOL isInsuredClicked;
    
    int isInsuredVal;
    int isTaxableVal;


// upload images btn
    
    IBOutlet UIButton *uploadItemImgsBtn;
    
    // item save btn
    
    IBOutlet UIButton *itemSaveBtn;//Divya

    //responseDateFormattedString
    NSString *formattedRespDateStr;
    
    BOOL itemAdded;
    NSString *localItemID;
    
    
    //viewPdf
    IBOutlet UIButton *viewPdf;
    BOOL isPdfOpen;

// New View
    
    IBOutlet UIView     *menuItemView;
    IBOutlet UIButton   *itemInfoBtn;
    IBOutlet UIButton   *itemPropertiesBtn;
    IBOutlet UIButton   *itemUploadsBtn;
    
    
    IBOutlet UIView     *itemInformationView;
    IBOutlet UIView     *itemPropertieView;
    IBOutlet UIView     *itemUploadsView;

// Scrollviews
    
    
    IBOutlet UIScrollView   *itemInfoScrollView;
    IBOutlet UIScrollView   *itemPropertiesScrollView;
    IBOutlet UIScrollView   *itemImagesScrollView;
    
    // temp scrollview
    
    UIScrollView *currentScrollView;
    
    
    // for uploading photos
    
    UIActionSheet* photoSheet;
    UIImagePickerController *imagePicker;
    UIPopoverController *photoPopOver;

    // images paths
    
    NSString *housePath;
    NSString *roomPath;
    NSString *itemPath;
    
    // deletion of img
    UIButton *deleteItemImgBtn;
    int deletedItemImgID;
    NSString *deletedItemImgServerID;
    
    UIAlertView *itemImgDeleteAlertView;

//    UIButton *itmImgGridViewBtn;
    NSMutableArray *imagesAry;
    
    int activeBtnTag;
    
    
    
    // scroll testing
    CGRect coveredFrame;
    UITextField *activeTExtField;
    UITextView  *activeTextView;

    
    //menu alert view handling
    BOOL menuUploadPhotosAlertViewFirstTime;
    
    // to show image
    
    UIImageView *itemImageView;
    

}
// item category
@property(nonatomic,retain)UIPopoverController  *itemCategoryPopOverController;
@property(nonatomic,retain)UIPickerView         *itemCategoryPicker;

// item status //Divya
@property(nonatomic,retain)UIPopoverController  *itemStatusPopOverController;//Divya
@property(nonatomic,retain)UIPickerView         *itemStatusPicker;//Divya

// item condition
@property(nonatomic,retain)UIPopoverController  *itemConditionPopOverController;
@property(nonatomic,retain)UIPickerView         *itemConditionPicker;
@property(nonatomic,retain)NSString *houseID;
@property(nonatomic,retain)NSString *roomID;
@property (nonatomic,strong) UIPopoverController *itemImagePopOver;

//item save btn
@property(nonatomic,retain)IBOutlet UIButton *itemSaveBtn;


@property (nonatomic, retain) NSIndexPath* categoryCheckedIndexPath;
@property (nonatomic, retain) NSIndexPath* conditionCheckedIndexPath;
@property (nonatomic, retain) NSIndexPath* statusCheckedIndexPath;


// for editing of item

@property(nonatomic,retain)NSString *itemID;


-(IBAction)addItemSaveBtnClicked:(id)sender;
-(IBAction)addItemCancelBtnClicked:(id)sender;
-(IBAction)itemCategoryBtnClicked:(id)sender;
-(IBAction)itemConditionBtnClicked:(id)sender;
-(IBAction)uploadItemImgsBtnClicked:(id)sender;
-(IBAction)itemStatusBtnClicked:(id)sender;//Divya
-(IBAction)itemIsInsuredBtnClicked:(id)sender;//Divya
-(IBAction)itemIsTaxableBtnClicked:(id)sender;//Divya

// new view

-(IBAction)itemInfoBtnClicked:(id)sender;
-(IBAction)itemPropertiesBtnBtnClicked:(id)sender;
-(IBAction)itemUploadsBtnClicked:(id)sender;




@end
