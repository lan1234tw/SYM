//
//  stageViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "stageViewController.h"
#import "testDispatchViewController.h"
#import "ContentPageModel.h"

@interface stageViewController ()

@end

@implementation stageViewController
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
    UIImage* img =[UIImage imageNamed:self.imagePath];
    self.stageImageView.image =img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_touched:(id)sender {
    NSArray *urls =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if(0 >= urls.count) {
        NSLog(@"找不到Cache的folder");
        return;
    } // if
    
    NSString* content =[[NSString alloc] init];
    content =urls[0];
    content =[content stringByAppendingPathComponent:@"dw1"];
    NSLog(@"%@", content);
    
    id returnVal =[self.storyboard instantiateViewControllerWithIdentifier:@"ContentPageViewController"];
    if(nil == returnVal) {
        NSLog(@"無法實體化指定的controller");
        return;
    } // if
    
    UIPageViewController* pageViewController =(UIPageViewController*)returnVal;
    ContentPageModel* contentPageModel =nil;
    contentPageModel =(ContentPageModel*)pageViewController.dataSource;
    [contentPageModel reloadContenetFromPath:content];
    
    NSArray* viewControllers =@[[contentPageModel viewControllerAtIndex:0 storyboard:pageViewController.storyboard]];
    [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self.navigationController pushViewController:returnVal animated:YES];
}

@end
