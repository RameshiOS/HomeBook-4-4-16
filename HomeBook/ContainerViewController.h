//
//  ContainerViewController.h
//  RoyalHouseManagement
//
//  Created by Manulogix on 22/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseManager.h"
#import "WebServiceUtils.h"
#import "WebServiceInterface.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "MenuViewController.h"


@interface ContainerViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,WebServiceUtilsDelegate,WebServiceInterfaceDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate,MFMailComposeViewControllerDelegate,UIWebViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate>{//added UINavigationControllerDelegate Divya
   
    DataBaseManager *dbManager;
    WebServiceInterface *webServiceInterface;
	MBProgressHUD *HUD;
    
    
    // house details
    NSString *typeStr;
    NSString *nameStr;
    NSString *houseIdStr;
    NSString *roomIdStr;

    // House Details
    
    NSMutableArray *houseDetails;
    
    // House Name Edit Details
    
    NSMutableArray *editHouseNameDetails;
    
    // Room Name Edit Details
    
    NSMutableArray *editRoomNameDetails;
    
    NSTimer *tapTimer;
    
    // rooms list
    
//    NSMutableArray *roomsArray;
    
    // text fields and buttons
    
    IBOutlet UILabel        *houseNameField;
    IBOutlet UILabel        *houseAddrField;
    IBOutlet UITextView     *houseDescTextView;
    
    IBOutlet UIButton       *houseSettingsBtn;
    
    
    // house images scroll view and bg view
    
    IBOutlet UIView         *scrollImgBgView;
    IBOutlet UIScrollView   *scrollImgView;
    
    
    // for uploading photos
    
    UIActionSheet* photoSheet;
    UIImagePickerController *imagePicker;
    UIPopoverController *photoPopOver;

    
    //scroll view
    IBOutlet UIScrollView *containerScrollView;
    UIView *containerSubView;
    
    
    // file path
    NSString *housePath;
    UIButton *deleteHouseImgBtn;
    int deletedHouseImgID;
    NSString *deletedHouseImgServerID;
    
    
    // subview details
    UIView *addRoomSubView;
    UITextField *roomNameTextField;
    UITextView *roomDescTextView;
    UIButton *roomTypeBtn;
    
    
    //  add House subview details
    UIView *addHouseSubView;
    UITextField *addHouseNameTextField;
    UITextView *addHouseDescTextView;
    UITextView *addHouseAddrTextView;

    
    
    NSMutableArray *roomTypeAry;
    NSMutableArray *roomTypeIds;
    NSMutableArray    *roomTypeNames;
    NSString *currentRoomID;

    
    // for items
//    NSMutableArray *itemsArray;
    UIButton *deleteItemBtn;
    UIButton *emailItemBtn;
    //pdf
    UIButton *viewPdfItemButton;
    NSString *pdfLink;
    UIWebView*   pdfWebView;
    NSString *tempItemPdfStorePath;
    

    int deletedItemID;
    
    // emial test
    MFMailComposeViewController *mailComposer;

    // webview
    UIWebView *testWebView;
    UIViewController *pdfcontroller;
    
    
    // alerts View
    
    UIAlertView *deleteItemAlertView;
    UIAlertView *deleteHouseImgAlertView;
    UIAlertView *deleteRoomAlertView;
    UIAlertView *deleteHouseAlertView;
    
    

    // house settings Array
    
    NSMutableArray *houseSettingsList;
    NSString *cellValue;
    UITableView *houseListTableViewMenu;

    UIImageView *houseImageView;
    UIImageView *itemImageView;

    
    // options array
    
    NSMutableArray *optionsListAry;
    int currentOptionBtnTag;
    
    
    // house Delete
    
    NSDictionary *deletedHouseDict;
    NSString     *deleteHouseID;
    NSString     *deleteHouseServerID;

    
    // room Delete
    
    NSDictionary *deletedRoomDict;
    NSString     *deleteRoomID;
    NSString     *deleteRoomServerID;
    
    // item delete
    
    NSString *deletedItemServerID;
    
    UITextView *itemNameTextView;
    UILongPressGestureRecognizer *itemGesture;
    int selectedEditItemID;
    
    // house sync button
    
    IBOutlet UIButton *houseSyncBtn;
    WebServiceUtils *webServiceUtils;

    
    IBOutlet UIButton *globalSyncBtn;
    
    // ROOM UPDATE
    NSString *updateRoomID;
    BOOL isRoomUpdated;
    
    // house UPDATE
    NSString *updateHouseID;
    BOOL isHouseUpdated;
    
    
    NSString *currentSelectedRoomID;
    
    CGFloat originYForRoom;

    CGFloat originXForItem;

    // performance
    NSMutableArray *houseDetailsAry;
    NSDictionary *currentRoomDict;
    
    
    
    // room Dictionary
    
    NSMutableArray *roomsArray;
    
    
    // items Dictionary
    
    NSMutableArray *itemArray;
    NSMutableArray *currentItemArray;

    
    
    // items images Dictionary
    
    NSMutableArray *itemImagesArray;

    
    BOOL isEditItemPopOverPresent;

    UITextView *itemNameEditTextView;
    
    BOOL isItemPdfClicked;
    UIButton *itemPdfClickedBtn;
    
    
    BOOL isEmailPdfClicked;
    UIButton *emailPdfClickedBtn;
    int viewPdfBtnTag;
    
    // to show item image
    
    UIButton *itemImageButton;
    
    
    // item searched string
    
    
    NSString *itemSearchedString;
    NSString *isSearcingItem;
    
    NSIndexPath *selectedCell;
    NSIndexPath* checkedIndexPath;
    
    
//    NSString *itenNameTextViewStr;
    
//   IBOutlet UIActivityIndicatorView *loading;
}
// pop over for room type

@property(nonatomic,retain)UIPopoverController *roomTypePopOverController;
//@property(nonatomic,retain)UIPickerView *roomTypePicker;

@property (nonatomic, retain) NSIndexPath* checkedIndexPath;

// pop over for options
@property (nonatomic,strong) UIPopoverController *optionsPopOver;


// pop over for roomtype
@property (nonatomic,strong) UIPopoverController *roomTypePopOver;


// pop over for house settings
@property (nonatomic,strong) UIPopoverController *houseSettingsPopOver;

@property (nonatomic,strong) UIPopoverController *houseImagePopOver;
@property (nonatomic,strong) UIPopoverController *itemImagePopOver;


// pop over for item name edit
@property (nonatomic,strong) UIPopoverController *itemNameEditPopOver;


// pop over for share

@property (strong, nonatomic) UIActivityViewController *activityViewController;
@property (strong, nonatomic) UIPopoverController      *sharePopOverController;


// house settings btn action
-(IBAction)houseSettingsBtnClicked:(id)sender;

// house sync button action
-(IBAction)houseSyncButtonClick:(id)sender;

-(IBAction)globalSyncButtonClick:(id)sender;

@end
