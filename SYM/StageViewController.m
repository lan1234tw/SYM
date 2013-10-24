//
//  StageViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "StageViewController.h"
#import "com_symAppDelegate.h"
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
  CGRect frame =self.view.frame;
  CGSize contentSize =CGSizeMake(frame.size.width*2, frame.size.height);
  [self.scrooView setContentSize:contentSize];
  
  [self.itemBtn1 addTarget:self action:@selector(total_touched:) forControlEvents:UIControlEventTouchUpInside];
  [self.itemBtn2 addTarget:self action:@selector(total_touched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -

// 回到分類資訊
- (IBAction)button_touched:(id)sender {
  [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)total_touched:(id)sender {
  if([sender isKindOfClass:[UIButton class]]) {
    UIButton* btn =(UIButton*)sender;
    
    NSLog(@"%@ - %d", btn.titleLabel.text, btn.tag);
  } // if
}

@end
