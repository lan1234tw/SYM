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
@synthesize img =_img;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
  self.contentImageView.image =self.img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
