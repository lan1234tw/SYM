//
//  HTTPDownloader.m
//  SYM
//
//  Created by HsiuYi on 13/9/24.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "HTTPDownloader.h"

@interface HTTPDownloader()
@end


@implementation HTTPDownloader

#pragma marks - Private

#pragma marks - Public

- (void)addItem {
}

- (void)cancelItem {
}

- (NSMutableArray*)getList:(NSString*)urlPath {
    NSMutableArray* list =nil;
    list =[[NSMutableArray alloc] init];
    
    @try {
        NSURL* url =nil;
        url =[NSURL URLWithString:urlPath];
    
        NSData* data =nil;
        data =[NSData dataWithContentsOfURL:url];
    
        NSString* urlContent =[NSString alloc];
        urlContent =[urlContent initWithData:data encoding:NSASCIIStringEncoding];
    
        NSError* error;
        list =[NSJSONSerialization JSONObjectWithData:data
               options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers
               error:&error];
    
        if(nil != error) {
            NSLog(@"%@", error.debugDescription);
        } // if
    } // @try
    @catch(NSException* ex) {
        NSLog(@"%@", ex.debugDescription);
    } // @catch
    
    return list;
}

- (void)downloadItem {
  ///MARK:以下程式碼是用來參考如何利用NSMutableURLRequest物件POST資料
  
  NSString *post = @"mac=abcdefg";
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

  NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
   
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:[NSURL URLWithString:@"http://127.0.0.1:8080/symBack/Test.jsp"]];
  [request setHTTPMethod:@"POST"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  
  if(YES == [NSURLConnection canHandleRequest:request]) {
    NSData* data =nil;
    NSURLResponse* response =nil;
    NSError* err;
    data =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    ///MARK:轉型為NSHTTPURLResponse以便取得狀態碼
    if(YES == [response isKindOfClass:NSHTTPURLResponse.class]) {
      NSHTTPURLResponse* httpResponse =nil;
      httpResponse =(NSHTTPURLResponse*)response;
      
      NSLog(@"Status Code : %d", httpResponse.statusCode);
    } // if
    
    if(nil != err) {
      NSLog(@"%@", err.debugDescription);
      return;
    } // if
  } // if
}

@end
