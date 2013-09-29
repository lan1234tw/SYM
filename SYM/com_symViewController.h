//
//  com_symViewController.h
//  SYM
//
//  Created by HsiuYi on 13/9/17.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface com_symViewController : UIViewController<UITableViewDataSource> {
    NSMutableArray* items;
}

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@end
