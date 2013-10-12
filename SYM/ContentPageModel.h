//
//  ContentPageModel.h
//  SYM
//
//  Created by HsiuYi on 13/10/12.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"

@interface ContentPageModel : NSObject<UIPageViewControllerDataSource>

// 清除掉舊資料，從指定的路徑讀取資料
- (void)reloadContenetFromPath:(NSString*)path;
- (ContentViewController*)viewControllerAtIndex:(int)index storyboard:(UIStoryboard*)storyboard;

@end
