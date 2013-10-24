//
//  NetworkUtils.h
//  SYM
//
//  Created by HsiuYi on 2013/10/24.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUtils : NSObject

+ (BOOL)isNetworkAvailable;
+ (NSString *)macAddress;

@end
