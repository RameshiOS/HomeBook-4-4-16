//
//  SignupViewController.h
//  RoyalHouseManagement
//
//  Created by Divya on 5/30/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAUtilities.h"
#import "WebServiceInterface.h"
#import "DataBaseManager.h"
#import "DashBoardViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
@interface SignupViewController : UIViewController<UITextFieldDelegate,WebServiceInterfaceDelegate,SKPSMTPMessageDelegate>
{
    IBOutlet UIScrollView *signUpSubView;
    UIImageView      *houseImage;
    
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *phoneField;
    BOOL validAlertCheck;
    
    IBOutlet UILabel *headingLabel;

    CGPoint svos;
    
    //    BOOL viewDidLoad;
    BOOL signUpSuccess;
    BOOL isAdmin;
    BOOL isPotentialUser;
    WebServiceInterface *webServiceInterface;
    DataBaseManager *dbManager;
    NSString *isLaunching;

}
@end
