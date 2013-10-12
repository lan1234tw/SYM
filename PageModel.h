//
//  PageModel.h
//  SYM
//
//  Created by HsiuYi on 13/10/9.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageModel : NSObject<UIPageViewControllerDataSource>

- (NSString*)pathOfIndex:(int)i;

@end
