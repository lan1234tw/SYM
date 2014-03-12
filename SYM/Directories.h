//
//  Directories.h
//  SYM
//
//  Created by HsiuYi on 2014/1/10.
//  Copyright (c) 2014年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Directories : NSObject

+ (Directories*)instance;
- (NSURL*)documentDirectory;
- (NSURL*)cacheDirectory;

@end
