//
//  FAUtilities.h
//  Rhm
//
//  Created by NagaMalleswar on 05/02/13.
//  Copyright (c) 2013 NagaMalleswar. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CustomIOS7AlertView.h"

@interface FAUtilities : NSObject

@property UIAlertView *alterWithCancelBtn;

+ (void)setBorderWithColor:(UIColor *)color toView:(UIView *)view  withRadius:(CGFloat)radius;
+ (UIBarButtonItem *)customButtonWithTitle:(NSString*)title style:(UIButtonType)buttonStyle target:(id)target action:(SEL)sel width:(CGFloat)width;
+ (UIBarButtonItem *)customBackButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width;
+ (UIBarButtonItem *)customBackButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width title:(NSString *)title;
+ (UIBarButtonItem *)customInfoButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width;

+ (UIBarButtonItem *)customButtonWithImage:(NSString*)bgImage target:(id)target action:(SEL)sel width:(CGFloat)width;
+ (CGFloat)getFreeDiskspace;
+ (CGFloat)getTotalDiskspace;
+ (CGFloat)getAppUsageSpace;
+ (CGFloat)convertBytesToMB:(CGFloat)bytes;
+ (NSData*)getImageDataFromView:(UIView*)view;



+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+ (unsigned int)intFromHexString:(NSString *)hexStr;

+(BOOL) offlineCheck;

+(void)showToastMessageAlert:(NSString*)message;
+(void)dismiss:(UIAlertView*)alertView;

+(void)showAlert:(NSString*)msg;
+(void)dismissAlert:(NSString*)msg;

+(void)showAlertMessage:(NSString*)msg;

+(NSString *)base64StringFromData:(NSData *)data length:(int)length;
+(NSData *)base64DataFromString:(NSString *)string;

+ (void)addSkipBackupAttributeToPath:(NSString*)path;




@end
