//
//  ContentItem.h
//  SYM
//
//  Created by HsiuYi on 2014/1/27.
//  Copyright (c) 2014年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentBase;

@interface ContentItem : NSManagedObject

@property (nonatomic, retain) NSString * itemType;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSData * pictureData;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) ContentBase *base;

@end
