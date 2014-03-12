//
//  DownloadTask.m
//  SYM
//
//  Created by HsiuYi on 2014/1/6.
//  Copyright (c) 2014年 HsiuYi. All rights reserved.
//

#import "DownloadTask.h"

@implementation DownloadTask
@synthesize manager = _manager, contentBase = _contentBase;

- (void)main {
  
  // url先編碼過一次，以免檔名有些什麼亂七八糟的字
  NSString* encodedUrl = [self.contentBase.archivePath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:[NSURL URLWithString:encodedUrl]];
  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  
  NSURLConnection* conn =nil;
  
  ///MARK:要用帶startImmediately參數的初始器，否則一啟動就會開始傳輸，無法做後續的設定。
  conn =[[NSURLConnection alloc] initWithRequest:request
                                 delegate:self.manager
                                 startImmediately:NO];
  [conn setDelegateQueue:self.manager.queue];
  self.manager.currentBase =self.contentBase;
  
  [conn start];
}

@end
