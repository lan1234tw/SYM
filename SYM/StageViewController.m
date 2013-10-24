//
//  StageViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "StageViewController.h"
#import "HTTPDownloader.h"

@interface StageViewController ()

@end

@implementation StageViewController

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

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_touched:(id)sender {
  /*
  NSArray *urls =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  if(0 >= urls.count) {
     NSLog(@"找不到Cache的folder");
     return;
  } // if
  */
  
  // 當使用者按下開始下載的時候
  
  // [downloader resumeItem:url];
}

@end
