//
//  MainViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/22.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "MainViewController.h"
#import "StageScrollViewController.h"
#import "ContentManager.h"

@interface MainViewController ()
@end

@implementation MainViewController

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

- (void)viewWillAppear:(BOOL)animated {
  __block NSMutableArray* listItems =nil;
  listItems =[ContentManager.instance loadList:@"http://127.0.0.1:8080/symBack/json.txt"];
  
  if(nil == listItems || 0 == listItems.count) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下載清單無內容"
                                              message:nil
                         delegate:nil cancelButtonTitle:@"關閉" otherButtonTitles:nil];
    
    [alert show];
  } // if
  
  [listItems enumerateObjectsUsingBlock:^(NSMutableDictionary* base, NSUInteger idx, BOOL *stop) {
    NSString* archivePath =base[@"archivePath"];
    NSString* previewPath =base[@"previewPath"];
    [ContentManager.instance loadPreviewItem:archivePath previewPath:previewPath];
  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if(YES == [segue.identifier isEqualToString:@"ID_MyInfo"]) {
    UINavigationController* navController =nil;
    StageScrollViewController* viewController =nil;
    
    navController =(UINavigationController*)(segue.destinationViewController);
    viewController =(StageScrollViewController*)([navController topViewController]);
    viewController.contentType =@"myInfo";
  } // if
}
@end
