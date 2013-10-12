//
//  ContentPageModel.m
//  SYM
//
//  Created by HsiuYi on 13/10/12.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "ContentPageModel.h"

@interface ContentPageModel() {
    NSString* contentPath;
    NSMutableArray* contents;
}

@end

/// MARK:Implementation
@implementation ContentPageModel

- (id)init {
    self = [super init];
    if (self) {
        if(nil == contents) {
            contents =[[NSMutableArray alloc] init];
        } // if
    }
    return self;
}

- (void)reloadContenetFromPath:(NSString*)path {
    [contents removeAllObjects];
    
    NSFileManager* fileManager =nil;
    fileManager =[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnum =[fileManager enumeratorAtPath:path];
    
    // 把檔案列示出來看看是不是正常
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        file =[path stringByAppendingPathComponent:file];
        NSLog(@">>> %@", file);
        [contents addObject:file];
    } // while
}

// 找出指定的viewController是顯示哪一筆資料
- (NSUInteger)indexViewController:(ContentViewController*)viewController {
    return [contents indexOfObject:viewController.imagePath];
}

- (ContentViewController*)viewControllerAtIndex:(int)index storyboard:(UIStoryboard *)storyboard {
    ContentViewController* contentViewController =nil;
    contentViewController =(ContentViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ContentViewController"];
    contentViewController.imagePath =contents[index];
    return contentViewController;
}

#pragma mark - UIPageViewDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    ContentViewController* contentViewController =nil;
    contentViewController =(ContentViewController*)viewController;
    
    NSUInteger i =[self indexViewController:contentViewController];
    if(NSNotFound == i || 0 == i) {
        return nil;
    } // if
    else {
        --i;
        contentViewController =[self viewControllerAtIndex:i storyboard:pageViewController.storyboard];
        return contentViewController;
    } // else
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    ContentViewController* contentViewController =nil;
    contentViewController =(ContentViewController*)viewController;
    
    NSUInteger i =[self indexViewController:contentViewController];
    if(NSNotFound == i ) {
        return 0;
    } // if
    else {
        ++i;
        if(contents.count <= i) {
            return nil;
        } // if
        
        contentViewController =[self viewControllerAtIndex:i storyboard:pageViewController.storyboard];
        return contentViewController;
    } // else
}

/*
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}
*/

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    if(nil != contents) {
        return contents.count;
    } // if
    else {
        return 0;
    } // else
}


@end
