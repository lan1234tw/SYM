//
//  ContentViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/12.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
@end

@implementation ContentViewController
@synthesize imagePath = _imagePath;

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
    UIImage* img =nil;
    img =[UIImage imageWithContentsOfFile:self.imagePath];
    
    self.contentImageView.image =img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
