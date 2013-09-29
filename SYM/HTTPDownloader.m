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
        
#ifdef DEBUG
        NSLog(@"從%@讀得資料：%@", urlPath, urlContent);
#endif
    
        NSError* error;
        list =[NSJSONSerialization JSONObjectWithData:data
                              options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers
                              error:&error];
    
        if(nil != error) {
            NSLog(@"%@", error.debugDescription);
        } // if
        else {
            
#ifdef DEBUG
            for(int i =0; i < [list count]; ++i) {
                NSLog(@"%@", list[i]);
            } // for
#endif
            
        } // else
    } // @try
    @catch(NSException* ex) {
        NSLog(@"%@", ex.debugDescription);
    } // @catch
    
    return list;
}

@end
