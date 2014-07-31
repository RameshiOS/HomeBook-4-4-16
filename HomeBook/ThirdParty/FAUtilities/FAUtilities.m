//
//  FAUtilities.m
//  Rhm
//
//  Created by NagaMalleswar on 05/02/13.
//  Copyright (c) 2013 NagaMalleswar. All rights reserved.
//

#import "FAUtilities.h"
#import <mach/mach.h>
#import <QuartzCore/QuartzCore.h>
#include <sys/xattr.h>


@implementation FAUtilities


static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

+ (void)setBorderWithColor:(UIColor *)color toView:(UIView *)view withRadius:(CGFloat)radius{
    CALayer * layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[color CGColor]];
    [layer setCornerRadius:radius];
}
+ (UIBarButtonItem *)customButtonWithTitle:(NSString*)title style:(UIButtonType)buttonStyle target:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *buttonView = [UIButton buttonWithType:buttonStyle];
    [buttonView setFrame:CGRectMake(0, 0, width, 30)];
	[buttonView setTitle:title forState:UIControlStateNormal];
	buttonView.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 3, 0);
    buttonView.titleLabel.textAlignment = NSTextAlignmentCenter;
	[buttonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	return barButton  ;
}
+ (UIBarButtonItem *)customButtonWithImage:(NSString*)bgImage target:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonView setFrame:CGRectMake(0, 0, width, 30)];
    
	buttonView.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    buttonView.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 3, 0);
    buttonView.titleLabel.textAlignment = NSTextAlignmentCenter;
	[buttonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:[UIImage imageNamed:bgImage] forState:UIControlStateNormal];
    //buttonView.imageView.layer.cornerRadius = 7.0f;
    buttonView.layer.shadowRadius = 5.0f;
    buttonView.layer.shadowColor = [[UIColor colorWithRed:248.0f/255.0f green:249.0f/255.0f blue:250.0f/255.0f alpha:1] CGColor];
    buttonView.layer.shadowOffset = CGSizeMake(-4.0f, 1.0f);
    buttonView.layer.shadowOpacity = 0.5f;
    buttonView.layer.masksToBounds = NO;
//    [buttonView.layer setCornerRadius: 4.0];
//    [buttonView.layer setBorderWidth:1.0];
    [buttonView.layer setBorderColor:[[UIColor colorWithRed:171.0f/255.0f green:171.0f/255.0f blue:171.0f/255.0f alpha:1] CGColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
	return barButton  ;
}


+ (UIBarButtonItem *)customBackButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *backButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 20)];
    backButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    backButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[backButtonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [backButtonView setBackgroundImage:[UIImage imageNamed:@"backhome"] forState:UIControlStateNormal];
	UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
	return backBarButton  ;
}
+ (UIBarButtonItem *)customBackButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width title:(NSString *)title{
    UIButton *backButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
    backButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    backButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[backButtonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [backButtonView setBackgroundImage:[UIImage imageNamed:@"button_black_1.png"] forState:UIControlStateNormal];
    [backButtonView setBackgroundImage:[UIImage imageNamed:@"button_black_2.png"] forState:UIControlStateHighlighted];

    [backButtonView setTitle:title forState:UIControlStateNormal];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
	return backBarButton  ;
}
+ (UIBarButtonItem *)customInfoButtonWithtarget:(id)target action:(SEL)sel width:(CGFloat)width{
    UIButton *infoButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 20)];
    infoButtonView.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    infoButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    infoButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[infoButtonView addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [infoButtonView setBackgroundImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
	UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButtonView];
	return backBarButton  ;
}
+ (NSData*)getImageDataFromView:(UIView*)view{
    UIGraphicsBeginImageContext([view bounds].size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 1);
    UIGraphicsEndImageContext();
    return data;
}

+ (CGFloat)convertBytesToMB:(CGFloat)bytes{
    CGFloat mbData = ((bytes/1024)/1024);
    return mbData;
}

+ (CGFloat)getTotalDiskspace{
    CGFloat totalSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
     return totalSpace;
}

+ (CGFloat)getFreeDiskspace {
    CGFloat totalSpace = 0.0f;
    CGFloat totalFreeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        NSLog(@"Memory Capacity of %.2f MiB with %.2f MiB Free memory available.", ((totalSpace/1024)/1024), ((totalFreeSpace/1024)/1024));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalFreeSpace;
}

+ (CGFloat)getAppUsageSpace {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %u", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    return  info.resident_size;
}


+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}


+(BOOL) offlineCheck {
//    if(isOFFLINE) {
//        return YES;
//    }
//    return NO;
    return NO;
}


+(void)showAlert:(NSString*)msg{
    NSString *titleStr = ALERT_MSG_TITLE;
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleStr message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

+(void)dismissAlert:(NSString*)msg{
    
}

+(void)showAlertMessage:(NSString*)msg{
    NSString *titleStr = @"Thanks";
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleStr message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
    
    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:3];

}



+(void)showToastMessageAlert:(NSString*)message{
//    NSString *titleString;
//    
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7) {
//        titleString = [NSString stringWithFormat:@"\n\n%@",FORMS_PAGE_TITLE];
//    }else{
//        titleString = FORMS_PAGE_TITLE;
//    }
//
//    
//	UIAlertView *toastMsgAlert= [[UIAlertView alloc] initWithTitle:titleString
//                                                           message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
//	[toastMsgAlert setMessage:message];
//	[toastMsgAlert setDelegate:self];
//	[toastMsgAlert show];
//    
//  
//    
//    [self performSelector:@selector(dismiss:) withObject:toastMsgAlert afterDelay:1.5];
}

+(void)dismiss:(UIAlertView*)alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}



+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c",base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}
+ (NSData *)base64DataFromString: (NSString *)string{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil)
    {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true;
        }
        
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak)
            {
                break;
            }
        }
    }
    
    return theData;
}


+ (void)addSkipBackupAttributeToPath:(NSString*)path {
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    BOOL result = setxattr([path fileSystemRepresentation], attrName, &attrValue, sizeof(attrValue), 0, 0);
    NSLog(@"result %d",result);
    
}

@end
