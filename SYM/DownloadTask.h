//
//  DownloadTask.h
//  SYM
//
//  Created by HsiuYi on 2014/1/6.
//  Copyright (c) 2014年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentManager.h"

@interface DownloadTask : NSOperation

@property (nonatomic, weak) ContentManager* manager;
@property (nonatomic, strong) ContentBase* contentBase;

@end
