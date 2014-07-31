//
//  ViewController.h
//  HomeBook
//
//  Created by Manulogix on 13/06/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAUtilities.h"
#import "WebServiceInterface.h"
#import "DataBaseManager.h"
#import "DashBoardViewController.h"
#import "WebServiceUtils.h"

@interface ViewController : UIViewController<UITextFieldDelegate,WebServiceInterfaceDelegate,WebServiceUtilsDelegate>{
    IBOutlet UIScrollView *loginSubView;
    UIImageView      *houseImage;
    
    IBOutlet UITextField *userNameField;
    IBOutlet UITextField *passwordField;
    CGPoint svos;
    
    IBOutlet UIButton *demoBtn;
    
    //    BOOL viewDidLoad;
    BOOL loginSuccess;
    WebServiceInterface *webServiceInterface;
    DataBaseManager *dbManager;
    WebServiceUtils *webServiceUtils;
    
    BOOL UpdateUser;
    BOOL isFistLogin;
    
    NSString *isLaunching;
    BOOL isDemoAc;
    NSMutableArray * currentDemoUserIdAry;
    NSMutableArray *currentUserIdAry;
    NSMutableArray *currentInsertUserIdAry;
    NSMutableArray *currentInsertDemoUserIdAry;
    
    
}

@end
