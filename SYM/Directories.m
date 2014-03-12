//
//  Directories.m
//  SYM
//
//  Created by HsiuYi on 2014/1/10.
//  Copyright (c) 2014年 HsiuYi. All rights reserved.
//

#import "Directories.h"

@implementation Directories

+ (Directories*)instance {
  static Directories* _instance =nil;
  static dispatch_once_t predicate;
  
  dispatch_once(&predicate, ^{
      _instance =[[Directories alloc] init];
  });
  
  return _instance;
}


- (NSURL*)documentDirectory {
  return [[[NSFileManager defaultManager]
           URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL*)cacheDirectory {
  return [[[NSFileManager defaultManager]
           URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
