//
//  LoginViewController.m
//  SYM
//
//  Created by HsiuYi on 2013/11/5.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "LoginViewController.h"
#import "com_symAppDelegate.h"

@interface LoginViewController ()
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

    NSString* account =@"";
    account =self.accountField.text;
    
    if(YES == [account isEqualToString:@"ABC"]) {
      return NO;
    } // if
    else {
      com_symAppDelegate* appDelegate =nil;
      appDelegate =(com_symAppDelegate*)([UIApplication sharedApplication].delegate);
      appDelegate.currentUser =account;
      return YES;
    } // else
}

@end
