//
//  ContentItem.h
//  SYM
//
//  Created by HsiuYi on 13/10/15.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentBase;

@interface ContentItem : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) ContentBase *base;

@end
