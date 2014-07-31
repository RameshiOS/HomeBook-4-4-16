//
//  AppDelegate.h
//  HomeBook
//
//  Created by Manulogix on 13/06/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    DataBaseManager *dbManager;

}

@property (strong, nonatomic) UIWindow *window;

@end
