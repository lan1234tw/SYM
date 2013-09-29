//
//  HTTPDownloader.h
//  SYM
//
//  Created by HsiuYi on 13/9/24.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPDownloader : NSObject


#pragma mark - 讀取下載清單
- (NSMutableArray*)getList:(NSString*)urlPath;    // MARK:從指定的URL讀取JSON資料


#pragma mark - 加入排程讀取
- (void)addItem;
- (void)cancelItem;


@end
