//
//  WSLogin.h
//  TriStar
//
//  Created by Manulogix on 17/12/13.
//  Copyright (c) 2013 Manulogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSLogin : UIViewController{
    
}
-(NSDictionary *) parseJsonResponse:(NSData *)response;
@end
