//
//  DashBoardViewController.h
//  RoyalHouseManagement
//
//  Created by Manulogix on 29/01/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseManager.h"
#import "ViewController.h"
//#import "HouseCustomCell.h"
//#import "HouseDetailsViewController.h"
//#import "WebServiceInterface.h"
//#import "WebServiceUtils.h"
#import "WebServiceInterface.h"

@interface DashBoardViewController : UIViewController<WebServiceInterfaceDelegate>{
    IBOutlet UIButton *logoutBtn;
    IBOutlet UIView *containerForHouse;
    IBOutlet UIView *containerForRoom;
    DataBaseManager *dbManager;
    WebServiceInterface *webServiceInterface;
    UIBackgroundTaskIdentifier bgTask;

}

-(IBAction)SyncBtnClicked:(id)sender;


@end
