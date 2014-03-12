//
//  StageScrollViewController.m
//  SYM
//
//  Created by HsiuYi on 2013/10/25.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "StageScrollViewController.h"
#import "StageViewController.h"

@interface StageScrollViewController ()

@end

@implementation StageScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
  
  // 從Core Data中讀取資料
  NSArray* contents =[ContentManager.instance getAllContentBase];
  int totalPages =(int)((contents.count +8) /8);
  
  // 尺寸不能在viewDidLoad處理，否則會讀到直立的尺寸
  CGSize contentSize =CGSizeMake(
         totalPages *CGRectGetWidth(self.stageScrollView.frame),
         CGRectGetHeight(self.stageScrollView.frame)
  );
  
  [self.stageScrollView setContentSize:contentSize];
  self.stageScrollView.scrollsToTop = NO;
  self.pageControl.currentPage =0;
  self.pageControl.numberOfPages =totalPages;
  
  StageViewController* controller;
  int baseLeftCount =0; // 還剩下幾個base
  for(int i =0; i < totalPages; ++i) {
    controller =[self loadPageContent:i];
    [self addPageContent:controller];
    
    baseLeftCount =(int)(contents.count - i*8);
    if(8 < baseLeftCount) {
      baseLeftCount =8;
    } // if
    
    for(int j =0; j < baseLeftCount; ++j) {
      controller.contentBases[j] =contents[8 *i +j];
    } // for
  } // for
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (StageViewController*)loadPageContent:(int)page {
  StageViewController* controller =nil;
  controller =[self.storyboard instantiateViewControllerWithIdentifier:@"ID_StageViewController"];
  
  CGRect frame = self.stageScrollView.bounds;
  frame.origin.x = CGRectGetWidth(frame) * page;
  frame.origin.y = 0;
  controller.view.frame = frame;
  
  return controller;
}

- (void)addPageContent:(StageViewController*)controller {
  [self addChildViewController:controller];
  [self.stageScrollView addSubview:controller.view];
  
  [controller didMoveToParentViewController:self];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  // switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = CGRectGetWidth(self.stageScrollView.frame);
  
  // 計算現在要捲到第幾頁去
  NSUInteger page = floor((self.stageScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  self.pageControl.currentPage = page;
}

- (void)gotoPage:(BOOL)animated {
  NSInteger page = self.pageControl.currentPage;
  
  // update the scroll view to the appropriate page
  CGRect bounds = self.stageScrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * page;
  bounds.origin.y = 0;
  [self.stageScrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender {
  [self gotoPage:YES];    // YES = animate
}

- (IBAction)infoBtn_touched:(id)sender {
  [self dismissViewControllerAnimated:NO completion:nil];
}
@end
