//
//  PageModel.m
//  SYM
//
//  Created by HsiuYi on 13/10/9.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "PageModel.h"
#import "stageViewController.h"

@interface PageModel() {
    NSArray* images;
}

@end

@implementation PageModel

- (id)init {
    self = [super init];
    if (self) {
        if(nil == images) {
            images =@[@"foa002.jpg", @"foa003.jpg"];
        } // if
    }
    return self;
}

- (void)awakeFromNib {
}

- (NSString*)pathOfIndex:(int)i {
    if(nil == images || i >= images.count) {
        return nil;
    } // if
    else {
        return images[i];
    } // else
}

#pragma mark - UIPageViewDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    stageViewController* stageView =nil;
    stageView =(stageViewController*)viewController;
    
    NSUInteger index =0;
    index =[images indexOfObject:stageView.imagePath];
    if(0 == index || NSNotFound == index) {
        return nil;
    } // if
    
    --index;
    
    id returnVal =[viewController.storyboard instantiateViewControllerWithIdentifier:@"stageViewController"];
    if(nil == returnVal) {
        NSLog(@"無法實體化指定的controller");
        return nil;
    } // if
    stageView =(stageViewController*)returnVal;
    stageView.imagePath =images[index];
    
    return stageView;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    stageViewController* stageView =nil;
    stageView =(stageViewController*)viewController;
    
    NSUInteger index =0;
    index =[images indexOfObject:stageView.imagePath];
    if(NSNotFound == index) {
        return nil;
    } // if
    
    ++index;
    
    if(index >= images.count) {
        return nil;
    } // if
    
    id returnVal =[viewController.storyboard instantiateViewControllerWithIdentifier:@"stageViewController"];
    if(nil == returnVal) {
        NSLog(@"無法實體化指定的controller");
        return nil;
    } // if
    stageView =(stageViewController*)returnVal;
    stageView.imagePath =images[index];
    
    return stageView;
}


- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 2;
}

@end
