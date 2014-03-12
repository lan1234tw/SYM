//
//  StageViewController.h
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIProgressView.h>
#import "ContentManager.h"

#define STAGE_NUMBER  8 // Stage每頁要展示的項目數

@interface StageViewController : UIViewController {
}

@property (strong, nonatomic) NSString* imagePath;

@property (strong, nonatomic) NSMutableArray* contentBases;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray* imageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* descLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* durations;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* buttons;

@property (strong, nonatomic) IBOutletCollection(UIProgressView) NSArray* progressViews;

@end
