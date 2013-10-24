//
//  StageViewController.h
//  SYM
//
//  Created by HsiuYi on 13/10/4.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define STAGE_NUMBER  8 // Stage每頁要展示的項目數

@interface StageViewController : UIViewController {
}

@property (weak, nonatomic) IBOutlet UIButton *itemBtn1;
@property (weak, nonatomic) IBOutlet UIButton *itemBtn2;
@property (weak, nonatomic) IBOutlet UIScrollView *scrooView;

@end
