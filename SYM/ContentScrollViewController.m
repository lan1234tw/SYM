//
//  ContentScrollViewController.m
//  SYM
//
//  Created by HsiuYi on 2013/10/28.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "ContentScrollViewController.h"
#import "ContentViewController.h"
#import "Cell.h"
#import "ContentManager.h"

@interface ContentScrollViewController () {
  NSMutableArray* contentImages;
  NSMutableArray* thumbnailImages;
  int currentPage;
}

@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation ContentScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
      currentPage =0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Custom initialization
    currentPage =0;
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  NSUInteger numberPages = self.base.items.count;
  
  NSMutableArray *controllers = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < numberPages; i++) {
    [controllers addObject:[NSNull null]];
  }
  self.viewControllers = controllers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"讀取中" message:nil
                        delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
  
  UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc]
                                      initWithFrame: CGRectMake(125, 50, 30, 30)];
  progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  [alert addSubview: progress];
  [progress startAnimating];

  [alert show];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    int itemCount =0;
    itemCount =self.base.items.count;
  
    // 尺寸不能在viewDidLoad處理，否則會讀到直立的尺寸
    CGSize contentSize =CGSizeMake(
         itemCount *CGRectGetWidth(self.contentScrollView.frame),
         CGRectGetHeight(self.contentScrollView.frame));
  
    [self.contentScrollView setContentSize:contentSize];
    self.contentScrollView.scrollsToTop = NO;
    self.pageControl.currentPage =0;
    self.pageControl.numberOfPages =itemCount;

    // contentImages =[[NSMutableArray alloc] initWithCapacity:itemCount];
    thumbnailImages =[[NSMutableArray alloc] initWithCapacity:itemCount];
    
    for(int i =0; i < itemCount; ++i) {
      ContentItem* item =nil;
      item =[self.base.items objectAtIndex:i];
      thumbnailImages[i] =[UIImage imageWithData:item.thumbnailData];
      [[ContentManager instance].managedObjectContext refreshObject:item mergeChanges:NO];
    } // for
    
    /*
    dispatch_apply(itemCount,
       // 不能放到main queue裡面，否則會跑不出來
       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t k) {
         @try {
           ContentItem* item;
           item =self.base.items[k];
           contentImages[k] =[UIImage imageWithData:item.pictureData];
         }
         @catch(NSException* ex) {
           NSLog(@"%@", ex.debugDescription);
         }
      }
    );
    */
    [self.fastGuideView reloadData]; // 圖讀完了，要reload一下否則導覽會沒圖
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
  });

  [alert dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
  [[ContentManager instance].managedObjectContext refreshObject:self.base mergeChanges:NO];
}

// -------------------------------------------------------------
- (void)loadScrollViewWithPage:(NSUInteger)page {
  if (page >= self.base.items.count) {
    return;
  }
  
  // replace the placeholder if necessary
  ContentViewController *controller = [self.viewControllers objectAtIndex:page];
  if ((NSNull *)controller == [NSNull null]) {
    controller =[self.storyboard instantiateViewControllerWithIdentifier:@"ID_ContentViewController"];
    
    ContentItem* item =nil;
    item =[self.base.items objectAtIndex:page];
    UIImage* img =[UIImage imageWithData:item.pictureData];
    controller.img =img;
    
    [self.viewControllers replaceObjectAtIndex:page withObject:controller];
  }
  
  // add the controller's view to the scroll view
  if (controller.view.superview == nil) {
    CGRect frame = self.contentScrollView.frame;
    frame.origin.x = CGRectGetWidth(frame) * page;
    frame.origin.y = 0;
    controller.view.frame = frame;
    
    [self addChildViewController:controller];
    [self.contentScrollView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    ContentItem* item =nil;
    item =[self.base.items objectAtIndex:page];
    UIImage* img =[UIImage imageWithData:item.pictureData];
    controller.img =img;
  } //if
}
// -------------------------------------------------------------

#pragma mark -
- (void)gotoPage:(BOOL)animated {
  NSInteger page = self.pageControl.currentPage;
  
  // update the scroll view to the appropriate page
  CGRect bounds = self.contentScrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * page;
  bounds.origin.y = 0;
  [self.contentScrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender {
  [self gotoPage:YES];
}

- (IBAction)backBtn_touched:(id)sender {
  [[ContentManager instance].managedObjectContext reset];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)guideBtn_touched:(id)sender {
  [self.view bringSubviewToFront:self.fastGuideView];
  if(YES == self.fastGuideView.hidden) {
    [self.fastGuideView setHidden:NO];
  } // if
  else {
    [self.fastGuideView setHidden:YES];
  } // else
}

- (IBAction)prevBtn_touched:(id)sender {
  int page =self.pageControl.currentPage;
  
  if(0 >= page) {
    return;
  } // if
  else {
    --page;
    
    [self loadScrollViewWithPage:page -1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page +1];
    
    self.pageControl.currentPage =page;
    [self gotoPage:YES];
  } // else
}

- (IBAction)nextBtn_touched:(id)sender {
  int page =self.pageControl.currentPage +1;
  
  if(page >= self.pageControl.numberOfPages) {
    return;
  } // if
  else {
    [self loadScrollViewWithPage:page -1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page +1];
    
    self.pageControl.currentPage =page;
    [self gotoPage:YES];
  } // else
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  int page =indexPath.row;
  
  [self loadScrollViewWithPage:page -1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page +1];
  
  self.pageControl.currentPage =page;  // 切到指定的那張圖去
  [self gotoPage:YES];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell*)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ID_CollectionCell" forIndexPath:indexPath];
  
  // load the image for this cell
  cell.imageView.image = thumbnailImages[indexPath.row];
  return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return thumbnailImages.count;
}

@end
