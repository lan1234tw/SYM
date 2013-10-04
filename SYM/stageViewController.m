//
//  stageViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "stageViewController.h"
#import "testDispatchViewController.h"


@interface stageViewController ()

@end

@implementation stageViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_touched:(id)sender {
    id returnVal =[self.storyboard instantiateViewControllerWithIdentifier:@"testDispatchViewController"];
    
    if(nil == returnVal) {
        NSLog(@"無法實體化指定的controller");
        return;
    } // iif
    
    testDispatchViewController* viewController =(testDispatchViewController*)returnVal;
    UIButton* btn =(UIButton*)sender;
    viewController.title =btn.titleLabel.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
