//
//  WSLogin.m
//  TriStar
//
//  Created by Manulogix on 17/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import "WSLogin.h"
#import "DMLogin.h"
#import "SBJson.h"

@interface WSLogin ()

@end

@implementation WSLogin

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(NSDictionary *) parseJsonResponse:(NSData *)response{
//    NSLog(@"response %@", response);
    
    NSString *respStr = @"{\"findPo\": {\"vendor\": {\"vendorName\": \"test\",\"vendorPos\": [{\"poNumber\": \"123\",\"createdOn\": \"10-12-2013\",\"amount\": \"3000\"},{\"poNumber\": \"1234\",\"createdOn\": \"10-12-2013\",\"amount\": \"3000\"},{\"poNumber\": \"12345\",\"createdOn\": \"10-12-2013\",\"amount\": \"3000\"}]}}}";
    

    NSData *respData = [respStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *rspDic = [self getJSONObjectFromData:respData];
    NSArray *rspAry = [self getJSONObjectFromData:respData];
    
    NSLog(@"respAry %@", rspAry);
    NSLog(@"rspDic %@",rspDic);
    
    return rspDic;
}


-(id) getJSONObjectFromData:(NSData *)data {
    if ((!data) || ([data length] <=0)) return nil;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
//#if (__has_feature(objc_arc))
        NSString *dataInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//#else
//        NSString *dataInString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//#endif
        return [dataInString JSONValue];
    } else {
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
