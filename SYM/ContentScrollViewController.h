//
//  ContentScrollViewController.h
//  SYM
//
//  Created by HsiuYi on 2013/10/28.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentBase.h"
#import "ContentItem.h"

@interface ContentScrollViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource> {
}

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *fastGuideView;

@property (weak, nonatomic) ContentBase* base;

@end
