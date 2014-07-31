//
//  WebServiceUtils.h
//  RoyalHouseManagement
//
//  Created by Manulogix on 18/02/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseManager.h"
#import "WebServiceInterface.h"
//#import "ContainerViewController.h"

@protocol WebServiceUtilsDelegate<NSObject>
@required
-(void)getStatus:(NSDictionary *)status;
@end


@interface WebServiceUtils : UIViewController<WebServiceInterfaceDelegate>{
    DataBaseManager *dbManager;
    WebServiceInterface *webServiceInterface;
    id<NSObject,WebServiceUtilsDelegate> delegate;

    NSString *houseIDStr;
    
    BOOL houseUpdated;
    BOOL houseInserted;

    BOOL houseSuccessUpdated;
    BOOL houseSuccessInserted;
    
    
    BOOL roomUpdated;
    BOOL roomInserted;
    
    BOOL roomSuccessUpdated;
    BOOL roomSuccessInsertd;
    
    
    BOOL itemUpdated;
    BOOL itemInserted;
    
    BOOL itemSuccessUpdated;
    BOOL itemSuccessInsertd;

    NSMutableDictionary *tempRespDic;
    
    //responseDateFormattedString
    NSString *formattedRespDateStr;

    
    BOOL imageSuccessUpdated;
    
    BOOL imageUpdated;
    BOOL imageInserted;
    
    
    
    BOOL isHousesAvailable;

//    ContainerViewController *containerView;

}

@property(nonatomic,retain)id<NSObject,WebServiceUtilsDelegate> delegate;

-(id)   initWithVC  : (UIViewController *)parentVC;

//-(void)postRequest:(NSString *)reqType;

-(BOOL)postRequest:(NSString *)reqType withHouseID:(NSString *)houseID;

@end
