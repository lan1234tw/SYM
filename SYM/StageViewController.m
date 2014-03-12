//
//  StageViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "StageViewController.h"
#import "ContentBase.h"
#import "ContentScrollViewController.h"
#import "VideoPlaybackViewController.h"

@interface StageViewController () {
  int downloadCount;
}

@end

@implementation StageViewController
@synthesize contentBases = _contentBases;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    _contentBases =[[NSMutableArray alloc] init];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    _contentBases =[[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
  int beginHiddenIndex =0;
  beginHiddenIndex =self.contentBases.count;
  
  UIButton* btn =nil;
  ContentBase* base =nil;
  for(int i =0;i < beginHiddenIndex; ++i) {
    base =self.contentBases[i];
    btn =(UIButton*)self.buttons[i];
    
    if(YES == [base.downloadComplete boolValue]) {
      [btn setTitle:@"瀏覽" forState:UIControlStateNormal];
      [btn addTarget:self action:@selector(toContentScrollViewController:)
           forControlEvents:UIControlEventTouchUpInside];
    } // if
    else {
      [btn setTitle:@"開始下載" forState:UIControlStateNormal];
      [btn addTarget:self action:@selector(toBeginDownload:)
           forControlEvents:UIControlEventTouchUpInside];
    } // else
  } // for
  
  // 把不顯示的部分隱藏起來
  for(;beginHiddenIndex < 8; ++beginHiddenIndex) {
    ((UIImageView*)self.imageViews[beginHiddenIndex]).hidden =YES;
    ((UILabel*)self.descLabels[beginHiddenIndex]).hidden =YES;
    ((UILabel*)self.durations[beginHiddenIndex]).hidden =YES;
    ((UIButton*)self.buttons[beginHiddenIndex]).hidden =YES;
  } // for
  
  UIImage* img =nil;
  // NSString* previewPath;
  for(int i =0; i < self.contentBases.count; ++i) {
    if(nil == [self.imageViews[i] image]) {
      NSData* data =nil;
      data =((ContentBase*)self.contentBases[i]).previewPictureData;
      img =[UIImage imageWithData:data];
      [self.imageViews[i] setImage:img];
    } // if
    else {
      // 圖已經存在了
    } // else
  } // for
  
  [self hookRequestTracking];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self unhookRequestTracking];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)hookRequestTracking {
  [ContentManager.instance setRequestTracking:(id<ContentRequestTracking>)self];
}

- (void)unhookRequestTracking {
  [ContentManager.instance setRequestTracking:nil];
}

#pragma mark -
// 下載完成的部分會走這一段
- (IBAction)toContentScrollViewController:(id)sender {
  int i =[self.buttons indexOfObject:sender];
  ContentBase* base =self.contentBases[i];
  
  int type =[base.type intValue];
  if(kItemTypeJPG == type || kItemTypePNG == type) {
    ContentScrollViewController* controller =nil;
    controller =[self.storyboard instantiateViewControllerWithIdentifier:@"ID_ContentScrollViewController"];
    controller.base =base;
    [self.navigationController pushViewController:controller animated:NO];
  } // if
  else if(kItemTypeMP4 == type) {
    VideoPlaybackViewController* videoController =nil;
    videoController =[[VideoPlaybackViewController alloc] init];
    
    ContentItem* item =[base.items objectAtIndex:0];
    NSString* path =item.path;
    videoController.videoPath =path;
    [self.navigationController pushViewController:videoController animated:NO];
  } // else
  else {
    NSLog(@"讀取到無法辨識的內容");
  }
}

// 按下開始下載的按鈕，會執行這一段
- (IBAction)toBeginDownload:(id)sender {
  int i =[self.buttons indexOfObject:sender];
  UIButton* btn =(UIButton*)sender;
  [btn setTitle:@"下載準備中" forState:UIControlStateNormal];

  ContentBase* base =nil;
  base =self.contentBases[i];
  
  [ContentManager.instance requestBase:base];
}

#pragma mark - ContentRequestTracking
- (void)begin:(ContentBase*)base {
  dispatch_async(dispatch_get_main_queue(), ^{
    int i =[self.contentBases indexOfObject:base];
    if(NSNotFound == i) {
      return;
    } // if
    
    UIButton* btn =self.buttons[i];
    [btn setHidden:YES];
  
    UIProgressView* progressView =self.progressViews[i];
    [progressView setProgress:0.0f];
    [progressView setHidden:NO];
  
    downloadCount =base.items.count;
  });
}


- (void)update:(ContentBase*)base updateProgress:(double)g {
  dispatch_async(dispatch_get_main_queue(), ^{
    int i =[self.contentBases indexOfObject:base];
    UIProgressView* progressView =self.progressViews[i];
    [progressView setProgress:g];
  });
}

- (void)complete:(ContentBase*)base {
  dispatch_async(dispatch_get_main_queue(), ^{
    base.downloadComplete = [NSNumber numberWithBool:YES];
    
    NSError* error;
    [[ContentManager instance].managedObjectContext save:&error];
    if(nil != error) {
      NSLog(@"%@", error.debugDescription);
    } // if
    
    // 更新UI，但要記得要處理找不到的情況，因為有可能正在讀的時候就換了別頁，如此一來index就會不對。
    int i =[self.contentBases indexOfObject:base];
    if(NSNotFound == i) {
      return;
    } // if

    UIButton* btn =self.buttons[i];
    [btn setTitle:@"瀏覽" forState:UIControlStateNormal];
    [btn setHidden:NO];
    [btn removeTarget:self action:@selector(toBeginDownload:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(toContentScrollViewController:) forControlEvents:UIControlEventTouchUpInside];
  
    UIProgressView* progressView =self.progressViews[i];
    [progressView setHidden:YES];
  });
}


- (void)fail:(ContentBase*)base message:(NSString *)msg {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"發生錯誤" message:msg
                        delegate:nil cancelButtonTitle:@"關閉" otherButtonTitles:nil];
    
    [alert show];
    
    int i =[self.contentBases indexOfObject:base];
    
    // 記得要處理找不到的情況，因為有可能正在讀的時候就換了別頁，如此一來index就會不對。
    if(NSNotFound == i) {
      return;
    } // if
    
    UIButton* btn =self.buttons[i];
    [btn setTitle:@"開始下載" forState:UIControlStateNormal];
  });
}

@end
