//
//  SignupViewController.m
//  RoyalHouseManagement
//
//  Created by Divya on 5/30/14.
//  Copyright (c) 2014 Manulogix. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

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
    NSUserDefaults *standardUserDefaults1 = [NSUserDefaults standardUserDefaults];
    isLaunching = [standardUserDefaults1 objectForKey:@"IsLaunchingSignUp"];
    houseImage = [[UIImageView alloc] init];
    
    if ([isLaunching isEqualToString:@"YES"]) {
//        if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
//            [houseImage setFrame:CGRectMake(0, 300, 1024, 490)];
//        }
        signUpSubView.hidden = NO;
        if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
            [houseImage setFrame:CGRectMake(0, 620, 768, 400)];
        }
        [houseImage setImage:[UIImage imageNamed:@"house.jpg"]];
        [self.view addSubview:houseImage];
    }
    

    headingLabel.layer.borderColor = [UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0].CGColor;
    headingLabel.textColor= [UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0];
    headingLabel.layer.borderWidth = 2;
    headingLabel.layer.cornerRadius = 7;

    [emailField setValue:[UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [nameField setValue:[UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [phoneField setValue:[UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];

}
//-(void)viewDidAppear:(BOOL)animated{
//    [self showImage];
//}

//-(void)showImage{
//        signUpSubView.hidden = NO;
//        if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
//            [houseImage setFrame:CGRectMake(0, 620, 768, 400)];
//        }
//        [houseImage setImage:[UIImage imageNamed:@"house.jpg"]];
//        [self.view addSubview:houseImage];
//}

-(void) sendEmailInBackground:(NSString *)user{
    NSLog(@"Start Sending Mail %@",user);
    
    // format it
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    // convert it to a string
    NSString *currentDateString = [dateFormat stringFromDate:date];
    NSLog(@"currentDate:%@",currentDateString);
    
    SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
    emailMessage.relayHost = @"smtpout.secureserver.net";
    emailMessage.requiresAuth = YES;
    emailMessage.login = @"test1@manulogix.com"; //sender email address
    emailMessage.pass = @"demo123"; //sender email password
    emailMessage.wantsSecure = YES;
    emailMessage.delegate = self;
    emailMessage.fromEmail = @"sales@royalhousemanagement.com"; //sender email address

    NSString *messageBody;
    if ([user isEqualToString:@"Admin"]) {
        emailMessage.toEmail = @"sales@royalhousemanagement.com";  //receiver email address
        emailMessage.subject =[NSString stringWithFormat:@"New User Signup %@ %@",currentDateString,nameField.text];
        messageBody= [NSString stringWithFormat:@"Dear Elias,\n\nOne user has signed up. This user%@s details are following:\n\nName:%@\nEmail:%@\nPhone:%@\n\n\n\nThanks,\nSales@royalhousemanagement.com",@"'",nameField.text,emailField.text,phoneField.text];
        isAdmin=YES;
    }else{
        emailMessage.toEmail = emailField.text;  //receiver email address
        emailMessage.subject =[NSString stringWithFormat:@"%@",@"Thanks for signing up for Home Book"];
        messageBody= [NSString stringWithFormat:@"Dear %@,\n\nThanks for signing up for Home Book %@ Inventory Management App from Royal House Management LLC. One of our friendly sales personnel will contact you to assess your needs.\n\n\nThanks,\nSales@royalhousemanagement.com",nameField.text,@"–"];
        isPotentialUser=YES;

    }
    NSDictionary *plainMsg = [NSDictionary  dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                              messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    emailMessage.parts = [NSArray arrayWithObjects:plainMsg,nil];
    [emailMessage send];
}

// On success
-(void)messageSent:(SKPSMTPMessage *)message{
    NSLog(@"delegate - message sent");
    if (isAdmin==YES&&isPotentialUser==YES) {
        [self performSegueWithIdentifier:@"SegueToLogin" sender:self];
    }
//    }//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//    [alert show];
}
// On Failure
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    // open an alert with just an OK button
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//    [alert show];
//    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        svos = signUpSubView.contentOffset;
        CGPoint pt;
        CGRect rc = [textField bounds];
        rc = [textField convertRect:rc toView:signUpSubView];
        pt = rc.origin;
        pt.x = 0;
        pt.y -= 0;
        [signUpSubView setContentOffset:pt animated:YES];
    }
    return YES;
}

-(BOOL)isValidEmail:(NSString*)checkString{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        [signUpSubView setContentOffset:svos animated:YES];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField==emailField){
        if (emailField.text.length!=0) {
            if ([self isValidEmail:emailField.text]) {
            }else {
                [FAUtilities showAlert:INVALID_EMAIL];
                return;
            }
        }
    }if (textField==phoneField) {
        if (phoneField.text.length!=0) {
            
            NSString *regEx = @"([0-9]{3})-[0-9]{3}-[0-9]{4}";
            
            if ([textField.text isEqualToString:@""]) {
                //            NSLog(@"emply field");
            }else{
                if ([self getLength:textField.text] == 10) {
                    NSRange r = [textField.text rangeOfString:regEx options:NSRegularExpressionSearch];
                    
                    if (r.location == NSNotFound) {
                        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[-()]"
                                                                                                    options:0
                                                                                                      error:NULL];
                        NSString *cleanedString = [expression stringByReplacingMatchesInString:textField.text
                                                                                       options:0
                                                                                         range:NSMakeRange(0, [self getLength:textField.text])
                                                                                  withTemplate:@""];
                        NSLog(@"cleaned = %s",[cleanedString UTF8String] );
                        
                        NSString *firstSubStr = [cleanedString substringToIndex:3];
                        
                        NSRange secSubStrRange = NSMakeRange(3, 3);
                        NSString *secondSubStr = [cleanedString substringWithRange:secSubStrRange];
                        
                        NSRange thirdSubStrRange = NSMakeRange(6, 4);
                        NSString *thirdSubStr = [cleanedString substringWithRange:thirdSubStrRange];
                        
                        textField.text = [NSString stringWithFormat:@"(%@)-%@-%@",firstSubStr,secondSubStr,thirdSubStr];
                        if ([textField.text isEqualToString:@"(000)-000-0000"]) {
                            [textField becomeFirstResponder];
                            [FAUtilities showAlert:INVALID_PHONE];
                            validAlertCheck = YES;
                        }
                        
                        if (validAlertCheck == YES) {
                            validAlertCheck = NO;
                        }
                        
                    }else{
                        NSLog(@"phone is in valid format ");
                    }
                }else{
                    [FAUtilities showAlert:INVALID_PHONE];
                    [textField becomeFirstResponder];
                    validAlertCheck = YES;
                }
            }
        }
        }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    int newLength = [textField.text length] + [string length] - range.length;
    NSLog(@"length %d",newLength);
    
    if (newLength == 1) {
        string = [string uppercaseString];
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    int maxLength = 10;
    if (textField==phoneField) {
        if ([string isEqualToString:@""]) {
            NSLog(@"back space");
            return YES;
        }else{
            NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
            
            if (filtered) {
                if (maxLength == 0) {
                    maxLength=10;
                }
                NSString *text = @"";
                text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *regEx = @"([0-9]{3})-[0-9]{3}-[0-9]{4}";
                
                int length = [self getLength:textField.text];
                if(length == 10){
                    
                    NSRange r = [textField.text rangeOfString:regEx options:NSRegularExpressionSearch];
                    
                    if (r.location == NSNotFound) {
                        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[-()]"
                                                                                                    options:0
                                                                                                      error:NULL];
                        NSString *cleanedString = [expression stringByReplacingMatchesInString:textField.text
                                                                                       options:0
                                                                                         range:NSMakeRange(0, [self getLength:textField.text])
                                                                                  withTemplate:@""];
                        NSLog(@"cleaned = %s",[cleanedString UTF8String] );
                        
                        NSString *firstSubStr = [cleanedString substringToIndex:3];
                        
                        NSRange secSubStrRange = NSMakeRange(3, 3);
                        NSString *secondSubStr = [cleanedString substringWithRange:secSubStrRange];
                        
                        NSRange thirdSubStrRange = NSMakeRange(6, 4);
                        NSString *thirdSubStr = [cleanedString substringWithRange:thirdSubStrRange];
                        
                        
                        
                        textField.text = [NSString stringWithFormat:@"(%@)-%@-%@",firstSubStr,secondSubStr,thirdSubStr];
                        if ([textField.text isEqualToString:@"(000)-000-0000"]) {
                            //                            textField.text=@"";
                            [textField becomeFirstResponder];
                            //                            [self showAlert:PHONE_INVALID];
                            [FAUtilities showAlert:INVALID_PHONE];
                            validAlertCheck = YES;
                        }
                        
                    }else{
                        NSLog(@"phone is in valid format ");
                    }
                    
                    return NO;
                }
                
                return [string isEqualToString:filtered];
            }
        }
    }
  

    return YES;
}
/* Method to format the textfield value length after entering for SSN/DOB*/
-(int)getLength:(NSString*)formatNumber{
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@":" withString:@""];
    formatNumber = [formatNumber stringByReplacingOccurrencesOfString:@"/" withString:@""];
    int length = [formatNumber length];
    return length;
}
-(IBAction)signUpSubmitBtnClicked:(id)sender{
    if (emailField.text.length == 0) {
        [FAUtilities showAlert:@"Please Enter Email"];
        signUpSuccess = NO;
        return;
    }else if (nameField.text.length == 0){
        [FAUtilities showAlert:@"Please Enter Name"];
        signUpSuccess = NO;
        return;
    }else if (phoneField.text.length == 0){
        [FAUtilities showAlert:@"Please Enter Phone"];
        signUpSuccess = NO;
        return;
    }
    else{
        [self.view endEditing:YES];
            NSLog(@"signup table not contains records");
          [self postRequest:SIGNUP_TYPE];
    }
}

-(IBAction)signUpCancelBtnClicked:(id)sender{
    
    phoneField.text=@"";
    emailField.text=@"";
    nameField.text=@"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"YES" forKey:@"IsLaunchingSignUp"];
        [standardUserDefaults synchronize];
    }
    [self performSegueWithIdentifier:@"SegueToLogin" sender:self];

}
-(void)postRequest:(NSString *)reqType{
    NSString *requestURL;
    NSString *formattedBodyStr;
    
    if ([reqType isEqualToString:SIGNUP_TYPE]) {//Divya
        formattedBodyStr= [self jsonFormat:SIGNUP_TYPE withDictionary:nil];//Divya
        requestURL =SIGNUP_REQUEST_URL;//Divya
    }
    NSData *postJsonData = [formattedBodyStr dataUsingEncoding:NSUTF8StringEncoding];
    webServiceInterface = [[WebServiceInterface alloc]initWithVC:self];
    webServiceInterface.delegate =self;
    [webServiceInterface sendRequest:formattedBodyStr PostJsonData:postJsonData Req_Type:reqType Req_url:requestURL];//Divya
    
}


-(NSString*)jsonFormat:(NSString *)type withDictionary:(NSMutableDictionary *)formatDict{
    
    NSString *bodyStr;//Divya
    if ([type isEqualToString:SIGNUP_TYPE]) {//Divya
        bodyStr= [NSString stringWithFormat:@"{\"Type\":\"%@\",\"Email\":\"%@\",\"Name\":\"%@\",\"Phone\":\"%@\"}", type,emailField.text, nameField.text,phoneField.text];//Divya
    }
    return bodyStr;
}



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //    if ( loginSuccess == YES) {
    //        return YES;
    //    }else{
    return NO;
    //    }
}
-(void)getResponse:(NSDictionary *)resp type:(NSString *)respType{
    
    if ([respType isEqualToString:SIGNUP_TYPE]) {
        if (resp == NULL) {
            [FAUtilities showAlert:[resp valueForKey:@"Unable to Signup"]];
        }else if ([[resp valueForKey:@"Status"] isEqualToString:@"Fail"]) {
            signUpSuccess = NO;
            [FAUtilities showAlert:[resp valueForKey:@"Message"]];
        }else{
            signUpSuccess = YES;
            
            
            [self sendEmailInBackground:@"Admin"];
            [self sendEmailInBackground:@"PotentialUser"];

            NSMutableDictionary *defaultsTest = [[NSMutableDictionary alloc]init];
            [defaultsTest setObject:emailField.text forKey:@"Email"];
            [defaultsTest setObject:nameField.text forKey:@"Name"];
            [defaultsTest setObject:phoneField.text forKey:@"Phone"];

            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (userDefaults) {
                [userDefaults setObject:defaultsTest forKey:@"SignupDetails"];
                [userDefaults synchronize];
            }
            
            if ([emailField.text isKindOfClass:[NSNull class]]||(emailField.text.length==0)) {
                emailField.text =@"";
            }
            
            if ([nameField.text isKindOfClass:[NSNull class]]||(nameField.text.length==0)) {
                nameField.text =@"";
            }
            
            if ([phoneField.text isKindOfClass:[NSNull class]]||(phoneField.text.length==0)) {
                phoneField.text =@"";
            }
            [dbManager execute:[NSString stringWithFormat: @"INSERT INTO 'Interested_users' (SignupEmail, Name,CurrentUser,Phone)VALUES ('%@', '%@','%@','%@')",emailField.text,nameField.text,@"ON",phoneField.text]];
            
            [FAUtilities showAlert:[resp valueForKey:@"Message"]];

         }
      }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view endEditing:YES];
    
    if(UIInterfaceOrientationIsLandscape(STATUSBAR_ORIENTATION)){
        houseImage.hidden = NO;
        [houseImage setFrame:CGRectMake(0, 620, 768, 400)];
        [houseImage setImage:[UIImage imageNamed:@"house.jpg"]];
        [self.view addSubview:houseImage];
    }
    else if(UIInterfaceOrientationIsPortrait(STATUSBAR_ORIENTATION)){
        houseImage.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
